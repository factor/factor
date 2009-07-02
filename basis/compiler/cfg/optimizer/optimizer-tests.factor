USING: accessors arrays compiler.cfg.checker
compiler.cfg.debugger compiler.cfg.def-use
compiler.cfg.instructions fry kernel kernel.private math
math.private sbufs sequences sequences.private sets
slots.private strings tools.test vectors ;
IN: compiler.cfg.optimizer.tests

! Miscellaneous tests

: more? ( x -- ? ) ;

: test-case-1 ( -- ? ) f ;

: test-case-2 ( -- )
    test-case-1 [ test-case-2 ] [ ] if ; inline recursive

{
    [ 1array ]
    [ 1 2 ? ]
    [ { array } declare [ ] map ]
    [ { array } declare dup 1 slot [ 1 slot ] when ]
    [ [ dup more? ] [ dup ] produce ]
    [ vector new over test-case-1 [ test-case-2 ] [ ] if ]
    [ [ [ nth-unsafe ".." = 0 ] dip set-nth-unsafe ] 2curry (each-integer) ]
    [
        { fixnum sbuf } declare 2dup 3 slot fixnum> [
            over 3 fixnum* over dup [ 2 slot resize-string ] dip 2 set-slot
        ] [ ] if
    ]
    [ [ 2 fixnum* ] when 3 ]
    [ [ 2 fixnum+ ] when 3 ]
    [ [ 2 fixnum- ] when 3 ]
    [ 10000 [ ] times ]
} [
    [ [ ] ] dip '[ _ test-mr first check-mr ] unit-test
] each

[ t ]
[
    [
        HEX: 7fff fixnum-bitand 13 fixnum-shift-fast
        112 23 fixnum-shift-fast fixnum+fast
    ] test-mr first instructions>> [ ##add? ] any?
] unit-test
