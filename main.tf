resource "aws_security_group" "sg" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  # access these for only app subnets
  ingress {
    description = "docdb"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allow_db_cidr
  }

  # outside access
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sg" })
}

resource "aws_docdb_subnet_group" "subnet_group" {
  name       = "${var.name}-${var.env}"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name}-${var.env}" })

}

resource "aws_docdb_cluster_parameter_group" "param-group" {
  family      = "docdb4.0"
  name        = "${var.name}-${var.env}"
  description = "docdb cluster parameter group"

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-param-group" })

}

resource "aws_docdb_cluster" "docdb-cluster" {
  cluster_identifier              = "${var.name}-${var.env}"
  engine                          = "docdb"
  master_username                 = data.aws_ssm_parameter.db_user.value
  master_password                 = data.aws_ssm_parameter.db_password.value
  backup_retention_period         = 5
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  db_subnet_group_name            = aws_docdb_subnet_group.subnet_group.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.param-group.name
  engine_version                  = var.engine_version
  port                            = var.port
  vpc_security_group_ids          = [aws_security_group.sg.id]

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-cluster" })
}
