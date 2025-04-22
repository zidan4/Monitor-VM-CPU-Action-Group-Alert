provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-monitor"
  location = "East US"
}

# Assume you already have a VM; reference it here:
data "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-backup"
  resource_group_name = azurerm_resource_group.rg.name
}

# 1️⃣ Action Group (email)
resource "azurerm_monitor_action_group" "email_ag" {
  name                = "cpu-alert-ag"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "cpuAG"

  email_receiver {
    name          = "AlertReceiver"
    email_address = "your-email@example.com"
  }
}

# 2️⃣ Metric Alert
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "high-cpu-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [data.azurerm_linux_virtual_machine.vm.id]
  description         = "Alert when CPU > 70%"
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_ag.id
  }
}
