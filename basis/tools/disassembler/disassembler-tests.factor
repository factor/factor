IN: tools.disassembler.tests
USING: math classes.tuple prettyprint.custom 
tools.disassembler tools.test strings ;

[ ] [ \ + disassemble ] unit-test
[ ] [ { string pprint* } disassemble ] unit-test
