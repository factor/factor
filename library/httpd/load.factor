USING: kernel parser sequences io ;
[
    "/library/httpd/http-common.factor"
    "/library/httpd/mime.factor"
    "/library/httpd/html-tags.factor"
    "/library/httpd/html.factor"
    "/library/httpd/responder.factor"
    "/library/httpd/httpd.factor"
    "/library/httpd/file-responder.factor"
    "/library/httpd/test-responder.factor"
    "/library/httpd/resource-responder.factor"
    "/library/httpd/cont-responder.factor"
    "/library/httpd/browser-responder.factor"
    "/library/httpd/default-responders.factor"
    "/library/httpd/http-client.factor"
] [
    dup print run-resource
] each
