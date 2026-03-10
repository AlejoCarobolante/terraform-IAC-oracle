# 1. La Red Virtual (VCN) - El paraguas principal
resource "oci_core_vcn" "k3s_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "k3s-cluster-vcn"
  dns_label      = "k3svcn"
}

# 2. El Internet Gateway - La puerta de salida a internet
resource "oci_core_internet_gateway" "k3s_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s-igw"
  enabled        = true
}

# 3. Tabla de Ruteo
resource "oci_core_default_route_table" "k3s_route_table" {
  manage_default_resource_id = oci_core_vcn.k3s_vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.k3s_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# 4. El Firewall (Security List)
resource "oci_core_security_list" "k3s_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s-security-list"

  # Salida: Permitimos que el servidor descargue cosas de cualquier lado
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Entrada: SSH (Puerto 22) para que puedas entrar a la consola
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      max = 22
      min = 22
    }
  }

  # Entrada: HTTP (Puerto 80)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 80
      min = 80
    }
  }

  # Entrada: HTTPS (Puerto 443)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 443
      min = 443
    }
  }
}

# 5. La Subred Pública
resource "oci_core_subnet" "k3s_public_subnet" {
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.k3s_vcn.id
  cidr_block          = "10.0.1.0/24"
  display_name        = "k3s-public-subnet"
  route_table_id      = oci_core_vcn.k3s_vcn.default_route_table_id
  security_list_ids   = [oci_core_security_list.k3s_security_list.id]
  dhcp_options_id     = oci_core_vcn.k3s_vcn.default_dhcp_options_id
  dns_label           = "public"
}