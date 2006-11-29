USING: io ;

REQUIRES: libs/calendar libs/http libs/xml ;

PROVIDE: libs/httpd
{ +files+ {
    "mime.factor"
    "html-tags.factor"
    "responder.factor"
    "httpd.factor"
    "callback-responder.factor"
    "cont-responder.factor"
    "prototype-js.factor"
    "html.factor"
    "embedded.factor"
    "file-responder.factor"
    "default-responders.factor"
} }
{ +tests+ {
    "test/html.factor"
    "test/http-client.factor"
    "test/httpd.factor"
    "test/url-encoding.factor"
} } ;

USE: httpd
MAIN: libs/httpd 8888 httpd ;
