
### Creacion de VPC en terraform

---

#### 1. **backend.tf**

**Propósito:**  
Este archivo configura el backend de Terraform, que es el lugar donde se almacena el estado de Terraform (`tfstate`). En este caso, se utiliza un bucket de Amazon S3 para almacenar de manera segura y compartida el estado de la infraestructura.

**Ejemplo de contenido:**
```hcl
terraform {
  backend "s3" {
    bucket         = "nombre-del-bucket"
    key            = "ruta/al/tfstate/archivo.tfstate"
    region         = "us-west-2"
    dynamodb_table = "nombre-de-la-tabla-dynamodb"  # Opcional: Para bloqueo de estado
    encrypt        = true
  }
}
```

**Explicación:**  
- `bucket`: Nombre del bucket S3 donde se almacenará el archivo de estado.
- `key`: Ruta dentro del bucket para el archivo de estado.
- `region`: Región de AWS donde se encuentra el bucket.
- `dynamodb_table`: (Opcional) Nombre de la tabla DynamoDB utilizada para el bloqueo de estado.
- `encrypt`: Activa la encriptación del archivo de estado.

---

#### 2. **main.tf**

**Propósito:**  
Este archivo contiene la definición de los recursos principales de la infraestructura. En el contexto de AWS, puede incluir la creación de una VPC, subnets, gateways, entre otros recursos necesarios.

**Ejemplo de contenido:**
```hcl
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

# Otros recursos pueden definirse aquí
```

**Explicación:**  
- `aws_vpc`: Crea una VPC con el bloque CIDR especificado.
- `aws_subnet`: Crea una subnet dentro de la VPC creada, especificando la zona de disponibilidad.

---

#### 3. **provider.tf**

**Propósito:**  
Define el proveedor y la configuración de la cuenta AWS, incluyendo la región donde se despliega la infraestructura.

**Ejemplo de contenido:**
```hcl
provider "aws" {
  region  = "us-west-2"
  profile = "default"  # Opcional: Perfil de AWS a utilizar
}
```

**Explicación:**  
- `region`: Define la región de AWS donde se desplegarán los recursos.
- `profile`: (Opcional) Especifica un perfil de AWS configurado en tu máquina local.

---

#### 4. **outputs.tf**

**Propósito:**  
Este archivo define las salidas que se mostrarán al final de la ejecución de Terraform. Las salidas son generalmente valores que son importantes para otros módulos o para los usuarios, como IDs de recursos, direcciones IP, entre otros.

**Ejemplo de contenido:**
```hcl
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.subnet_a.id
}
```

**Explicación:**  
- `vpc_id`: Muestra el ID de la VPC creada.
- `subnet_ids`: Muestra el ID de la subnet creada.

---

#### 5. **variables.tf**

**Propósito:**  
Este archivo se utiliza para declarar las variables que se utilizarán en la configuración de Terraform. Permite definir valores que pueden cambiar según el entorno sin necesidad de modificar el código.

**Ejemplo de contenido:**
```hcl
variable "region" {
  description = "La región de AWS en la que se desplegará la infraestructura"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "El bloque CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

**Explicación:**  
- `region`: Variable que define la región de AWS. Puede ser sobrescrita en `terraform.tfvars`.
- `vpc_cidr`: Define el bloque CIDR para la VPC.

---

#### 6. **terraform.tfvars**

**Propósito:**  
Este archivo contiene los valores concretos para las variables definidas en `variables.tf`. Es donde se especifican los valores reales que se aplicarán durante la ejecución de Terraform.

**Ejemplo de contenido:**
```hcl
region   = "us-west-2"
vpc_cidr = "10.0.0.0/16"
```

**Explicación:**  
Este archivo permite configurar valores sin modificar los archivos de configuración principal (`.tf`). Es especialmente útil para manejar configuraciones para diferentes entornos (desarrollo, producción, etc.).

