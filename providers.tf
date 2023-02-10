terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.43.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  skip_provider_registration = true
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

