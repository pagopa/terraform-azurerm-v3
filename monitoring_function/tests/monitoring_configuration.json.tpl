[
  {
    "apiName" : "root",
    "appName" : "pagopa",
    "url" : "https://${api_dot_env_name}.platform.pagopa.it/",
    "type" : "public",
    "checkCertificate" : true,
    "method" : "GET",
    "expectedCodes" : ["200"],
    "tags" : {
      "description" : "pagopa ${env_name} context root"
    },
    "durationLimit" : 10000,
    "alertConfiguration" : {
      "enabled" : false
    }
  }
]
