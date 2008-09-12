IN: tools.deploy.test.4
USING: io.encodings.8-bit io.encodings.string kernel ;

: deploy-test-4 ( -- )
    "xyzthg" \ latin7 encode drop ;

MAIN: deploy-test-4
