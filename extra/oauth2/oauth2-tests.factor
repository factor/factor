USING: kernel oauth2 tools.test urls ;
IN: oauth2.tests

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

! token-params
{
    {
        { "client_id" "1234" }
        { "client_secret" "password" }
        { "redirect_uri" "test-pest" }
        { "state" "abcd" }
        { "code" "hej" }
        { "grant_type" "authorization_code" }
    }
} [
    "https://github.com/login/oauth/authorize"
    "https://github.com/login/oauth/access_token"
    "test-pest"
    "1234" "password" "user" { { "state" "abcd" } } oauth2 boa
    "hej" token-params
] unit-test
