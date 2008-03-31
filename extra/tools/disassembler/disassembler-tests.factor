IN: tools.disassembler.tests
USING: math classes.tuple prettyprint.backend tools.disassembler
tools.test strings ;

[ ] [ \ + disassemble ] unit-test
[ ] [ { string pprint* } disassemble ] unit-test
