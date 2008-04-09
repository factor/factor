IN: tools.deploy.test.3
USING: io.encodings.ascii io.files kernel ;

: deploy-test-3
    "resource:extra/tools/deploy/test/3/3.factor"
    ascii file-contents drop ;

MAIN: deploy-test-3
