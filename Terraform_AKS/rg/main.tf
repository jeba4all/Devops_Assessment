provider "azurerm" {
    subscription_id = "XXXX"
    client_id       = "XXXX"
    client_secret   = "XXXX"
    tenant_id       = "XXXX"
    features{}
}


resource "azurerm_resource_group" "my-testaks-k8s" {
  name     = "example"
  location = "Southeast Asia"
    
     tags = {
        environment = "Terraform Demo"
    }
  
}