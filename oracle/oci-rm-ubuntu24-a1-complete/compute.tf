resource "oci_core_instance" "vm" {
  count = var.vm_count

  availability_domain = local.availability_domain
  compartment_id      = var.compartment_ocid
  display_name = var.vm_count == 1 ? (
    var.vm_name_prefix
  ) : format("%s-%02d", var.vm_name_prefix, count.index + 1)
  shape = local.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = format("%s-%02d-vnic", var.vm_name_prefix, count.index + 1)
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id
  }

  metadata = {
    ssh_authorized_keys = trimspace(var.ssh_public_key)
  }
}
