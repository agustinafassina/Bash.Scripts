#!/bin/bash
# v2.0
## Auth0 example:
auth0_external_app=""
auth0_audience=""
auth0_client_id=""
auth0_client_secret=""

declare -r body_json='{
    "audience":"'"$auth0_audience"'",
    "client_id":"'"$auth0_client_id"'",
    "client_secret":"'"$auth0_client_secret"'",
    "grant_type":"client_credentials"
}'

code_response="$(curl --request POST --url $auth0_external_app --header "Content-type:application/json" --data "${body_json}" -w '\n%{http_code}' --output response.txt)"

if [ "$code_response" -eq "403" ];then
    bodyResponse="'" cat response.txt"'"
fi

if [ "$code_response" -eq "201" ];then
    code_response="'" cat response.txt"'"
fi