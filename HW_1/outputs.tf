output "public_ip" {
  value = yandex_compute_instance.web.network_interface[0].nat_ip_address
}

output "private_ip" {
  value = yandex_compute_instance.web.network_interface[0].ip_address
}

output "last_ubuntu_id" {
    value = data.yandex_compute_image.last_ubuntu.id
}

output "subnet_id" {
    value = data.yandex_vpc_subnet.default_b.subnet_id
}