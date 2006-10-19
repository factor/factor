USING: io ;

REQUIRES: contrib/calendar contrib/embedded contrib/http
contrib/xml ;

PROVIDE: contrib/httpd { 
    "mime.factor"
    "html-tags.factor"
    "responder.factor"
    "httpd.factor"
    "callback-responder.factor"
    "cont-responder.factor"
    "prototype-js.factor"
    "html.factor"
    "file-responder.factor"
    "default-responders.factor"
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
