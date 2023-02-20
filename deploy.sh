#!/bin/bash

CURRENT_DIR=$(pwd)
IAC_DIR="${CURRENT_DIR}/iac"
RELEASE_DIR="${CURRENT_DIR}/bin/Release/net6.0/linux-x64/publish"

printf "\n* Compilando em netcore 6.0 ...\n"
dotnet publish serverless-netcore.sln \
    --configuration "Release" \
    --framework "net6.0" \
    --runtime "linux-x64" \
    --self-contained false >> /dev/null

if [ -f "$CURRENT_DIR/app.zip" ]; then
    printf "* Excluindo arquivo app.zip ...\n"
    rm -rf "$CURRENT_DIR/app.zip"
fi

cd ${RELEASE_DIR} && zip -r $(pwd)/app.zip . >> /dev/null && mv $(pwd)/app.zip $CURRENT_DIR

printf "* Copiando arquivo compilado para o S3 ... \n"
aws s3 cp "${CURRENT_DIR}/app.zip" "s3://dcorrea-my-bucket/example-net6/app.zip" \
    --profile danilosilva87 \
    --region us-east-1

cd $IAC_DIR

terraform apply
