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

resources:
  # -- request is mandatory
  requests:
    # -- memory
    memory: "${POD_RAM}Mi"
    # -- cpu
    cpu: "${POD_CPU}m"
  # -- limits is mandatory
  limits:
    # -- memory
    memory: "${POD_RAM}Mi"
    # -- cpu
    cpu: "${POD_CPU}m"

azure:
  workloadIdentityClientId: ${WORKLOAD_IDENTITY_CLIENT_ID}
