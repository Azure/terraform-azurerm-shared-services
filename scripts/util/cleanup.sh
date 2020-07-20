set -ex

rm -Rf .terraform
rm -Rf terraform-azurerm-remote-state/.terraform
rm -f backend.*
rm -f terraform.tfstate*

pushd bootstrap
rm -Rf .terraform
rm -Rf terraform-azurerm-remote-state/.terraform
rm -f backend.*
rm -f terraform.tfstate*
popd

SUFFIX=$1

az group delete --name backend-$SUFFIX --yes &
az group delete --name rg-net-ss-$SUFFIX --yes &
az group delete --name rg-sec-ss-$SUFFIX --yes &
az group delete --name rg-data-ss-$SUFFIX --yes &
az group delete --name rg-diag-ss-$SUFFIX --yes &

wait

echo "Complete.."
