# OCI Resource Manager provides authentication automatically.
# This stack is intentionally fixed to Frankfurt.
provider "oci" {
  region = local.region
}
