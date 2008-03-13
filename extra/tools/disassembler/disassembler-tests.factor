IN: tools.disassembler.tests
USING: math tuples prettyprint.backend tools.disassembler
tools.test strings ;

[ ] [ \ + disassemble ] unit-test
[ ] [ { string pprint* } disassemble ] unit-test
