IN: tools.deploy.test.3
USING: io.encodings.ascii io.encodings.string system kernel ;

: deploy-test-3 ( -- )
    "xyzthg" ascii encode drop ;

MAIN: deploy-test-3
