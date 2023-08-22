! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: http.server.static

HELP: <file-responder>
{ $values { "root" "a pathname string" } { "hook" { $quotation ( path mime-type -- response ) } } { "responder" file-responder } }
{ $description "Creates a file responder which serves content from " { $snippet "path" } " by using the hook to generate a response." } ;

HELP: <static>
{ $values
    { "root" "a pathname string" }
    { "responder" file-responder } }
{ $description "Creates a file responder which serves content from " { $snippet "path" } "." } ;

HELP: enable-fhtml
{ $values { "responder" file-responder } }
{ $description "Enables the responder to serve " { $snippet ".fhtml" } " files by running them." }
{ $notes "See " { $link "html.templates.fhtml" } "." }
{ $side-effects "responder" } ;

ARTICLE: "http.server.static.extend" "Hooks for dynamic content"
"The static responder can be extended for dynamic content by associating quotations with MIME types in the hashtable stored in the " { $slot "special" } " slot. The quotations have stack effect " { $snippet "( path -- response )" } "."
$nl
"A utility word uses the above feature to enable server-side " { $snippet ".fhtml" } " scripts, allowing a development style much like PHP:"
{ $subsections enable-fhtml }
"This feature is also used by " { $vocab-link "http.server.cgi" } " to run " { $snippet ".cgi" } " files."
$nl
"It is also possible to override the hook used when serving static files to the client:"
{ $subsections <file-responder> }
"The default just sends the file's contents with the request; " { $vocab-link "xmode.code2html.responder" } " provides an alternate hook which sends a syntax-highlighted version of the file." ;

ARTICLE: "http.server.static" "Serving static content"
"The " { $vocab-link "http.server.static" } " vocabulary implements a responder for serving static files."
{ $subsections <static> }
"The static responder does not serve directory listings by default, as a security measure. Directory listings can be enabled by storing a true value in the " { $slot "allow-listings" } " slot."
$nl
"If all you want to do is serve files from a directory, the following phrase does the trick:"
{ $code
    "USING: namespaces http.server http.server.static ;"
    "\"/var/www/mysite.com/\" <static> main-responder set"
    "8080 httpd"
}
{ $subsections "http.server.static.extend" } ;

ABOUT: "http.server.static"
