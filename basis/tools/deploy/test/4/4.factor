USING: io.encodings.string kernel io.encodings.8-bit ;
IN: tools.deploy.test.4

: deploy-test-4 ( -- )
    "xyzthg" latin7 encode drop ;

MAIN: deploy-test-4
