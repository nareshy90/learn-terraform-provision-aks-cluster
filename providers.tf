provider "hcp" {
  # Configuration options
  client_id = var.HCP_CLIENT_ID
  client_secret = var.HCP_CLIENT_SECRET
}

provider "azurerm" {
  features {}
}