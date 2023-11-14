#!/bin/bash

# Executed for hosting 'CP-API' in 'container' mode for production & development purposes.

if [[ ! -n $SECRETS_MANAGER_ACCESS_TOKEN ]]; then
  echo "SECRETS_MANAGER_ACCESS_TOKEN is not set."
  exit 1
fi

# Set initial credentials for MongoDB
if [[ $1 -eq 1 ]]; then
  echo "Initialization mode: ON"
  export MONGO_INITDB_ROOT_USERNAME=$(bws secret get "d9e537ef-3d9d-40e8-af7a-b0ab01231127" --access-token "$SECRETS_MANAGER_ACCESS_TOKEN" | jq -r '.value')
  export MONGO_INITDB_ROOT_PASSWORD=$(bws secret get "32f20ec0-b3f9-4b12-be80-b0ab01233f2c" --access-token "$SECRETS_MANAGER_ACCESS_TOKEN" | jq -r '.value')
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo docker compose stop cp-api
  sudo docker compose rm -f cp-api
  sudo docker compose pull
  sudo -E docker compose up -d
elif [[ "$OSTYPE" == "darwin"* ]]; then
  docker compose stop cp-api
  docker compose rm -f cp-api
  docker compose pull
  docker compose up -d
fi

if [[ $1 -eq 1 ]]; then
  echo "Initializing database..."
  
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sleep 5s
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    sleep 5
  fi

  CUPLAN_MONGODB_CONNECTION_URI=$(bws secret get "5f5ffa48-aacb-4f98-89fa-b0ab0122ff13" --access-token "$SECRETS_MANAGER_ACCESS_TOKEN" | jq -r '.value')
  CUPLAN_MONGODB_USERNAME=$(bws secret get "d9e537ef-3d9d-40e8-af7a-b0ab01231127" --access-token "$SECRETS_MANAGER_ACCESS_TOKEN" | jq -r '.value')
  CUPLAN_MONGODB_PASSWORD=$(bws secret get "32f20ec0-b3f9-4b12-be80-b0ab01233f2c" --access-token "$SECRETS_MANAGER_ACCESS_TOKEN" | jq -r '.value')

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

  sleep 1

  chmod +x mongosh
  ./mongosh $CUPLAN_MONGODB_CONNECTION_URI --username $CUPLAN_MONGODB_USERNAME --password $CUPLAN_MONGODB_PASSWORD --file ./db/drop.js --file ./db/organization_permission.js --file ./db/organization.js --file ./db/role.js --file ./db/member.js --file ./db/invitation_code.js
fi