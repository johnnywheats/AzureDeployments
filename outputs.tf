output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${azurerm_network_interface.vm.*.private_ip_address}"
}
