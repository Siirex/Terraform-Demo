
/*
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}
*/

resource "aws_key_pair" "public-key" {
  key_name = "terraform-public-key-${var.owner}"
  # public_key = tls_private_key.tls_key.public_key_openssh
  public_key = "${file("key-access-instances.pub")}"

  tags = {
    Name = "terraform-public-key-${var.owner}"
  }
}
