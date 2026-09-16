variable "compartment_ocid" {
  type        = string
  description = "Compartment in which the complete isolated VM environment will be created."
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key installed on every VM."

  validation {
    condition     = length(trimspace(var.ssh_public_key)) > 0
    error_message = "ssh_public_key must not be empty."
  }
}

variable "vm_name_prefix" {
  type        = string
  description = "Display-name prefix for this stack's VM(s) and network resources."
  default     = "ubuntu-a1"

  validation {
    condition     = length(trimspace(var.vm_name_prefix)) > 0
    error_message = "vm_name_prefix must not be empty."
  }
}

variable "vm_count" {
  type        = number
  description = "Number of Ubuntu ARM VMs created inside this new VCN."
  default     = 1

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10 && floor(var.vm_count) == var.vm_count
    error_message = "vm_count must be a whole number from 1 through 10."
  }
}

variable "instance_ocpus" {
  type        = number
  description = "OCPUs per VM.Standard.A1.Flex instance."
  default     = 1

  validation {
    condition     = var.instance_ocpus > 0
    error_message = "instance_ocpus must be greater than 0."
  }
}

variable "instance_memory_in_gbs" {
  type        = number
  description = "Memory in GB per VM.Standard.A1.Flex instance."
  default     = 6

  validation {
    condition     = var.instance_memory_in_gbs > 0
    error_message = "instance_memory_in_gbs must be greater than 0."
  }
}

variable "create_load_balancer" {
  type        = bool
  description = "Create a flexible public Load Balancer and register every VM on port 80."
  default     = true
}
