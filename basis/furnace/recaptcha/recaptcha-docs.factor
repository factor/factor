! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: furnace.actions furnace.alloy help.markup help.syntax
http.server.filters ;
IN: furnace.recaptcha

HELP: <recaptcha>
{ $values
    { "responder" "a responder" }
    { "recaptcha" recaptcha }
}
{ $description "A " { $link filter-responder } " wrapping another responder. Set the domain, public, and private keys using the key you get by registering with recaptcha." } ;

HELP: recaptcha-error
{ $var-description "Set to the error string returned by the recaptcha server." } ;

HELP: validate-recaptcha
{ $description "Validates a recaptcha using the recaptcha web service API." } ;

ARTICLE: "recaptcha-example" "Recaptcha example"
"There are several steps to using the recaptcha library."
{ $list
    { "Wrap the responder in a " { $link <recaptcha> } }
    { "Wrap the responder in an " { $link <alloy> } " if it is not already, to enable conversations and database access" }
    { "Call " { $link validate-recaptcha } " from the " { $slot "validate" } " slot of the " { $link action } }
    { "Put the chloe tag " { $snippet "<recaptcha/>" } " inside a form tag in the template served by your " { $link action } }
}
$nl
"There is an example web app using recaptcha support:"
{ $code
    "USING: furnace.recaptcha.example http.server ;"
    "<recaptcha-app> main-responder set-global"
    "8080 httpd"
} ;

ARTICLE: "furnace.recaptcha" "Recaptcha support for Furnace"
"The " { $vocab-link "furnace.recaptcha" } " vocabulary implements support for the recaptcha. Recaptcha is a web service that provides the user with a captcha, a test that is easy to solve by visual inspection, but hard to solve by writing a computer program. Use a captcha to protect forms from abusive users." $nl

"The recaptcha responder is a " { $link filter-responder } " that wraps another responder. Set the " { $slot "domain" } ", " { $slot "site-key" } ", and " { $slot "secret-key" } " slots of this responder to your recaptcha account information." $nl

"Wrapping a responder with recaptcha support:"
{ $subsections <recaptcha> }
"Validating recaptcha:"
{ $subsections validate-recaptcha }
"Symbol set after validation:"
{ $subsections recaptcha-error }
"An example:"
{ $subsections "recaptcha-example" } ;

ABOUT: "furnace.recaptcha"
