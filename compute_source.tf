resource oci_core_instance source_postgresql {
	availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
	compartment_id      = var.compartment_ocid
	display_name = var.source_postgre_display_name
	shape 		 = var.source_postgre_shape
	create_vnic_details {
		assign_public_ip = "true"
		display_name = "postgre_vnic"
		subnet_id    = oci_core_subnet.holvcn_public_subnet.id
	}
	source_details {
        source_id   = var.source_postgre_image_ocid[var.region]
		source_type = "image"
	}
	metadata = {
		ssh_authorized_keys = file("~/.ssh/oci.pub")
		user_data = data.template_cloudinit_config.source_postgre_cloud_init.rendered
	}
}
