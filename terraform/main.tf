# Terraform configuration block specifying required providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.51.0"  # Azure provider version
    }
  }
}

# Configure the Azure provider with auto subscription detection
provider "azurerm" {
  features {}  # Enable features for Azure resources

  #DONT FORGET TO ADD YOUR SUBS ID!!!!!!
  subscription_id = ""
  #DONT FORGET TO ADD YOUR SUBS ID!!!!!!
  
}

# Use data source to get current subscription information
data "azurerm_client_config" "current" {
  # This automatically gets the current Azure context
  # No configuration needed - uses your az login credentials
}

# Create a resource group to organize all related resources
resource "azurerm_resource_group" "rg" {
  name     = "voting-app-rg"  # Name of the resource group
  location = "Southeast Asia" # Azure region where resources will be created
}

# Create a virtual network for the AKS cluster
resource "azurerm_virtual_network" "vnet" {
  name                = "voting-app-vnet"  # Virtual network name
  address_space       = ["10.0.0.0/12"]    # IP address range for the VNET
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet within the virtual network for AKS nodes
resource "azurerm_subnet" "subnet" {
  name                 = "voting-app-subnet"  # Subnet name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]      # IP range for this subnet
}

# Create an Azure Kubernetes Service (AKS) cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "voting-app-aks"  # AKS cluster name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "votingapp"       # DNS prefix for API server

  # Default node pool configuration
  default_node_pool {
    name                = "default"              # Node pool name
    node_count          = 1                      # Initial number of nodes
    vm_size             = "Standard_D2s_v3"      # VM size for nodes
    vnet_subnet_id      = azurerm_subnet.subnet.id  # Attach to our subnet
    min_count           = 1                      # Minimum nodes for auto-scaling
    max_count           = 3                      # Maximum nodes for auto-scaling
    zones               = ["2", "3"]             # Availability zones for high availability (each location maybe different)
    auto_scaling_enabled = true                   # Enable cluster auto-scaling
  }

  # Use system-assigned managed identity for AKS
  identity {
    type = "SystemAssigned"  # Azure manages the identity automatically
  }

  # Network configuration for the AKS cluster
  network_profile {
    network_plugin    = "kubenet"    # Network plugin (simpler than Azure CNI)
    load_balancer_sku = "standard"   # Load balancer type
    service_cidr      = "10.1.0.0/16"  # IP range for Kubernetes services
    dns_service_ip    = "10.1.0.10"    # DNS service IP within service CIDR
    pod_cidr          = "10.2.0.0/16"  # IP range for Kubernetes pods
  }
}

# Output the current subscription ID (for verification)
output "current_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
  description = "The subscription ID being used (from az login)"
}

# Output the current tenant ID (for verification)
output "current_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
  description = "The tenant ID being used (from az login)"
}

# Output the kubeconfig to access the cluster
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true  # Mark as sensitive to avoid showing in logs
}

# Output the cluster name for reference
output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

# Output the resource group name for reference
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}