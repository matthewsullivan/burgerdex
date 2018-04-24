#!/bin/bash

# Get curl with HTTP/2 and openssl with ECDSA: 'brew install curl openssl'
curl=/usr/local/opt/curl/bin/curl
openssl=/usr/local/opt/openssl/bin/openssl

# --------------------------------------------------------------------------

deviceToken=86a9380755e01d81eb762d5b09be1b17d0454676b4a2a1dedf2e8b51b5b99f9b

authKey="./AuthKey_V33W44GFB5.p8"
authKeyId=V33W44GFB5
teamId=RSD3QQHZ2M
bundleId=com.devandbarrel.burgerdex
endpoint=https://api.development.push.apple.com

read -r -d '' payload <<-'EOF'
{
   "aps": {
      "badge": 0,
      "category": "Food & Drink",
      "alert": {
         "title": "New Burger",
         "subtitle": "The Bacon Beast has just been added!",
         "body": "Two real beef patties covered in cheese, BBQ sauce and the best bacon in town. You must try this burger!"
      }
   }
}
EOF

# --------------------------------------------------------------------------

base64() {
   $openssl base64 -e -A | tr -- '+/' '-_' | tr -d =
}

sign() {
   printf "$1"| $openssl dgst -binary -sha256 -sign "$authKey" | base64
}

time=$(date +%s)
header=$(printf '{ "alg": "ES256", "kid": "%s" }' "$authKeyId" | base64)
claims=$(printf '{ "iss": "%s", "iat": %d }' "$teamId" "$time" | base64)
jwt="$header.$claims.$(sign $header.$claims)"

$curl --verbose \
   --header "content-type: application/json" \
   --header "authorization: bearer $jwt" \
   --header "apns-topic: $bundleId" \
   --data "$payload" \
   $endpoint/3/device/$deviceToken