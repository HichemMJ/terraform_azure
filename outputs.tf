
output "public_ip_loadbalancer" {
  #value = azurerm_public_ip.lb_pubip.id
  value = azurerm_public_ip.lb-pubip.id
  description = "The private IP address of the newly created Azure VM"
}
