USING: dotenv dotenv.private environment kernel peg tools.test ;

! parse keys

[ "0KEY" key-parser parse ] must-fail
{ "KEY" } [ "KEY" key-parser parse ] unit-test
{ "KEY1" } [ "KEY1" key-parser parse ] unit-test

! parse values

{ "ABCDEF" } [ "ABCDEF" value-parser parse ] unit-test
{ "ABCDEF" } [ "ABCDEF" value-parser parse ] unit-test
{ "ABC\t\"DEF" } [ "\"ABC\\t\\\"DEF\"" value-parser parse ] unit-test
{ "ABC\\t'DEF" } [ "'ABC\\t\\'DEF'" value-parser parse ] unit-test
{ "ABC\\t`DEF" } [ "`ABC\\t\\`DEF`" value-parser parse ] unit-test

! get var

{ "testing" } [
    "testing" "HOST" set-os-env
    "HOST=\"${HOST}\"" parse-dotenv drop
    "HOST" os-env
] unit-test

! default, if not empty

{ "localhost" } [
    "HOST" unset-os-env
    "HOST=\"${HOST:-localhost}\"" parse-dotenv drop
    "HOST" os-env
] unit-test

{ "google.com" } [
    "google.com" "HOST" set-os-env
    "HOST=\"${HOST:-localhost}\"" parse-dotenv drop
    "HOST" os-env
] unit-test

! default, it not set

{ "localhost" } [
    "HOST" unset-os-env
    "HOST=\"${HOST-localhost}\"" parse-dotenv drop
    "HOST" os-env
] unit-test

{ "" } [
    "" "HOST" set-os-env
    "HOST=\"${HOST-localhost}\"" parse-dotenv drop
    "HOST" os-env
] unit-test
