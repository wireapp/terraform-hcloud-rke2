terraform {
  required_providers {
    rancher2 = {
      # PR for rke2_config https://github.com/rancher/terraform-provider-rancher2/pull/626/files
      # Not using yet as it seems to be supporting only a handful of configuration options https://github.com/rancher/terraform-provider-rancher2/pull/626/files#diff-ea87985827a5e33692d9699416d9144971b191e9688a542125e8f31b5133adbdR1034-R1050
      # source  = "git@github.com:rawmind0/terraform-provider-rancher2.git?ref=rke2"
      source  = "rancher/rancher2"
      version = "1.13.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.26.0"
    }
  }
}