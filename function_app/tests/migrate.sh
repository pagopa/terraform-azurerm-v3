#!/bin/bash

function removeAndImport() {
    #
    # Remove and import a Terraform resource
    #
    local old_resource_name="$1"
    # Square brackets are not processed normally by grep, otherwise
    esc_old_resource_name=$(echo "$old_resource_name" | sed 's/\[/\\[/g; s/\]/\\]/g')

    local new_resource_name="$2"

    if [ -z "$old_resource_name" ] || [ -z "$new_resource_name" ]; then
        echo "You need to define the resources to be removed and imported in order to proceed"
    exit 1
    fi
    if [ "$(terraform show | grep $esc_old_resource_name)" ]; then
        # Get the resource ID
        function_app_id=$(terraform show -json | jq --arg resource "$old_resource_name" '.values.root_module.child_modules[].resources[] | select(.address==$resource).values.id' | tr -d '"')
        if [ $? -eq 0 ]; then
            # Remove the resource from the state file
            terraform state rm "$old_resource_name"
            if [ $? -eq 0 ]; then
                # Import the resource as "module.func_python.azurerm_linux_function_app.this"
                terraform import $new_resource_name $function_app_id
                if [ $? -eq 0 ]; then
                    echo "Successfully imported the function app resource as a Linux function app with ID: $function_app_id"
                else
                    echo "I can't import the resource $new_resource_name"
                fi
            else
                echo "I can't remove the resource $old_resource_name from your Terraform state"
            fi
        else
            echo "I can't find the resource $old_resource_name in your Terraform state"
        fi
    else
        echo "The $old_resource_name resource was not found in the state file."
    fi
}

# Check if the "Terraform" and "jq" commands are available
if ! which terraform &> /dev/null && which jq &> /dev/null; then
  echo "Please install terraform and jq before proceeding."
  exit 1
fi

removeAndImport "module.func_python.azurerm_function_app.this" "module.func_python.azurerm_linux_function_app.this"

removeAndImport "module.func_python.azurerm_app_service_plan.this[0]" "module.func_python.azurerm_service_plan.this[0]"

