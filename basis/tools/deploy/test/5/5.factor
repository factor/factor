IN: tools.deploy.test.5
USING: accessors urls io.encodings.ascii io.files math.parser
http.client kernel ;

: deploy-test-5 ( -- )
    URL" http://localhost/foo.html" clone
    "resource:port-number" ascii file-contents string>number >>port
    http-get 2drop ;

MAIN: deploy-test-5
