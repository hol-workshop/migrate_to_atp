// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.

output "wallet" {
  value = "${var.fetch_wallet ? join(",", data.oci_database_autonomous_database_wallet.wallet.*.content) : ""}"
}
