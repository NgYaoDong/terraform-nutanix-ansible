# Client VM resources
resource "nutanix_virtual_machine" "client" {
  for_each             = toset(local.client_names) # One VM per client name
  name                 = each.key                  # VM name
  cluster_uuid         = local.cluster_uuid        # Cluster to deploy to
  num_vcpus_per_socket = 2                         # vCPUs per socket
  num_sockets          = 1                         # Number of sockets
  memory_size_mib      = 512                       # Memory in MiB

  categories {
    name = "role"
    value = "client" # Category for client VMs
  }

  depends_on = [
    nutanix_virtual_machine.gateway # Ensure gateway VMs are created first
  ]

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = local.image_uuid # Use the specified image
    }
    device_properties {
      device_type = "DISK" # Disk type
    }
    disk_size_mib = 8192 # Disk size in MiB
  }

  nic_list {
    subnet_uuid = local.internet_subnet_uuid # Attach to internet subnet
    ip_endpoint_list {
      ip   = local.client_ips[each.key] # Assign static IP
      type = "ASSIGNED"                 # Default type for assigned IPs
    }
  }
}

# Gateway VM resources
resource "nutanix_virtual_machine" "gateway" {
  for_each             = toset(local.gateway_names) # One VM per gateway name
  name                 = each.key                   # VM name
  cluster_uuid         = local.cluster_uuid         # Cluster to deploy to
  num_vcpus_per_socket = 2                          # vCPUs per socket
  num_sockets          = 1                          # Number of sockets
  memory_size_mib      = 512                        # Memory in MiB

  categories {
    name = "role"
    value = "gateway" # Category for gateway VMs
  }

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = local.image_uuid # Use the specified image
    }
    device_properties {
      device_type = "DISK" # Disk type
    }
    disk_size_mib = 8192 # Disk size in MiB
  }

  nic_list {
    subnet_uuid = local.internet_subnet_uuid # Attach to internet subnet
    ip_endpoint_list {
      ip   = local.gateway_internet_ips[each.key] # Assign static IP
      type = "ASSIGNED"                           # Default type for assigned IPs
    }
  }

  nic_list {
    subnet_uuid = local.intranet_subnet_uuid # Attach to intranet subnet
    ip_endpoint_list {
      ip   = local.gateway_intranet_ips[each.key] # Assign static IP
      type = "ASSIGNED"                           # Default type for assigned IPs
    }
  }
}
