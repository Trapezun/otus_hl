data "yandex_compute_image" "last_ubuntu" {
  family = "ubuntu-2204-lts" 
}

data "yandex_vpc_subnet" "default_b" {
  name = "default-ru-central1-b"  # одна из дефолтных подсетей
}

resource "yandex_compute_instance" "bastion" { 
  name = "mini-instance-bastion"
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)

  metadata = {
    ssh-keys = "ubuntu:${file("id_rsa.pub")}"
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
    subnet_id = data.yandex_vpc_subnet.default_b.subnet_id     
    nat = true 
  }
}


resource "yandex_compute_instance" "db" { 
  name = "mini-instance-db"
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)

  metadata = {
    ssh-keys = "ubuntu:${file("id_rsa.pub")}"
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
    subnet_id = data.yandex_vpc_subnet.default_b.subnet_id 
    nat = true
  }
}


resource "yandex_compute_instance" "business" { 
  count = 2
  name = "mini-instance-business-${count.index + 1}"
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)

  metadata = {
    ssh-keys = "ubuntu:${file("id_rsa.pub")}"
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
    subnet_id = data.yandex_vpc_subnet.default_b.subnet_id 
    nat = true
  }
}


resource "yandex_compute_instance" "front" { 
  name = "mini-instance-front"
	platform_id = "standard-v1" # тип процессора (Intel Broadwell)

  metadata = {
    ssh-keys = "ubuntu:${file("id_rsa.pub")}"
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
    subnet_id = data.yandex_vpc_subnet.default_b.subnet_id 
    nat = true 
  }
}






  