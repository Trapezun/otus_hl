data "yandex_compute_image" "last_ubuntu" {
  family = "ubuntu-2204-lts" 
}

resource "yandex_vpc_network" "global_network" {
  folder_id = var.folder_id
  name = "network-servers"
}
resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id    = var.folder_id
  name = "nat-gateway-servers"
  shared_egress_gateway {}
}
resource "yandex_vpc_route_table" "rt" {
  folder_id   = var.folder_id
  name       = "egress-route-table-servers"
  network_id = yandex_vpc_network.global_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
resource "yandex_vpc_subnet" "private" {
  name = "private-vpc-subnet"
  folder_id      =  var.folder_id 
  network_id     = yandex_vpc_network.global_network.id       
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}



resource "yandex_compute_instance" "bastion" { 
  name = "mini-instance-bastion"
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
    subnet_id = yandex_vpc_subnet.private.id     
    nat = true 
  }

  provisioner "local-exec" {
      command = "ansible-playbook -u ubuntu -i '${yandex_compute_instance.bastion.network_interface[0].nat_ip_address},' ./../../Ansible/start_bastion.yml"
  }

}




  