output "production_vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_id_ap_northeast_2a_public" {
  value = aws_subnet.ap_northeast_2a_public.id
}

output "subnet_id_ap_northeast_2c_public" {
  value = aws_subnet.ap_northeast_2c_public.id
}

output "subnet_id_ap_northeast_2a_private" {
  value = aws_subnet.ap_northeast_2a_private.id
}

output "subnet_id_ap_northeast_2c_private" {
  value = aws_subnet.ap_northeast_2c_private.id
}
