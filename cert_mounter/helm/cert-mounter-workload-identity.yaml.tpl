namespace: ${NAMESPACE}

deployment:
  create: true

kvCertificatesName:
  - ${CERTIFICATE_NAME}

keyvault:
  name: ${KEY_VAULT_NAME}
  tenantId: ${TENANT_ID}

serviceAccount:
  name: ${SERVICE_ACCOUNT_NAME}

azure:
  workloadIdentityClientId: ${WORKLOAD_IDENTITY_CLIENT_ID}
