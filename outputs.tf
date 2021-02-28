
output "Source_Postgre_Public_IP_address" {
	value = oci_core_instance.source_postgresql.public_ip
}
