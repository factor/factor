IN: scratchpad
USING: words kernel parser sequences io compiler ;

{ 
    "mime"
    "xml"
    "http-common"
    "html-tags"
    "responder"
    "httpd"
    "cont-responder"
    "callback-responder"
    "prototype-js"
    "html"
    "embedded"
    "file-responder"
    "help-responder"
    "inspect-responder"
    "browser-responder"
    "default-responders"
    "http-client"

    "test/html"
    "test/http-client"
    "test/httpd"
    "test/url-encoding"
} [ "/contrib/httpd/" swap ".factor" append3 run-resource ] each

"To start the HTTP server, issue the following command in the listener:" print
"  USE: httpd" print
"  [ 8888 httpd ] in-thread" print
"Replacing '8888' with whatever port number you desire." print
