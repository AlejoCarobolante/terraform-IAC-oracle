output "instance_public_ip" {
  description = "La dirección IP pública de la máquina para SSH o DNS"
  value       = oci_core_instance.k3s_server.public_ip
}

output "ssh_connection_string" {
  description = "Cadena de conexión SSH para acceder a la máquina"
  value       = "ssh ubuntu@${oci_core_instance.k3s_server.public_ip}"
}