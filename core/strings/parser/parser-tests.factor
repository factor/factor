IN: strings.parser.tests
USING: strings.parser tools.test ;

[ "Hello\n\rworld" ] [ "Hello\\n\\rworld" unescape-string ] unit-test
