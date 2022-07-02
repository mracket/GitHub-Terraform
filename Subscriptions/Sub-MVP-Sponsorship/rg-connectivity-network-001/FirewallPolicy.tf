resource "azurerm_firewall_policy_rule_collection_group" "FirewallAVDRuleCollection" {
  name               = "example-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.FirewallPolicy.id
  priority           = 500
  application_rule_collection {
    name     = "rc_avd_webbrowsing"
    priority = 1000
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
    priority = 5000
    action   = "allow"
    rule {
      name                  = "rule-avd-to-onpremises"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["172.17.0.0/16"]
      destination_addresses = ["192.168.1.0/24", "192.168.10.0/24"]
    }
  } 
}