#!/bin/bash

# Executed for solving the dependencies of the execution of the CP-API for development purposes.

if [[ -n $1 ]]; then
  cd "$1" || exit 1
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo -E docker compose -f dev.docker-compose.yaml up -d
elif [[ "$OSTYPE" == "darwin"* ]]; then
  docker compose -f dev.docker-compose.yaml up -d
fi

if [ ! -f ./mongosh ]; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl https://downloads.mongodb.com/compass/mongosh-2.0.1-linux-x64.tgz --output mongosh.tgz
    tar -zxvf mongosh.tgz

    mv mongosh-2.0.1-linux-x64/bin/* ./
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    curl https://downloads.mongodb.com/compass/mongosh-2.0.1-darwin-arm64.zip --output mongosh.zip
    unzip -o mongosh.zip

    mv mongosh-2.0.1-darwin-arm64/bin/* ./
  fi
fi


if [[ -z ${CUPLAN_DEPS_FIRST_RUN+x} ]]; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sleep 5s
  elif [[ "$OSTYPE" == "darwin"* ]]; then
      sleep 5
  fi

  export CUPLAN_DEPS_FIRST_RUN="false"
fi

chmod +x mongosh
./mongosh mongodb://localhost:26000 --username guest --password guest --file ./db/drop.js --file ./db/organization_permission.js --file ./db/organization.js --file ./db/role.js --file ./db/member.js --file ./db/invitation_code.js