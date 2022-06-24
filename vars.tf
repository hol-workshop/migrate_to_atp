variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}

################################ Quotas
variable "source_pgsql_compute_shape" {
  default = "VM.Standard.E4.Flex"
}
variable "source_pgsql_compute_ocpus" {
  default = 1
}
variable "source_pgsql_memory_in_gbs" {
  default = 1
}
variable "ogg_pgsql_compute_shape" {
  default = "VM.Standard2.1"
}
variable "ogg_micro_compute_shape" {
  default = "VM.Standard2.1"
}
################################ VCN

variable "holvcn_display_name" {
  default = "HOLVCN"
}
variable "holvcn_dns_label" {
  default = "holvcn"
}
variable "holvcn_public_subnet_display_name" {
  default = "HOLVCN_Public_Subnet"
}
variable "holvcn_public_security_list_display_name" {
  default = "HOLVCN_Public_SL"
}
variable "holvcn_public_dns_label" {
  default = "holvcnpublc"
}
variable "holvcn_public_route_table_display_name" {
  default = "HOLVCN_Public_RT"
}
variable "holvcn_private_subnet_display_name" {
  default = "HOLVCN_Private_subnet"
}
variable "holvcn_private_security_list_display_name" {
  default = "HOLVCN_Private_SL"
}
variable "holvcn_private_dns_label" {
  default = "holvcnprivate"
}
variable "holvcn_private_route_table_display_name" {
  default = "HOLVCN_Private_RT"
}
variable "holvcn_igw_display_name" {
  default = "HOLVCN_IGW"
}
variable "holvcn_nat_display_name" {
  default = "HOLVCN_IGW"
}
variable "holvcn_cidr_block" {
  default = "10.10.0.0/16"
}
variable "holvcn_public_cidr_block" {
  default = "10.10.0.0/24"
}
variable "holvcn_private_cidr_block" {
  default = "10.10.1.0/24"
}
variable "holvcn_igw_cidr_block" {
  default = "0.0.0.0/0"
}
variable "holvcn_nat_cidr_block" {
  default = "0.0.0.0/0"
}

################################ TARGET ATP
variable "atp_display_name" {
  default = "HOL Target ATP"
}
variable "atp_db_name" {
  default = "hol"
}
variable "atp_db_version" {
  default = "19c"
}
variable "atp_license_model" {
  default = "LICENSE_INCLUDED"
}
## FREE TIER
variable "atp_is_free_tier" {
  default = false
}
variable "atp_ocpu_count" {
  default = 1
}
variable "atp_storage_size" {
  default = 1
}
variable "atp_visibility" {
  default = "Public"
}
variable "atp_wallet_generate_type" {
  default = "SINGLE"
}
variable "atp_workload" {
  default = "OLTP"
}
variable "database_id" {
  default = ""
}

