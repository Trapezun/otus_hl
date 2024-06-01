output "public_ip_bastion" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

