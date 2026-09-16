resource "oci_load_balancer_load_balancer" "public_lb" {
  count = var.create_load_balancer ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${var.vm_name_prefix}-lb"
  shape          = "flexible"
  subnet_ids     = [oci_core_subnet.public_subnet.id]

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }
}

resource "oci_load_balancer_backend_set" "vm_backends" {
  count = var.create_load_balancer ? 1 : 0

  name             = "vmBackends"
  load_balancer_id = oci_load_balancer_load_balancer.public_lb[0].id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = 80
  }
}

resource "oci_load_balancer_backend" "vm" {
  count = var.create_load_balancer ? var.vm_count : 0

  backendset_name  = oci_load_balancer_backend_set.vm_backends[0].name
  ip_address       = oci_core_instance.vm[count.index].private_ip
  load_balancer_id = oci_load_balancer_load_balancer.public_lb[0].id
  port             = 80
}

resource "oci_load_balancer_listener" "http" {
  count = var.create_load_balancer ? 1 : 0

  load_balancer_id         = oci_load_balancer_load_balancer.public_lb[0].id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.vm_backends[0].name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = 240
  }
}
