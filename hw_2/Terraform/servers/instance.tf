data "yandex_compute_image" "last_ubuntu" {
  family = "ubuntu-2204-lts" 
}

data "yandex_vpc_subnet" "private" {
  name = "private-vpc-subnet"  
}

variable "instancesDB" {
  type = map(object({
    name      = string
    ip_address = string
  }))
  default = {
    instance1 = {
      name      = "instance-db-1"
      ip_address = "10.0.1.20"
    }
    instance2 = {
      name      = "instance-db-2"
      ip_address = "10.0.1.21"
    }
    instance3 = {
      name      = "instance-db-3"
       ip_address = "10.0.1.22"
    }
  }
}
resource "yandex_compute_instance" "db" { 

  for_each = var.instancesDB

  name = each.value.name
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)
  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "ubuntu:${file("./../id_rsa.pub")}"
  }

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2 # vCPU
    memory = 4 # RAM
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
      size = 40 
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.private.id  
    ip_address =  each.value.ip_address
    nat = true 
  }

  # provisioner "local-exec" {           
  #     command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.db.network_interface[0].ip_address},' -e 'ip_bastion={ip_bastion}' ./../../Ansible/start_db.yml"
  # }
}


variable "instancesDBProxy" {
  type = map(object({
    name      = string
    ip_address = string
  }))
  default = {
    instance1 = {
      name      = "instance-db-proxy-1"
      ip_address = "10.0.1.11"
    }
    instance2 = {
      name      = "instance-db-proxy-2"
      ip_address = "10.0.1.12"
    }
  }
}
resource "yandex_compute_instance" "db_proxy" { 

  for_each = var.instancesDBProxy

  name = each.value.name
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)
  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "ubuntu:${file("./../id_rsa.pub")}"
  }

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2 # vCPU
    memory = 2 # RAM
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.private.id  
    ip_address =  each.value.ip_address
    nat = true 
  }

  # provisioner "local-exec" {           
  #     command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.db.network_interface[0].ip_address},' -e 'ip_bastion={ip_bastion}' ./../../Ansible/start_db.yml"
  # }
}


variable "instancesBusinessProxy" {
  type = map(object({
    name      = string
    ip_address = string
  }))
  default = {
    instance1 = {
      name      = "instance-business-1"
      ip_address = "10.0.1.31"
    }    
     instance2 = {
      name      = "instance-business-2"
      ip_address = "10.0.1.32"
    }
  }
}
resource "yandex_compute_instance" "business" { 
  for_each = var.instancesBusinessProxy

  name = each.value.name
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)
  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "ubuntu:${file("./../id_rsa.pub")}"
  }

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2 # vCPU
    memory = 4 # RAM
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.private.id  
    ip_address =  each.value.ip_address
    nat=true
  }

  # provisioner "local-exec" {           
  #     command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.business.network_interface[0].ip_address},' -e 'ip_bastion={ip_bastion}, DB_HOST=${yandex_compute_instance.db.network_interface[0].ip_address}' ./../../Ansible/start_business.yml"
  # }

}


resource "yandex_lb_target_group" "target_group_db_proxy" {
  name = "targetgroupdbproxy"
 
  target {    
    subnet_id = data.yandex_vpc_subnet.private.id  
    address   = "10.0.1.11"
  }  

    target {    
    subnet_id = data.yandex_vpc_subnet.private.id  
    address   = "10.0.1.12"
  }
}

resource "yandex_lb_network_load_balancer" "internal_db_balancer" {
  name = "internaldbbalancer"
  type="internal"
  listener {
    name = "db-listener-master"
    port = 5000
    internal_address_spec  {
      ip_version = "ipv4"
      address="10.0.1.10"
      subnet_id= data.yandex_vpc_subnet.private.id  
    }
  }

 listener {
    name = "db-listener-replica"
    port = 5001
    internal_address_spec  {
      ip_version = "ipv4"
      address="10.0.1.10"
      subnet_id= data.yandex_vpc_subnet.private.id  
    }
  }


  attached_target_group {
    target_group_id = yandex_lb_target_group.target_group_db_proxy.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 5000        
      }
    }
  }
}


resource "yandex_lb_target_group" "business_target_group" {
  name = "business-target-group"
  
  target {
    subnet_id = data.yandex_vpc_subnet.private.id
    address   = "10.0.1.31"
  }
  target {
    subnet_id = data.yandex_vpc_subnet.private.id
    address   = "10.0.1.32"
  }
     
}
resource "yandex_lb_network_load_balancer" "business_load_balancer" {
  name = "business-load-balancer"
  
  listener {
    name         = "http"
    port         = 80
    target_port  = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  
  attached_target_group {
    target_group_id = yandex_lb_target_group.business_target_group.id
    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80        
      }

      # name = "http"
      # http_options {
      #   path = "/health"
      #   port = 80
      # }
    }
  }
}










  