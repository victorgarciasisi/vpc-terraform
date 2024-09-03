
# Crear la VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}

# Crear subredes privadas
resource "aws_subnet" "private" {
  count = length(var.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 3, count.index)
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-${var.azs[count.index]}"
  }
}

# Crear subredes públicas
resource "aws_subnet" "public" {
  count = length(var.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 3, count.index + length(var.azs) + 1)
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${var.azs[count.index]}"
  }
}


# Crear el Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    #Name = "${var.vpc_name}-igw"
    Name = "${var.vpc_name}" 
  }
}

# Crear tabla de enrutamiento privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private"
  }
}

# Asociar subredes privadas con la tabla de enrutamiento privada
resource "aws_route_table_association" "private" {
  count = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Añadir ruta a la tabla de enrutamiento privada para el NAT Gateway
resource "aws_route" "private_nat" {
  count = length(var.azs)

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.gw[0].id : aws_nat_gateway.gw[count.index].id
}

# Crear tabla de enrutamiento pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.vpc_name}-public"
  }
}

# Asociar subredes públicas con la tabla de enrutamiento pública
resource "aws_route_table_association" "public" {
  count = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Crear NAT Gateway para subredes privadas
resource "aws_nat_gateway" "gw" {
  count = var.single_nat_gateway ? 1 : length(var.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  tags = {
    Name = "${var.vpc_name}-nat-gateway-${var.aws_region}a"
    #Name = "dev-nat-gateway-eu-west-1a"
  }
}

resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : length(var.azs)

  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-gateway-${var.aws_region}a"
    #Name = "dev-nat-gateway-eu-west-1a"
  }

  depends_on = [aws_internet_gateway.gw]
}

