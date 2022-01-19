variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}

################################ Quotas
variable "source_pgsql_compute_shape" {
  default = "VM.Standard.E2.1"
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
	ap-chuncheon-1 	= "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaazj2i3nddb6unlcc3qsykgcfvvfkivfufhry57wi3xourgy4xsloa"
	ap-hyderabad-1 	= "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaf6ve55piez3tebkhjm3bqh2ud3m55bujcty7jkmr6qlljonh556q"
	ap-melbourne-1 	= "ocid1.image.oc1.ap-melbourne-1.aaaaaaaaulahbkfipfww5upbrm5f4wrvn6a3fum46np6brv6wi3jfmrllryq"
	ap-mumbai-1 	= "ocid1.image.oc1.ap-mumbai-1.aaaaaaaapaignemz5qzpjuiqx3qvsqcj5db73ec4gakbkamwd6ntyaxrmrmq"
	ap-osaka-1 	= "ocid1.image.oc1.ap-osaka-1.aaaaaaaaoyplbp7i7ublp2udzydqjeyfieenejbkq4iqz2o6tbycsdk6xwda"
	ap-seoul-1 	= "ocid1.image.oc1.ap-seoul-1.aaaaaaaapqkj57pmhwsmm6medm37vg2jny4v73lw426qszfdzkq7wkzcqgaq"
	ap-singapore-1 	= "ocid1.image.oc1.ap-singapore-1.aaaaaaaa7vj5qidknfqkofg5esyh6wae2uurf2cohu7bspd6vxoy7kn7fapa"
	ap-sydney-1 	= "ocid1.image.oc1.ap-sydney-1.aaaaaaaaay5jf7yle5elp4k3opmxwxohhwta6wjmmnro5zglt5zarok7kvwa"
	ap-tokyo-1 	= "ocid1.image.oc1.ap-tokyo-1.aaaaaaaadeswedg2atub26mnfyu2wbqrjigremlvcf4neoluz4jumq3wawaq"
	ca-montreal-1 	= "ocid1.image.oc1.ca-montreal-1.aaaaaaaa57ojxb2gm6eedaoy5piguj4rwzfx6mhnbamjmv2754rz3vcl6vnq"
	ca-toronto-1 	= "ocid1.image.oc1.ca-toronto-1.aaaaaaaah4uzqezswz2cvemgnidg73bigdfpuljcdlsqirpepe4ekk6kcmba"
	eu-amsterdam-1 	= "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa4qxjmipq35drg5entn7qpenwrx6f4zbbyjqffvltb45uz42v5sda"
	eu-frankfurt-1 	= "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaalepl4teucgdomo6jbzgskc4r6fhrz7tp5twfosnqp47lk5v6qoa"
	eu-marseille-1 	= "ocid1.image.oc1.eu-marseille-1.aaaaaaaafrqr6mgcuka3ar5ilgh27dhyejx3mlbgcih5b6dustvullk6hzva"
	eu-zurich-1 	= "ocid1.image.oc1.eu-zurich-1.aaaaaaaarge5cqqk3rnnnmzi2qn3pampycrsvrnpxin7rg6nkslkupzqvv6a"
	il-jerusalem-1 	= "ocid1.image.oc1.il-jerusalem-1.aaaaaaaaghqna2tgejiy5akex6qq2pxdrp7kxjw62oscuvl7m5vghulbhiea"
	me-dubai-1 	= "ocid1.image.oc1.me-dubai-1.aaaaaaaavle63te4cazwuonqt7nf6dlffvewycojbnonjdzykpy4zz2zd6kq"
	me-jeddah-1 	= "ocid1.image.oc1.me-jeddah-1.aaaaaaaahbdcnsxqnr2a4he3ktapzy5kwpj32kau4qakbncvsfbaybqqvpxq"
	sa-santiago-1 	= "ocid1.image.oc1.sa-santiago-1.aaaaaaaas7w5iuhchzw6ynfj4r3zecxjeoxfzdwnrcrwb6tb3aeczqavvuua"
	sa-saopaulo-1 	= "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaargxb3xu3rmfavoakcfgmrvz6nc7s4b7luvuy3xyzin6nxb622vpa"
	sa-vinhedo-1 	= "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaavhzs4aetjn7rysstacpmzcbhnapjjwok7zy5f7kmtvhencndlhkq"
	uk-cardiff-1 	= "ocid1.image.oc1.uk-cardiff-1.aaaaaaaad25kve4ufflntl6nuh4tds2wvflekak3tlinng7w7ebzh3ysiu3a"
	uk-london-1 	= "ocid1.image.oc1.uk-london-1.aaaaaaaalu2sd65shsmeewhijd5bo4ut64sc5l3436lgoizanotrqbzawlwq"
	us-ashburn-1 	= "ocid1.image.oc1.iad.aaaaaaaasp5c733iphbi3cwbakd75nvk6pf6r7pgz4dsroz3pdrgcsfyk6lq"
	us-phoenix-1 	= "ocid1.image.oc1.phx.aaaaaaaazvmq762wkokwfxpec3iipkidzxrqxqv4bdmjszm4mkcno3nzzzga"
	us-sanjose-1 	= "ocid1.image.oc1.us-sanjose-1.aaaaaaaahdd7i2sp2yxu5skd72cefntfwizg7sop4bnzeziooavzmwyufynq"
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
