variable "tenancy_ocid" {
  description = "OCID del Tenancy (ID de la cuenta)"
  type        = string
}

variable "user_ocid" {
  description = "OCID del usuario de Oracle Cloud"
  type        = string
}

variable "fingerprint" {
  description = "Huella digital de tu clave API"
  type        = string
}

variable "private_key_path" {
  description = "Ruta local al archivo .pem de tu clave privada"
  type        = string
}

variable "region" {
  description = "Región de Oracle Cloud"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_id" {
  description = "OCID del Compartment (la carpeta lógica en Oracle donde vivirá tu infra)"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Ruta local a tu clave SSH pública (ej: ~/.ssh/id_rsa.pub)"
  type        = string
}