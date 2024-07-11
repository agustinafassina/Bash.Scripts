#!/bin/bash
## Auth0 example:
auth0ExternalApp=""
auth0Audience=""
auth0ClientId=""
auth0ClientSecret=""

declare -r bodyJson='{
    "audience":"'"$auth0Audience"'",
    "client_id":"'"$auth0ClientId"'",
    "client_secret":"'"$auth0ClientSecret"'",
    "grant_type":"client_credentials"
}'

codeResponse="$(curl --request POST --url $auth0ExternalApp --header "Content-type:application/json" --data "${bodyJson}" -w '\n%{http_code}' --output response.txt)"

if [ "$codeResponse" -eq "403" ];then
    bodyResponse="'" cat response.txt"'"
fi

if [ "$codeResponse" -eq "201" ];then
    codeResponse="'" cat response.txt"'"
fi