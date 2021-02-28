// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.

resource "random_string" "password" {
  count            = var.fetch_wallet ? 1 : 0
  length           = 16
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "-%._"
}

data "oci_database_autonomous_database_wallet" "wallet" {
  count                  = var.fetch_wallet ? 1 : 0
  autonomous_database_id = var.autonomous_database_id
  password               = random_string.password.0.result
  generate_type          = "SINGLE"
  base64_encode_content  = true
}
