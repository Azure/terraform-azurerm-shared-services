#!/bin/bash

#USE IN THE EVENT YOU WANT TO REMOVE THE AUDIT POLICY BUT HAVE LOST THE TERRARFORM STATE

#Delete the parent Policy Initiative
az policy set-definition delete --name "Auto Diagnostics Policy Initiative"

#Delete the individual Policies

#WARNING this will delete all custom policies assigned to the subscription
#az policy definition list | jq -r 'map(select(.policyType=="Custom")) | .[] | .name' | while read line; do az policy definition delete -n $line ; done 

az policy definition list --query "[?contains(name, 'log-microsoft_')].name" | while read line; do az policy definition delete -n $line ; done 

