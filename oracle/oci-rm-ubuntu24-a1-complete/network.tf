resource "oci_core_virtual_network" "vcn" {
  cidr_block     = local.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.vm_name_prefix}-vcn"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vm_name_prefix}-igw"
  vcn_id         = oci_core_virtual_network.vcn.id
  enabled        = true
}

resource "oci_core_route_table" "public_routes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.vm_name_prefix}-public-routes"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_security_list" "vm_security" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.vm_name_prefix}-security-list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = { for port in local.ingress_tcp_ports : tostring(port) => port }

    content {
      protocol = "6"
      source   = "0.0.0.0/0"

      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
    }
  }
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block                 = local.subnet_cidr
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = "${var.vm_name_prefix}-public-subnet"
  route_table_id             = oci_core_route_table.public_routes.id
  security_list_ids          = [oci_core_security_list.vm_security.id]
  dhcp_options_id            = oci_core_virtual_network.vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
}
