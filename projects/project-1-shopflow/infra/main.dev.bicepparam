using '../main.bicep'

// ShopFlow — DEV environment parameters
param environment = 'dev'
param location = 'centralindia'
param sqlAdminLogin = 'sqladmin'
param sqlAdminPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD')
