USING: io ;

REQUIRES: embedded ;

PROVIDE: httpd { 
    "mime.factor"
    "xml.factor"
    "http-common.factor"
    "html-tags.factor"
    "responder.factor"
    "httpd.factor"
    "cont-responder.factor"
    "callback-responder.factor"
    "prototype-js.factor"
    "html.factor"
    "file-responder.factor"
    "help-responder.factor"
    "inspect-responder.factor"
    "browser-responder.factor"
    "default-responders.factor"
    "http-client.factor"
} {
    "test/html.factor"
    "test/http-client.factor"
    "test/httpd.factor"
    "test/url-encoding.factor"
} ;

"To start the HTTP server, issue the following command in the listener:" print
"  USE: httpd" print
"  [ 8888 httpd ] in-thread" print
"Replacing '8888' with whatever port number you desire." print
