USING: io.encodings.string kernel ;
IN: tools.deploy.test.4

: deploy-test-4 ( -- )
    "xyzthg" \ latin7 encode drop ;

MAIN: deploy-test-4
