! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings ;
IN: crypto.passwd-md5

HELP: authenticate-password
{ $values
    { "shadow" string } { "password" string }
    { "?" boolean } }
{ $description "Encodes the provided password and compares it to the encoded password entry from a shadowed password file." } ;

HELP: parse-shadow-password
{ $values
    { "string" string }
    { "magic" string } { "salt" string } { "password" string } }
{ $description "Splits a shadowed password entry into a magic string, a salt, and an encoded password string." } ;

HELP: passwd-md5
{ $values
    { "magic" string } { "salt" string } { "password" string }
    { "bytes" "an md5-shadowed password entry" } }
{ $description "Encodes the password with the given magic string and salt to an MD5-shadow password entry." } ;

ARTICLE: "crypto.passwd-md5" "MD5 shadow passwords"
"The " { $vocab-link "crypto.passwd-md5" } " vocabulary can encode passwords for use in an MD5 shadow password file." $nl

"Encoding a password:"
{ $subsections passwd-md5 }
"Parsing a shadowed password entry:"
{ $subsections parse-shadow-password }
"Authenticating against a shadowed password:"
{ $subsections authenticate-password } ;

ABOUT: "crypto.passwd-md5"
