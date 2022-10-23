resource "aws_security_group" "cockroach" {
    vpc_id = data.aws_vpc.services.id
    name   =  "${var.resource_prefix}-CockroachSecurityGroup"

    tags = {
    Name       =  "${var.resource_prefix}-CockroachSecurityGroup"
    Deployment = var.resource_prefix
    }

    # HTTP
      ingress {
        from_port       = 8280
        protocol        = "tcp"
        to_port         = 8280
        cidr_blocks      = ["0.0.0.0/0"]
      }

      # SQL
      ingress {
        from_port       = 26257
        protocol        = "tcp"
        to_port         = 26257
        cidr_blocks      = ["0.0.0.0/0"]
      }

      ingress {
        from_port       = 8086
        protocol        = "tcp"
        to_port         = 8086
        cidr_blocks      = ["0.0.0.0/0"]
      }

       ingress {
        from_port       = 22
        protocol        = "tcp"
        to_port         = 22
        cidr_blocks      = ["0.0.0.0/0"]
      }

}