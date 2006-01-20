IN: scratchpad
USING: words kernel parser sequences io compiler ;

{ 
    "xml"
    "http-common"
    "mime"
    "html-tags"
    "html"
    "responder"
    "httpd"
    "file-responder"
    "help-responder"
    "cont-responder"
    "browser-responder"
    "default-responders"
    "http-client"

    "test/html"
    "test/http-client"
    "test/httpd"
    "test/url-encoding"
} [ "contrib/httpd/" swap ".factor" append3 run-file ] each
