output "private_ip_db" {
  value = yandex_compute_instance.db.network_interface[0].ip_address
}

output "private_ips_business" {
  value = yandex_compute_instance.business[*].network_interface[0].ip_address  
}

output "public_ip_front" {
  value = yandex_compute_instance.front.network_interface[0].nat_ip_address
}

output "public_ip_bastion" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

