USING: accessors calendar kernel oauth2 tools.test urls ;

! assoc>tokens
{
    "blah" "bleh" t
} [
    H{
        { "expires_in" 3600 }
        { "access_token" "blah" }
        { "token_type" "Bearer" }
        { "refresh_token" "bleh" }
    } assoc>tokens
    [ access>> ] [ refresh>> ] [ expiry>> timestamp? ] tri
] unit-test

! oauth2>auth-uri
{
    URL" https://github.com/login/oauth/authorize?client_id=1234&scope=user&redirect_uri=test-pest&state=abcd&response_type=code&access_type=offline"
} [
    "https://github.com/login/oauth/authorize"
    "https://github.com/login/oauth/access_token"
    "test-pest"
    "1234" "password" "user"
    { { "state" "abcd" } } oauth2 boa oauth2>auth-uri
] unit-test

! tokens-params
{
    {
        { "code" "hej" }
        { "client_id" "1234" }
        { "client_secret" "password" }
        { "redirect_uri" "test-pest" }
        { "state" "abcd" }
        { "grant_type" "authorization_code" }
    }
} [
    "https://github.com/login/oauth/authorize"
    "https://github.com/login/oauth/access_token"
    "test-pest"
    "1234" "password" "user" { { "state" "abcd" } } oauth2 boa
    "hej" tokens-params
] unit-test
