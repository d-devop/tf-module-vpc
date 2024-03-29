resource "aws_route" "route_to_app_vpc_in_default_vpc" {
  route_table_id            = var.default_vpc_route_table
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

### Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}_public"
  }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}_app"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}_db"
  }
}

resource "aws_route_table_association" "public_route_table_to_public_subnets" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app_route_table_to_private_subnets" {
  count          = length(aws_subnet.app_subnets)
  subnet_id      = element(aws_subnet.app_subnets.*.id, count.index)
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db_route_table_to_private_subnets" {
  count          = length(aws_subnet.db_subnets)
  subnet_id      = element(aws_subnet.db_subnets.*.id, count.index)
  route_table_id = aws_route_table.db.id
}

resource "aws_route" "internet_route_in_public_route_table" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route" "internet_route_in_app_route_table" {
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route" "internet_route_in_db_route_table" {
  route_table_id         = aws_route_table.db.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route" "route_to_default_vpc_in_public_subnet" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "route_to_default_vpc_in_app_subnet" {
  route_table_id            = aws_route_table.app.id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
