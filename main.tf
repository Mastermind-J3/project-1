resource "azuread_user" "user-me" {
  user_principal_name = "jatin@hashicorp.com"
  display_name        = "Jatin J."
  mail_nickname       = "jjatin"
  password            = "SecretP@sswd99!"
}

resource "azuread_user" "user-prof" {
  user_principal_name   = "Oibrahim@hashicorp.com"
  display_name          = "Ibrahim O. "
  mail_nickname         = "Oibrahim"
  password              = "SecretP@sswd99!"
  force_password_change = true
}

resource "aws_iam_user" "classmate_users" {
  for_each = toset(var.users)
  name     = each.value

  tags = {
    Description = "classmate-user"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket = "my-terraform-aws-bucket-${count.index}"
  count  = var.num_of_buckets
}

resource "azurerm_resource_group" "resource-grp" {
  name     = "azure-terraform-exam"
  location = "East US"
}


resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource-grp.location
  resource_group_name = azurerm_resource_group.resource-grp.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.resource-grp.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  #depends_on = [azurerm_virtual_network.main]

}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.resource-grp.location
  resource_group_name = azurerm_resource_group.resource-grp.name
  #depends_on = [azurerm_subnet.internal]

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.resource-grp.location
  resource_group_name   = azurerm_resource_group.resource-grp.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"
  #depends_on = [azurerm_virtual_network.main]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    Owner       = "Jatin"
    environment = "staging"
  }
}

resource "azurerm_storage_account" "storage-account" {
  name                     = "myexamstorageaccount"
  resource_group_name      = azurerm_resource_group.resource-grp.name
  location                 = azurerm_resource_group.resource-grp.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Owner       = "Jatin"
    environment = "staging"
  }
}

