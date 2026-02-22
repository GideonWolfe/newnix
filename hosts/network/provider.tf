terraform {
  required_providers {
    routeros = {
      source = "terraform-routeros/routeros"
    }
  }
}

provider "routeros" {
  hosturl        = "https://router.local"        # env ROS_HOSTURL or MIKROTIK_HOST
  username       = "admin"                       # env ROS_USERNAME or MIKROTIK_USER
  password       = ""                            # env ROS_PASSWORD or MIKROTIK_PASSWORD
  ca_certificate = "/path/to/ca/certificate.pem" # env ROS_CA_CERTIFICATE or MIKROTIK_CA_CERTIFICATE
  insecure       = true                          # env ROS_INSECURE or MIKROTIK_INSECURE
}