################################ SOURCE PGSQL
variable "source_pgsql_assign_public_ip" {
  default = true
}
variable "source_pgsql_boot_size_in_gbs" {
  default = "50"
}
variable "source_pgsql_hostname_label" {
  default = "sourcedb"
}
variable "source_pgsql_custom_volume_sizes" {
  default = false
}
variable "source_pgsql_display_name" {
  default = "HOL Source PGSQL"
}
variable "source_postgre_image_ocid" {
  type = map(string)

  default = {
        af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaal6e5oq4wqj22nc2q2cgrxddaj4vppml4npnc7lw4djxvvhaxpjuq"
        ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaarqlrgpd7zvvsfpdtdadlqe3qkw5dk5pwkn6dgnbmv72a7soso37a"
        ap-hyderabad-1 = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaakmppkw5brxoavkdzsrsyrnxzif4i6tjeezrlha7qkg6figroejwa"
        ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaaoq6mjbufhxulayjshcamjjtn6qefq3hgo7zvgkkguiqvr2pe7jea"
        ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaxwzgwul3ypt5h2lnawqxnzdyyht6mualqjaaflargmsovcmh7esq"
        ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa4lucxlnba6vpf76reg2x6gfxc7pttromfervverqp3r5ymjz2icq"
        ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaa76zdukvtdztsfsjdyxgvktlpycas4jophzvtgkcivslzlhqqerfq"
        ap-singapore-1 = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaebp4i47o4i6w7gddfunwoyvzn7bn5nwstfpolbqbychutjmmvazq"
        ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaa54sw74nj4wnkhwv3mbmetmy6ir72gfk3p3son4iw4qfwqvmwhwba"
        ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaifg3oyglbeldfl53e3jixdecuhgobpy467mbrf2qhgic7qryrk2q"
        ca-montreal-1 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaane6dibtqgnofquogxdq2dhi2uz6hpokou4xdorigjkifup6a5ejq"
        ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaahetquleq6y5fx6qzqp6sl4skkr3jdr5xo5khylsxwmuidxc5vvsq"
        eu-amsterdam-1 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaaloxx3bsjmuagx5qdcv52v5kuhksm5akfxk7k6mrqvqb7z4efqdnq"
        eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaahwtpw63fcu6jmiyjxywh2lg7wto5wpcbsu4kvfxaxfuxrqj7ciqa"
        eu-marseille-1 = "ocid1.image.oc1.eu-marseille-1.aaaaaaaakyvgyazjpbqtoi4cxzhbn2ayracxraz3lsz6e3e64tbumtskg75q"
        eu-milan-1 = "ocid1.image.oc1.eu-milan-1.aaaaaaaav5mbqkil4uncqpz5rsmzjsqvcgh3rucp5ivxwe4ehkpl4v7wffbq"
        eu-paris-1 = "ocid1.image.oc1.eu-paris-1.aaaaaaaahyrm4v6rjdj44bfg65zay4jpqubyg3j44sjpx3htxmmh74qim74q"
        eu-stockholm-1 = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaakkk5dbg5qd2jfuf4u3u7xe22eh5qdvjbjhrtf2kbjd4kd4nyeiqa"
        eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaiwcif2p5fd2zftoi63qoegxnozlzfsxcblcn4kwoqariebn7hgma"
        il-jerusalem-1 = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaacjkp7tam2kbpzzrsmnabrr6v5qbo6tthr67akmeyz6r5j44s5qna"
        me-abudhabi-1 = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaa3ke4wr6r52powmnj5zqxaqtrp3yltvu6e35bqp2qcpso4niqerya"
        me-dubai-1 = "ocid1.image.oc1.me-dubai-1.aaaaaaaaouw25brqutwut5nv62him5mqspkz6rujs7wnc5bbyb4kd7ijex7q"
        me-jeddah-1 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaavhea54os4bdmpg3vifjfkrcddzzpn7vzydobavwmhqopgsrvjxga"
        sa-santiago-1 = "ocid1.image.oc1.sa-santiago-1.aaaaaaaayeok6g4zxstqt6fkra2oluxhdahsp6izc7bwwutq7rdxpjr75gia"
        sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaace6cnnq5234mjocfi2wcd6sptqgdw76wk4jiusmo47xi36ghvbqq"
        sa-vinhedo-1 = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaanlzt62pzzcl54f3zyhlr3odtqohempfyg27rtt75zqqecppr6g3a"
        uk-cardiff-1 = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaa2zu5tj5x6qjkpvi6zqyjjckjicd4rn7b7lzqecbqwcxqlwv7avea"
        uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaagcgnqdfrbpc7r4upct3peh6c4uyvo746u6oz5g2dtnlunjzsdx4a"
        us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaawyrwqisciarak2rkykdwbv5u6xsj5bv3nc6nsahk3etad3znz6ea"
        us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaawr44ywh6wjc2lfshhdqxjrbxycfgog65a4435iswyka7bubfx37a"
        us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaaqasl5uvt7syyvv7uzj4j4axcyazcbthdxz6gkrznbpjcns6ojpq"
 }
}

