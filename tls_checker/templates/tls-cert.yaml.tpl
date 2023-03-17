namespace: '${namespace}'

image:
  repository: '${image_name}'
  tag: '${image_tag}'

ingress:
  create: false

service:
  create: false

resources:
  requests:
    memory: '96Mi'
    cpu: '10m'
  limits:
    memory: '128Mi'
    cpu: '50m'

envConfig:
  WEBSITE_SITE_NAME: '${website_site_name}'
  FUNCTION_WORKER_RUNTIME: 'dotnet'
  TIME_TRIGGER: '${time_trigger}'
  FunctionName: '${function_name}'
  Region: '${region}'
  ExpirationDeltaInDays: '${expiration_delta_in_days}'
  Host: 'https://${host}'
  AzureWebJobsStorage: "UseDevelopmentStorage=true"
  APPINSIGHTS_INSTRUMENTATIONKEY: '${appinsights_instrumentationkey}'

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
