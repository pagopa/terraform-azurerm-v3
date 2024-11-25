#!/bin/bash

#
# bash .utils/terraform_run_all.sh init local
# bash .utils/terraform_run_all.sh init docker
#

# 'set -e' tells the shell to exit if any of the foreground command fails,
# i.e. exits with a non-zero status.
set -eu

# Initialize array of PIDs for the background jobs that we're about to launch.
pids=()

TAG=$(cat .terraform-version)
ACTION="$1"
MODE="$2"

case "${MODE}" in
  docker*)
    docker pull "hashicorp/terraform:$TAG"
  ;;
  local*)
    terraform -version
  ;;
  *)
  exit 1
esac

function terraform_init(){
  folder="$1"
  root_folder="$(pwd)"
  if [ -d "$folder" ]; then
    echo "🔬 folder: $folder in under terraform: $ACTION action $MODE mode"

    rm -rf "$folder/ignore_features.tf"
    rm -rf "$folder/.terraform"
    rm -rf "$folder/.terraform.lock.hcl"
    find "$folder" -type f -name '*.terraform.lock.hcl*' -delete

    cd "$folder" || exit

    case "${MODE}" in
      docker*)
        docker run -v "${root_folder}:/tmp" -w /tmp/${folder} "hashicorp/terraform:$TAG" "$ACTION"
      ;;
      local*)
        terraform "$ACTION"
      ;;
    *)
      exit 1
    esac

    cd ..
  fi
}

for folder in *; do
  terraform_init "${folder}" &

  # Add the PID of this background job to the array.
  pids+=($!)
done

# Wait for each specific process to terminate.
# Instead of this loop, a single call to 'wait' would wait for all the jobs
# to terminate, but it would not give us their exit status.
#
for pid in "${pids[@]}"; do
  #
  # Waiting on a specific PID makes the wait command return with the exit
  # status of that process. Because of the 'set -e' setting, any exit status
  # other than zero causes the current shell to terminate with that exit
  # status as well.
  #
  wait "$pid"
done
