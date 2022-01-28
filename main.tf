# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  required_version = ">= 0.14.9"


  backend "remote" {
    organization = "jcetina"

    workspaces {
      name = "gh_jcetina_policy_testing"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  storage_accounts = {
    audit_log_storage = {
      name                     = "jcetinapoltestast"
      account_tier             = "Standard"
      access_tier              = "Cool"
      account_replication_type = "LRS"
    }
    func_app_storage = {
      name                     = "jcetinapoltestbst"
      account_tier             = "Standard"
      access_tier              = "Cool"
      account_replication_type = "LRS"
    }
  }
}
data "azurerm_resource_group" "rg" {
  name = "rg-gh-jcetina-policy-testing"
}

resource "azurerm_storage_account" "storage_accounts" {
  for_each = local.storage_accounts

  name                      = each.value.name
  resource_group_name       = data.azurerm_resource_group.rg.name
  location                  = data.azurerm_resource_group.rg.location
  account_tier              = each.value.account_tier
  access_tier               = each.value.access_tier
  account_replication_type  = each.value.account_replication_type
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}