################################ OGG POSTGRESQL BLOCK VOLUME
//
variable "ogg_pgsql_bv_display_name" {
  default = "OGG_PGSQL BlockVolume"
}
variable "boot_size_in_gbs" {
  default = "50"
}
variable "ogg_pgsql_swap_size_in_gbs" {
  default = "50" //256
}
variable "ogg_pgsql_trails_size_in_gbs" {
  default = "50" //512
}
variable "ogg_pgsql_deployments_size_in_gbs" {
  default = "50"
}

// OGG Deployment volume
variable "ogg_pgsql_deployments_volume_id" {
  default = ""
}

// OGG Trails volume
variable "ogg_pgsql_trails_volume_id" {
  default = ""
}
################################ OGG MICRO BLOCK VOLUME
//
variable "ogg_micro_bv_display_name" {
  default = "OGG_Micro BlockVolume"
}

variable "ogg_micro_swap_size_in_gbs" {
  default = "50"  //256
}
variable "ogg_micro_trails_size_in_gbs" {
  default = "50"  //512
}
variable "ogg_micro_deployments_size_in_gbs" {
  default = "50"
}
variable "ogg_micro_cacheManager_size_in_gbs" {
  default = "50"
}
// OGG Deployment volume
variable "ogg_micro_deployments_volume_id" {
  default = ""
}
// OGG CacheManager volume
variable "ogg_micro_cacheManager_volume_id" {
  default = ""
}
// OGG Trails volume
variable "ogg_micro_trails_volume_id" {
  default = ""
}
################################ OGG PGSQL IMAGE
variable "ogg_pgsql_dbms" {
  default = "postgresql"
}
variable "ogg_pgsql_edition" {
  default = "Classic"
}
variable "ogg_pgsql_version" {
  default = "19.1.0.0.201013"
}
variable "image_compartment_id" {
  default = ""
}
################################ OGG PGSQL INSTANCE
variable "ogg_pgsql_assign_public_ip" {
  default = true
}
variable "ogg_pgsql_boot_size_in_gbs" {
  default = "50"
}
variable "ogg_pgsql_display_name" {
  default = "HOL OGG PGSQL"
}
variable "ogg_pgsql_hostname_label" {
  default = "ogg19cpgsql"
}
variable "ogg_pgsql_custom_volume_sizes" {
  default = false
}
################################ OGG Micro IMAGE
variable "ogg_micro_dbms" {
  default = "Oracle"
}
variable "ogg_micro_edition" {
  default = "Microservices"
}
variable "ogg_micro_version" {
  default = "19.1.0.0.201013"
}
################################ OGG MICRO INSTANCE
variable "ogg_micro_assign_public_ip" {
  default = true
}
variable "ogg_micro_boot_size_in_gbs" {
  default = "50"
}
variable "ogg_micro_display_name" {
  default = "HOL OGG Microservices"
}
variable "ogg_micro_hostname_label" {
  default = "ogg19micro"
}
variable "ogg_micro_custom_volume_sizes" {
  default = false
}
################################ OGG MICRO GG CONFIGURATION

variable deployments_json {
  default = ""
}

variable deployment_1_name {
  default = "Source"
}

variable deployment_1_dbms {
  default = "Oracle 11g (11.2.0.4)"
}
variable deployment_1_adb {
  default = false
}
variable deployment_1_adb_id {
  default = ""
}
variable deployment_1_adb_compartment_id {
  default = ""
}

variable deployment_2_name {
  default = "Target"
}

variable deployment_2_dbms {
  default = "Oracle 19c (19.x)"
}

variable deployment_2_adb {
  default = true
}

variable deployment_2_adb_compartment_id {
  default = ""
}

variable deployment_2_adb_id {
  default = ""
}
