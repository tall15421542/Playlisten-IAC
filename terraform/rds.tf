resource "aws_security_group" "playlisten_rds_instance" {
  name   = "playlisten_rds_instance"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "allow MySQL connection"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "playlisten_rds_instance"
  }
}

data "aws_db_snapshot" "latest_prod_snapshot" {
  db_instance_identifier = var.rds_identifier 
  most_recent = true
  include_shared = true
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.rds_identifier

  engine = "mysql"
  engine_version = "5.7.33"
  family = "mysql5.7"
  instance_class = "db.t3.micro"
  allocated_storage = 20

  name     = "playlisten-sql"
  username = "admin"
  password = var.db_pass
  port     = "3306"

  subnet_ids = module.vpc.database_subnets
  vpc_security_group_ids = [aws_security_group.playlisten_rds_instance.id]
  db_subnet_group_name = module.vpc.database_subnet_group_name

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  create_db_option_group = false
  create_db_parameter_group = false
  create_db_subnet_group = false

  snapshot_identifier = data.aws_db_snapshot.latest_prod_snapshot.id
  skip_final_snapshot = "false"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}
