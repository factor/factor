USING: io ;

REQUIRES: libs/calendar libs/http libs/server libs/xml ;

PROVIDE: apps/http-server
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
    "test/httpd.factor"
    "test/url-encoding.factor"
    "test/embedded.factor"
} } ;

USE: httpd
MAIN: apps/http-server 8888 httpd ;
