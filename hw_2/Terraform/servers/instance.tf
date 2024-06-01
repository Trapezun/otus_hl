data "yandex_compute_image" "last_ubuntu" {
  family = "ubuntu-2204-lts" 
}

data "yandex_vpc_subnet" "private" {
  name = "private-vpc-subnet"
}






resource "yandex_compute_instance" "db" { 
  name = "mini-instance-db"
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)

  metadata = {
    ssh-keys = "ubuntu:${file("./../id_rsa.pub")}"
  }

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2 # vCPU
    memory = 1 # RAM
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.private.id  
  }

  provisioner "local-exec" {           
      command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.db.network_interface[0].ip_address},' -e 'ip_bastion={ip_bastion}' ./../../Ansible/start_db.yml"
  }
}



resource "yandex_compute_instance" "business" { 
  count = 2
  name = "mini-instance-business-${count.index + 1}"
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)

  metadata = {
    ssh-keys = "ubuntu:${file("./../id_rsa.pub")}"
  }

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2 # vCPU
    memory = 1 # RAM
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.private.id  
    #nat=true
  }

  provisioner "local-exec" {           
      command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.business.network_interface[0].ip_address},' -e 'ip_bastion={ip_bastion}, DB_HOST=${yandex_compute_instance.db.network_interface[0].ip_address}' ./../../Ansible/start_business.yml"
  }

}


resource "yandex_compute_instance" "front" { 

  count = 2
  name = "mini-instance-front-${count.index + 1}"
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)

  metadata = {
    ssh-keys = "ubuntu:${file("./../id_rsa.pub")}"
  }

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2 # vCPU
    memory = 1 # RAM
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.private.id  
    nat = true 
  }

    provisioner "local-exec" {           
      #command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.front.network_interface[0].ip_address}' -e '{ip_bastion:{ip_bastion}, "ip_addresses": ["10.0.1.5", "10.0.1.27"]}' ./../../Ansible/start_front.yml"
      command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.front.network_interface[0].ip_address}' -e '{ip_bastion:{ip_bastion}, "ip_addresses": [${yandex_compute_instance.business.network_interface[0].ip_address}]}' ./../../Ansible/start_front.yml"
  }
  
}


resource "yandex_lb_target_group" "lb_target_group" {
  name = "lb-target-group"
  
  target {
    subnet_id = data.yandex_vpc_subnet.private.id
    address   = yandex_compute_instance.front[0].network_interface[0].ip_address
  }
  target {
    subnet_id = data.yandex_vpc_subnet.private.id
    address   = yandex_compute_instance.front[1].network_interface[0].ip_address
  }
     
}
resource "yandex_lb_network_load_balancer" "ng_load_balancer" {
  name = "ng-load-balancer"
  
  listener {
    name         = "http"
    port         = 80
    target_port  = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  
  attached_target_group {
    target_group_id = yandex_lb_target_group.lb_target_group.id
    healthcheck {
      name = "http"
      http_options {
        path = "/health"
        port = 80
      }
    }
  }
}







 #eval "$(ssh-agent -s)"
 #ssh-add ~/.ssh/id_ed25519


  