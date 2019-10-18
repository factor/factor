IN: temporary
USING: io embedded kernel test sequences ;

: test-embedded ( path -- ? )
    "apps/http-server/test/" swap append
    
    [
        ".fhtml" append resource-path
        [ run-embedded-file ] string-out
    ] keep

    ".html" append resource-path
    <file-reader> contents
    = ;

[ t ] [ "example" test-embedded ] unit-test
[ t ] [ "bug" test-embedded ] unit-test
[ t ] [ "stack" test-embedded ] unit-test
