! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax http.basic-authentication crypto.sha2 ;

HELP: realms
{ $description 
   "A hashtable mapping a basic authentication realm (a string) "
   "to either a quotation or a hashtable. The quotation has "
   "stack effect ( username sha-256-string -- bool ). It "
   "is expected to perform the user authentication when called." $nl
   "If the realm maps to a hashtable then the hashtable should be a "
   "mapping of usernames to sha-256 hashed passwords." $nl
   "If the 'realms' variable does not exist in the current scope then "
   "authentication will always fail." }
{ $see-also add-realm with-basic-authentication } ;

HELP: add-realm
{ $values 
  { "data" "a quotation or a hashtable" } { "name" "a string" } }
{ $description 
   "Adds the authentication data to the " { $link realms } ". 'data' can be "
   "a quotation with stack effect ( username sha-256-string -- bool ) or "
   "a hashtable mapping username strings to sha-256-string passwords." }
{ $examples
  { $code "H{ { \"admin\" \"...\" } { \"user\" \"...\" } } \"my-realm\" add-realm" }
  { $code "[ \"...\" = swap \"admin\" = and ] \"my-realm\" add-realm" }
}
{ $see-also with-basic-authentication realms } ;

HELP: with-basic-authentication
{ $values 
  { "realm" "a string" } { "quot" "a quotation with stack effect ( -- )" } }
{ $description 
   "Checks if the HTTP request has the correct authorisation headers "
   "for basic authentication within the named realm. If the headers "
   "are not present then a '401' HTTP response results from the "
   "request, otherwise the quotation is called." }
{ $examples
{ $code "\"my-realm\" [\n  serving-html \"<html><body>Success!</body></html>\" write\n] with-basic-authentication" } }
{ $see-also add-realm realms }
 ;

ARTICLE: { "http-authentication" "basic-authentication" } "Basic Authentication"
"The Basic Authentication system provides a simple browser based " 
"authentication method to web applications. When the browser requests "
"a resource protected with basic authentication the server responds with "
"a '401' response code which means the user is unauthorized."
$nl
"When the browser receives this it prompts the user for a username and " 
"password. This is sent back to the server in a special HTTP header. The "
"server then checks this against its authentication information and either "
"accepts or rejects the users request."
$nl
"Authentication is split up into " { $link realms } ". Each realm can have "
"a different database of username and password information. A responder can "
"require basic authentication by using the " { $link with-basic-authentication } " word."
$nl
"Username and password information can be maintained using " { $link realms } " and " { $link add-realm } "."
$nl
"All passwords on the server should be stored as sha-256 strings generated with the " { $link string>sha-256-string } " word."
$nl
"Note that Basic Authentication itself is insecure in that it "
"sends the username and password as clear text (although it is "
"base64 encoded this is not much help). To prevent eavesdropping "
"it is best to use Basic Authentication with SSL."  ;

IN: http.basic-authentication
ABOUT: { "http-authentication" "basic-authentication" }