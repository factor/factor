IN: tools.deploy.test.5
USING: http.client kernel ;

: deploy-test-5 ( -- )
    "http://localhost:1237/foo.html" http-get 2drop ;

MAIN: deploy-test-5
