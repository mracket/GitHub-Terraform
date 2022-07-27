data "azurerm_firewall_policy" "AzureFirewallPolicy" {
    name = "afwp-connectivity-001"
    resource_group_name = azurerm_resource_group.resourcegroup.name

}

resource "azurerm_firewall_policy_rule_collection_group" "FirewallAVDRuleCollection" {
  name               = "rcg-avd"
  firewall_policy_id = data.azurerm_firewall_policy.AzureFirewallPolicy.id
  priority           = 2000
  application_rule_collection {
    name     = "rc_avd_webbrowsing"
    priority = 5000
    action   = "Allow"
    rule {
      name = "rule_avd_webbrowsing"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }      
      source_addresses  = ["172.17.0.0/16"]
      destination_fqdns = ["*"]
    }
  }

  network_rule_collection {
    name     = "rc_avd"
    priority = 2000
    action   = "Allow"
    rule {
      name                  = "rule-avd-to-onpremises"
      protocols             = ["TCP", "UDP","ICMP"]
      source_addresses      = ["172.17.0.0/16"]
      destination_addresses = ["192.168.1.0/24", "192.168.10.0/24"]
      destination_ports     = ["*"] 
    }
    rule {
      name                  = "rule-avd-to-storageaccount"
      protocols             = ["TCP"]
      source_addresses      = ["172.17.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["445"] 
    }
  }    
}
resource "azurerm_firewall_policy_rule_collection_group" "FirewallSharedServicesRuleCollection" {
  name               = "rcg-sharedservices"
  firewall_policy_id = data.azurerm_firewall_policy.AzureFirewallPolicy.id
  priority           = 1000
  application_rule_collection {
    name     = "rc_sharedservices_webbrowsing"
    priority = 5000
    action   = "Allow"
    rule {
      name = "rule_sharedservices_webbrowsing"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }      
      source_addresses  = ["172.18.0.0/16"]
      destination_fqdns = ["*"]
    }
  }

 network_rule_collection {
    name     = "rc_sharedservices"
    priority = 1000
    action   = "Allow"
    rule {
      name                  = "rule-avd-to-onpremises"
      protocols             = ["TCP", "UDP","ICMP"]
      source_addresses      = ["172.18.0.0/16"]
      destination_addresses = ["192.168.1.0/24", "192.168.10.0/24"]
      destination_ports     = ["*"] 
    }
    rule {
      name                  = "rule-sharedservice-to-storageaccount"
      protocols             = ["TCP"]
      source_addresses      = ["172.18.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["445"] 
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "FirewallOnPremisesRuleCollection" {
  name               = "rcg-onpremises"
  firewall_policy_id = data.azurerm_firewall_policy.AzureFirewallPolicy.id
  priority           = 1100
  
  network_rule_collection {
    name     = "rc_onpremises"
    priority = 1100
    action   = "Allow"
    rule {
      name                  = "rule-onpremises-to-avd"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = ["192.168.1.0/24", "192.168.10.0/24"]
      destination_addresses = ["172.17.0.0/16","172.18.0.0/16"]
      destination_ports     = ["*"] 
    }
  } 
}
