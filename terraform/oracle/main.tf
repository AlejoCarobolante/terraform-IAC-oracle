# 1. Buscamos la zona de disponibilidad en la región
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# 2. Buscamos la última imagen oficial de Ubuntu 22.04 para procesadores ARM
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# 3. Creamos el servidor (La instancia)
resource "oci_core_instance" "k3s_server" {
  # Usamos la primera zona de disponibilidad disponible
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"
  display_name        = "k3s-master-node"

  # Definimos la máquina virtual
  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  # La conectamos a la subred pública de network.tf
  create_vnic_details {
    subnet_id        = oci_core_subnet.k3s_public_subnet.id
    display_name     = "primary-vnic"
    assign_public_ip = true
  }

  # Instalar el sistema operativo que buscamos en el paso 2
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  # Inyectar la clave SSH PÚBLICA para poder entrar e instalar K3s y ArgoCD automáticamente con el script install_k3s_argo.sh
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    # Codificamos el script en base64 (requerimiento de Oracle) y se lo pasamos
    user_data           = base64encode(file("${path.module}/install_k3s_argo.sh"))
  }
}