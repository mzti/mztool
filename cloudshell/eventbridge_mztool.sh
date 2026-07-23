#!/bin/bash

REGION="sa-east-1"
BUCKET_NAME="mztool"
ZIP_NAME="mztool.zip"

# PAT deve ser exportado antes de rodar:
# export GITHUB_PAT="ghp_xxxxx"
if [ -z "$GITHUB_PAT" ]; then
  echo "ERRO: export GITHUB_PAT=\"ghp_xxxxx\" antes de rodar."
  exit 1
fi

CONNECTION_NAME="github-dispatch-mztool"
API_DEST_NAME="MztoolGithubActionsAPI"
RULE_NAME="mztool-githubactions"

echo "====================================="
echo "BUSCANDO OU CRIANDO CONNECTION"
echo "====================================="

# Tenta buscar a Connection existente
CONNECTION_ARN=$(aws events list-connections \
  --query "Connections[?Name=='$CONNECTION_NAME'].ConnectionArn" \
  --output text)

if [ -z "$CONNECTION_ARN" ]; then
  echo "Connection não existe. Criando..."
  CONNECTION_ARN=$(aws events create-connection \
    --name "$CONNECTION_NAME" \
    --authorization-type API_KEY \
    --auth-parameters "ApiKeyAuthParameters={ApiKeyName=Authorization,ApiKeyValue=Bearer $GITHUB_PAT}" \
    --query ConnectionArn \
    --output text)
else
  echo "Connection já existe: $CONNECTION_ARN"
fi

echo "====================================="
echo "BUSCANDO OU CRIANDO API DESTINATION"
echo "====================================="

API_DEST_ARN=$(aws events list-api-destinations \
  --query "ApiDestinations[?Name=='$API_DEST_NAME'].ApiDestinationArn" \
  --output text)

if [ -z "$API_DEST_ARN" ]; then
  echo "API Destination não existe. Criando..."
  API_DEST_ARN=$(aws events create-api-destination \
    --name "$API_DEST_NAME" \
    --connection-arn "$CONNECTION_ARN" \
    --invocation-endpoint "https://api.github.com/repos/mzti/mztool/dispatches" \
    --http-method POST \
    --query ApiDestinationArn \
    --output text)
else
  echo "API Destination já existe: $API_DEST_ARN"
fi

echo "====================================="
echo "CRIANDO RULE (SE NECESSÁRIO)"
echo "====================================="

aws events put-rule \
  --name "$RULE_NAME" \
  --event-pattern "{
    \"source\": [\"aws.s3\"],
    \"detail-type\": [\"Object Created\"],
    \"detail\": {
      \"bucket\": { \"name\": [\"$BUCKET_NAME\"] },
      \"object\": { \"key\": [\"$ZIP_NAME\"] }
    }
  }" \
  --region "$REGION"

echo "Rule criada ou atualizada."

echo "====================================="
echo "CRIANDO ROLE COM POLICY INLINE"
echo "====================================="

ROLE_NAME="Amazon_EventBridge_Invoke_API_Destination_$RANDOM"

aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Principal\": {\"Service\": \"events.amazonaws.com\"},
        \"Action\": \"sts:AssumeRole\"
      }
    ]
  }"

# Policy inline que funciona em qualquer região
aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "InvokeApiDestinationPolicy" \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"events:InvokeApiDestination\"
        ],
        \"Resource\": \"$API_DEST_ARN\"
      }
    ]
  }"

ROLE_ARN=$(aws iam get-role \
  --role-name "$ROLE_NAME" \
  --query Role.Arn \
  --output text)

echo "Role ARN: $ROLE_ARN"

echo "====================================="
echo "ASSOCIANDO TARGET"
echo "====================================="

aws events put-targets \
  --rule "$RULE_NAME" \
  --targets "[
    {
      \"Id\": \"1\",
      \"Arn\": \"$API_DEST_ARN\",
      \"Input\": \"{\\\"event_type\\\":\\\"mztool-updated\\\"}\",
      \"RoleArn\": \"$ROLE_ARN\"
    }
  ]" \
  --region "$REGION"

echo "====================================="
echo "CONFIGURAÇÃO COMPLETA!"
echo "EventBridge → GitHub Actions funcionando."
echo "====================================="
