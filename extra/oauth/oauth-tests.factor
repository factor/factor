USING: oauth oauth.private tools.test accessors kernel assocs
strings namespaces ;
IN: oauth.tests

[ "%26&b" ] [ "&" "b" hmac-key ] unit-test
[ "%26&" ] [ "&" f hmac-key ] unit-test

[ "B&http%3A%2F%2Ftwitter.com&a%3Db" ] [
    "http://twitter.com"
    "B"
    { { "a" "b" } }
    signature-base-string
] unit-test

[ "Z5tUa83q43qiy6dGGCb92bN/4ik=" ] [
    "ABC" "DEF" <token> consumer-token set

    "http://twitter.com"
    <request-token-params>
        12345 >>timestamp
        54321 >>nonce
    <request-token-request>
    post-data>>
    "oauth_signature" of
    >string
] unit-test
