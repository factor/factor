IN: temporary
USING: io embedded kernel test ;

[ t ] [
    "libs/httpd/test/example.fhtml" resource-path
    [ run-embedded-file ] string-out
    
    "libs/httpd/test/example.html"
    resource-path <file-reader> contents
    =
] unit-test
