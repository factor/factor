IN: tools.disassembler.tests
USING: math classes.tuple prettyprint.custom 
tools.disassembler tools.test strings ;

[ ] [ \ + disassemble ] unit-test
[ ] [ M\ string pprint* disassemble ] unit-test
