USING: oauth1 oauth1.private tools.test accessors kernel assocs
strings namespaces urls ;

{ "%26&b" } [ "&" "b" hmac-key ] unit-test
{ "%26&" } [ "&" f hmac-key ] unit-test

{ "B&http%3A%2F%2Ftwitter.com%2F&a%3Db" } [
    URL" http://twitter.com"
    "B"
    { { "a" "b" } }
    signature-base-string
] unit-test

{ "0EieqbHx0FJ/RtFskmRj9/TDpqo=" } [
    "ABC" "DEF" <token> consumer-token set

    URL" http://twitter.com"
    <request-token-params>
        12345 >>timestamp
        54321 >>nonce
    <request-token-request>
    post-data>>
    "oauth_signature" of
    >string
] unit-test
