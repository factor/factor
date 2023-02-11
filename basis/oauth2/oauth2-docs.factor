! Copyright (C) 2018 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: oauth2

ARTICLE: "oauth2" "Oauth2 Support"
"The " { $vocab-link "oauth2" } " vocab implements client support for the Oauth2 protocol."
$nl
"To use the oauth2 vocab, first create an instance of the " { $link oauth2 } " class to represent the Oauth2 provider's settings. The slots 'auth-uri' and 'token-uri' should be set to the providers authentication and token uri:ss. The 'redirect-uri' should hold the URI to a callback URL, which usually must be registered with the provider. The 'client-id' and 'client-secret' slots identifies the application and should be kept secret. For example, to initialize an oauth2 instance compatible with GitHub's api use:"
{ $unchecked-example
  "\"https://github.com/login/oauth/authorize\""
  "\"https://github.com/login/oauth/access_token\""
  "\"https://localhost:8080\" \"client-id\" \"client-secret\""
  "\"user\" { } oauth2 boa"
}
"Then to get hold of an access token, use the " { $link console-flow } " word and enter the verification code given by the provider. This puts a " { $link tokens } " instance on the stack whose slot 'access' contains the actual access token. It can be used to make API calls on behalf of the user. For example, to list all the user's GitHub repositories:"
{ $unchecked-example
  "\"https://api.github.com/user/repos\" \"access-token\""
  "oauth-http-get"
}
"Some providers limit the validity of the access token. If so, the provider sets the 'expiry' slot on the " { $link tokens } " tuple to the tokens expiration date and 'refresh' to a refresh token. The refresh token can be used with the " { $link refresh-flow } " word to request new access tokens from the provider."
{ $notes "The vocab only implements the console flow, but other methods for acquiring tokens could be added in the future" } ;

ABOUT: "oauth2"
