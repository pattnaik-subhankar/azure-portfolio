/*
  ShopFlow — Service Bus Bicep Module
  Standard tier namespace, orders-inbound queue, order-events topic with subscriptions.
*/
param location string
param environment string
param namespaceName string = 'sb-shopflow-${environment}-${uniqueString(resourceGroup().id)}'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: namespaceName
  location: location
  sku: { name: 'Standard', tier: 'Standard' }
  properties: {
    zoneRedundant: true
  }
}

resource ordersQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: 'orders-inbound'
  properties: {
    defaultMessageTimeToLive: 'P7D'
    maxDeliveryCount: 10
    lockDuration: 'PT1M'
    deadLetteringOnMessageExpiration: true
    maxSizeInMegabytes: 1024
    enablePartitioning: true
  }
}

resource orderEventsTopic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: 'order-events'
  properties: {
    defaultMessageTimeToLive: 'P7D'
    enablePartitioning: true
  }
}

// Topic subscriptions
resource subFulfillment 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
  parent: orderEventsTopic
  name: 'fulfillment-status'
  properties: { maxDeliveryCount: 10 }
}

resource subNotification 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
  parent: orderEventsTopic
  name: 'notification-out'
  properties: { maxDeliveryCount: 20 }
}

resource subAudit 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
  parent: orderEventsTopic
  name: 'audit'
  properties: { maxDeliveryCount: 10 }
}

// RBAC data-plane roles for managed identity access
// Service Bus Data Owner on namespace — assigned via pipeline to Function identities
output namespaceName string = serviceBusNamespace.name
output namespaceId string = serviceBusNamespace.id
output queueName string = ordersQueue.name
output topicName string = orderEventsTopic.name
