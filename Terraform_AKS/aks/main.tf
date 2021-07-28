provider "azurerm" {
    subscription_id = "XXXX"
    client_id       = "XXXX"
    client_secret   = "XXXX"
    tenant_id       = "XXXX"
    features{}
}


resource "azurerm_kubernetes_cluster" "k8sPoc" {
  name                = "mytestaks-k8s-Poc"
  location            = "East US"
  resource_group_name = "example"
  kubernetes_version  = "1.16.13"
  dns_prefix          = "mytestaks-k8s-Poc"

 
  default_node_pool {
        name            = "agentpool"
        node_count      = 3
        vm_size         = "Standard_D2s_v3"
    }
    
  service_principal {
    client_id       = "XXXX"
    client_secret   = "XXXX"
  } 
    
  tags = {
    Environment = "Terraform Demo"
  }
}
