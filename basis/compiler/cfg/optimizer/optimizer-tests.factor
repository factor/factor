USING: accessors arrays compiler.cfg.checker compiler.cfg.debugger
compiler.cfg.def-use compiler.cfg.instructions compiler.cfg.optimizer
fry kernel kernel.private math math.partial-dispatch math.private
sbufs sequences sequences.private sets slots.private strings
strings.private tools.test vectors layouts ;
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
    [
        over integer? [
            over dup 16 <-integer-fixnum
            [ 0 >=-integer-fixnum ] [ drop f ] if [
                nip dup
                [ ] [ ] if
            ] [ 2drop f ] if
        ] [ 2drop f ] if
    ]
    [
        pick 10 fixnum>= [ [ 123 fixnum-bitand ] 2dip ] [ ] if
        set-string-nth-fast
    ]
} [
    [ [ ] ] dip '[ _ test-cfg first optimize-cfg check-cfg ] unit-test
] each

cell 8 = [
    [ t ]
    [
        [
            1 50 fixnum-shift-fast fixnum+fast
        ] test-mr first instructions>> [ ##add? ] any?
    ] unit-test
] when
