! Copyright (C) 2009-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: assocs help.markup help.syntax ;
IN: cgi

HELP: <cgi-form>
{ $values { "assoc" assoc } }
{ $description "Parse a CGI request into an " { $link assoc } ". Multiple parameters are passed as a list for each key." } ;

HELP: <cgi-simple-form>
{ $values { "assoc" assoc } }
{ $description "Parse a CGI request into an " { $link assoc } ". Only the first parameter is kept, if multiple parameters are passed." } ;

ARTICLE: "cgi" "CGI (Common Gateway Interface)"
"The " { $vocab-link "cgi" } " can be used to parse a CGI request:"
{ $subsections
    <cgi-form>
    <cgi-simple-form>
}
{ $heading "Troubleshooting" }
"If the CGI script leaves elements on the stack, you'll get an error like the following (after running all of the code in your script):"
$nl
{ $snippet "Quotation called with wrong stack effect effect ( -- )" } ;

ABOUT: "cgi"
