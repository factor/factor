USING: arrays sequences tools.test compiler.cfg.checker compiler.cfg.debugger
compiler.cfg.def-use sets kernel kernel.private fry slots.private vectors
sequences.private math sbufs math.private slots.private strings ;
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
