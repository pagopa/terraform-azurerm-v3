import json
import sys
import subprocess


def find_operation_ids(api_id: str, service_name: str, resource_group: str) -> str:
  # operations = subprocess.run(f'az apim api operation list --resource-group {resource_group} --service-name {service_name} --api-id {api_id} --query "[].{id:id, name:name, urlTemplate:urlTemplate}" --output json')
  operations = subprocess.run(['az', 'apim', 'api', 'operation', 'list','--resource-group', resource_group, '--service-name', service_name, '--api-id', api_id, '--query', '[].{id:id, name:name, urlTemplate:urlTemplate}', '--output', 'json'], capture_output=True, text=True)
  operations_j = json.loads(operations)

  result = {}

  for operation in operations_j:
    result[operation['name']] = operation['urlTemplate']
  return result

def main(query):
  rg = query['resource_group']
  service_name = query['service_name']
  api_id = query['api_id']
  operation_ids = find_operation_ids(api_id, service_name, rg)
  print(json.dumps(operation_ids))


if __name__ == "__main__":
  input = sys.stdin.read()
  query = json.loads(input)
  main(query)
