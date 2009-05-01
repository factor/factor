IN: tools.disassembler.tests
USING: kernel fry vocabs tools.disassembler tools.test sequences ;

"math" words [ [ [ ] ] dip '[ _ disassemble ] unit-test ] each