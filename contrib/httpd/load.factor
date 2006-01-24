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
    "live-updater"
    "prototype-js"
    "html"
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
