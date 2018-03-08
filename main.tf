# Configure the Microsoft Azure Provider
provider "azurerm" {
	subscription_id = "${var.Subscription_ID}"
	tenant_id       = "${var.Tenant_ID}"
}
