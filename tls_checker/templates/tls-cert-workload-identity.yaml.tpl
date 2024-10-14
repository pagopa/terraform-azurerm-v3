namespace: '${namespace}'

image:
  repository: '${image_name}'
  tag: '${image_tag}'

ingress:
  create: false

service:
  create: false

readinessProbe:
  httpGet:
    path: /
    port: 8080
  initialDelaySeconds: 30
  failureThreshold: 7
  periodSeconds: 10
  timeoutSeconds: 1
  successThreshold: 1

livenessProbe:
  httpGet:
    path: /
    port: 8080
  initialDelaySeconds: 30
  failureThreshold: 7
  periodSeconds: 10
  timeoutSeconds: 1
  successThreshold: 1
  terminationGracePeriodSeconds: 30

startupProbe:
  httpGet:
    path: /
    port: 8080
  initialDelaySeconds: 30
  failureThreshold: 7
  periodSeconds: 10
  timeoutSeconds: 10
  successThreshold: 1
  terminationGracePeriodSeconds: 30

resources:
  requests:
    memory: '128Mi'
    cpu: '70m'
  limits:
    memory: '128Mi'
    cpu: '70m'

envConfig:
  WEBSITE_SITE_NAME: '${website_site_name}'
  FUNCTION_WORKER_RUNTIME: 'dotnet'
  TIME_TRIGGER: '${time_trigger}'
  FunctionName: '${function_name}'
  Region: '${region}'
  ExpirationDeltaInDays: '${expiration_delta_in_days}'
  Host: 'https://${host}'
  AzureWebJobsStorage: "UseDevelopmentStorage=true"

# load the secret from keyvault
envSecret:
  APPINSIGHTS_INSTRUMENTATIONKEY: '${kv_secret_name_for_application_insights_connection_string}'

keyvault:
  name: '${keyvault_name}'
  tenantId: '${keyvault_tenant_id}'

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: node_type
              operator: In
              values:
                - user

sidecars:
  - name: azurite
    securityContext:
      allowPrivilegeEscalation: false
    image: mcr.microsoft.com/azure-storage/azurite:3.18.0@sha256:fbd99a4aa4259827081ff9e5cd133a531f20fa2d1d010891fd474d5798f15d7a
    ports:
      - containerPort: 10000
    resources:
      limits:
        memory: 100Mi
        cpu: 20m

### Workload Identity

serviceAccount:
  name: ${SERVICE_ACCOUNT_NAME}

azure:
  workloadIdentityClientId: ${WORKLOAD_IDENTITY_CLIENT_ID}

