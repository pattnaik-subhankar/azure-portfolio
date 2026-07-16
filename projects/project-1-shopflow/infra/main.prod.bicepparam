using '../main.bicep'

// ShopFlow — PROD environment parameters
param environment = 'prod'
param location = 'centralindia'
param sqlAdminLogin = 'sqladmin'
param sqlAdminPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD_PROD')
