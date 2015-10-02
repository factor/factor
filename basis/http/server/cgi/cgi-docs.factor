USING: help.markup help.syntax ;
IN: http.server.cgi

DEFER: file-responder
DEFER: <static>

HELP: enable-cgi
{ $values { "responder" file-responder } }
{ $description "Enables the responder to serve " { $snippet ".cgi" } " scripts by executing them as per the CGI specification." }
{ $examples
    { $code
        "<dispatcher>
    \"/var/www/cgi/\" <static> enable-cgi \"cgi-bin\" add-responder"
    }
}
{ $side-effects "responder" } ;

ARTICLE: "http.server.cgi" "Serving CGI scripts"
"The " { $vocab-link "http.server.cgi" } " implements CGI support. It is used in conjunction with a " { $link <static> } " responder."
{ $subsections enable-cgi } ;

ABOUT: "http.server.cgi"
