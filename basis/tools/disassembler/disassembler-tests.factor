USING: kernel fry vocabs tools.disassembler tools.test sequences
system ;

os windows? cpu x86.32? and [
    "math" vocab-words [
        [ { } ] dip '[ _ disassemble ] unit-test
    ] each
] unless
