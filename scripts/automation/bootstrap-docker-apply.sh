#!/bin/sh
terraform init
terraform apply -auto-approve
cp -r /ss/submodules/bootstrap /data