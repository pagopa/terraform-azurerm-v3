namespace: ${NAMESPACE}
nameOverride: ""
fullnameOverride: ""

deployment:
create: true

kvCertificatesName:
- ${CERTIFICATE_NAME}

keyvault:
  name: ${KEY_VAULT_NAME}
  tenantId: ${TENANT_ID}
