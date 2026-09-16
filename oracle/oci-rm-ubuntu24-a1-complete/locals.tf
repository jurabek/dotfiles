locals {
  # Fixed exactly as requested.
  region              = "eu-frankfurt-1"
  availability_domain = "aCvB:EU-FRANKFURT-1-AD-3"
  instance_shape      = "VM.Standard.A1.Flex"

  # Canonical-Ubuntu-24.04-Minimal-aarch64-2026.08.25-0
  image_id = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4nss3uamvyav7jykr6k4jw6jx5ysh2ggw6go5l56fm5qwfdktruq"

  # Reusing these CIDRs is fine because each Resource Manager stack creates
  # a completely separate VCN.
  vcn_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.20.0/24"

  # Matches the useful inbound ports from the original configuration.
  ingress_tcp_ports = [22, 80, 3000, 3005]
}
