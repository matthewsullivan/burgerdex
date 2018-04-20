<?php
    
// THE FINAL SCRIPT WITHOUT DEPENDENCIES!!! ...except curl with http2
$device_token = "a0abd886etc...";
//echo $key;
$kid      = "YOURKEYID";
$teamId   = "YOURTEAMID";
$app_bundle_id = "your.app.bundle";
$base_url = "https://api.development.push.apple.com";

$header = ["alg" => "ES256", "kid" => $kid];
$header = base64_encode(json_encode($header));

$claim = ["iss" => $teamId, "iat" => time()];
$claim = base64_encode(json_encode($claim));

$token = $header.".".$claim;
// key in same folder as the script
$filename = "KeyFromApple.p8";
$pkey     = openssl_pkey_get_private("file://{$filename}");
$signature;
openssl_sign($token, $signature, $pkey, 'sha256');
$sign = base64_encode($signature);

$jws = $token.".".$sign;

$message = '{"aps":{"alert":"You are welcome.","sound":"default"}}';

function sendHTTP2Push($curl, $base_url, $app_bundle_id, $message, $device_token, $jws) {

    $url = "{$base_url}/3/device/{$device_token}";
    // headers
    $headers = array(
        "apns-topic: {$app_bundle_id}",
        'Authorization: bearer ' . $jws
    );
    // other curl options
    curl_setopt_array($curl, array(
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_2_0,
        CURLOPT_URL => $url,
        CURLOPT_PORT => 443,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_POST => TRUE,
        CURLOPT_POSTFIELDS => $message,
        CURLOPT_RETURNTRANSFER => TRUE,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_SSL_VERIFYPEER => FALSE,
        CURLOPT_HEADER => 1
    ));
    // go...
    $result = curl_exec($curl);
    if ($result === FALSE) {
        throw new Exception("Curl failed: " .  curl_error($curl));
    }
    print_r($result."\n");
    // get response
    $status = curl_getinfo($curl);
    return $status;
}
// open connection
$curl = curl_init();
sendHTTP2Push($curl, $base_url, $app_bundle_id, $message, $device_token, $jws);

?>