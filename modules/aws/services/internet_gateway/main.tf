

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"
  tags   = merge(var.tags, var.common_tags,)
}
