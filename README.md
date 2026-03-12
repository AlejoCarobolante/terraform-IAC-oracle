# Infraestructura Personal en Oracle Cloud (K3s + ArgoCD)

Este repositorio contiene la Infraestructura como Código (IaC) para provisionar un clúster ligero de Kubernetes (K3s) sobre una instancia ARM de 24GB de RAM en la capa gratuita de Oracle Cloud Infrastructure (OCI).

El aprovisionamiento incluye la instalación automática de **ArgoCD** para gestionar despliegues mediante GitOps.

## 🏗️ Arquitectura
- **Proveedor:** Oracle Cloud (OCI)
- **Instancia:** VM.Standard.A1.Flex (4 OCPUs, 24GB RAM - ARM64)
- **Orquestador:** K3s (Rancher)
- **GitOps:** ArgoCD

## 🔒 Prerrequisitos (Paso 0)
Antes de ejecutar cualquier comando, necesitas tener configurada tu cuenta de Oracle Cloud y tus claves:
1. Crear una API Key en la consola de Oracle Cloud y descargar el archivo privado `.pem`.
2. Tener una clave SSH local (pública y privada) para acceder al servidor. Ej: `~/.ssh/id_rsa.pub`.
3. Crear un archivo llamado `terraform.tfvars` dentro de la carpeta `terraform/oracle/` (este archivo está ignorado en Git por seguridad).

**Ejemplo de `terraform.tfvars`:**
```bash
tenancy_ocid         = "ocid1.tenancy.oc1..xxxx"
user_ocid            = "ocid1.user.oc1..xxxx"
fingerprint          = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path     = "/ruta/absoluta/a/tu/clave/oracle.pem"
region               = "sa-saopaulo-1" # O la que hayas elegido
compartment_id       = "ocid1.compartment.oc1..xxxx"
ssh_public_key_path  = "/ruta/absoluta/a/tu/clave_ssh_local.pub"
```

## 🚀 Cómo desplegar la infraestructura
Primero, si no tienes un par de llaves SSH, genera uno mediante el comando:

```bash
ssh-keygen -t ed25519 -C "nombre-del-par"
```
Guarda el par en la ruta (en Windows el path suele ser C:\Users\<usuario>/.ssh)

Se van a haber generado:
* id_ed25519: clave privada
* id_ed25519.pub: clave pública

En el archivo `terraform.tfvars`, indicamos el path a la clave pública

Abre tu terminal, navega a la carpeta del proveedor y ejecuta el ciclo de vida de Terraform:

```bash
cd terraform/oracle
```

**1. Inicializar Terraform**
Descarga los plugins necesarios para hablar con Oracle.
```bash
terraform init
```

**2. Planificar (Dry-Run)**
Revisa qué es exactamente lo que Terraform va a crear en tu cuenta.
```bash
terraform plan
```

**3. Aplicar**
Crea la infraestructura real. Te pedirá confirmación escribiendo `yes`.
```bash
terraform apply
```

## 🔌 Conexión y Siguientes Pasos

Una vez que Terraform termine (tarda un par de minutos), te devolverá la IP pública de tu nueva máquina en la terminal gracias al archivo `outputs.tf`.

1. **Entrar al servidor:**
   ```bash
   ssh ubuntu@<IP_PUBLICA_MOSTRADA>
   ```
2. **Verificar Kubernetes:**
   ```bash
   kubectl get nodes
   kubectl get pods -n argocd
   ```
3. **Conectar el equipo:**
   Una vez que ArgoCD esté corriendo, ingresa a su interfaz web y conecta el repositorio para que comience el despliegue automático.