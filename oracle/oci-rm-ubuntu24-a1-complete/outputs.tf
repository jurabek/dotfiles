output "region" {
  value = local.region
}

output "availability_domain" {
  value = local.availability_domain
}

output "image_id" {
  value = local.image_id
}

output "vcn_id" {
  value = oci_core_virtual_network.vcn.id
}

output "subnet_id" {
  value = oci_core_subnet.public_subnet.id
}

output "instance_ids" {
  value = oci_core_instance.vm[*].id
}

output "instance_names" {
  value = oci_core_instance.vm[*].display_name
}

output "public_ips" {
  value = oci_core_instance.vm[*].public_ip
}

output "private_ips" {
  value = oci_core_instance.vm[*].private_ip
}

output "ssh_commands" {
  description = "SSH commands for Ubuntu."
  value       = [for ip in oci_core_instance.vm[*].public_ip : "ssh ubuntu@${ip}"]
}

output "load_balancer_public_ips" {
  value = var.create_load_balancer ? [
    for detail in oci_load_balancer_load_balancer.public_lb[0].ip_address_details : detail.ip_address
  ] : []
}
