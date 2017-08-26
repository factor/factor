USING: io xml.syntax xml.writer ;
IN: tools.deploy.test.20

: test-xml ( str -- str' )
    XML-DOC[[ <foo><-></foo> ]] xml>string ;

: main ( -- )
    "Factor" test-xml print ;

MAIN: main
