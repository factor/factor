! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs cpu.architecture fry kernel layouts locals
math math.order namespaces sequences vectors ;
IN: compiler.cfg.builder.alien.params

SYMBOL: stack-params

SYMBOL: compact-stack-params?

SYMBOLS: stack-group-offset stack-group-remaining ;

: param-natural-size ( rep-tuple -- size )
    dup length 3 > [ fourth ] [ first rep-size ] if ;

GENERIC#: alloc-stack-param 1 ( rep size -- n )

M:: object alloc-stack-param ( rep size -- n )
    compact-stack-params? get
    [ stack-params get size align dup size + stack-params set ]
    [ stack-params get dup rep rep-size cell align + stack-params set ]
    if ;

M:: float-rep alloc-stack-param ( rep size -- n )
    compact-stack-params? get
    [ stack-params get size align dup size + stack-params set ]
    [ stack-params get rep rep-size [ cell align stack-params +@ ] keep
      float-right-align-on-stack? [ + ] [ drop ] if ]
    if ;

: ?dummy-stack-params ( rep -- )
    dummy-stack-params? [ cell alloc-stack-param drop ] [ drop ] if ;

: ?dummy-int-params ( rep -- )
    dummy-int-params? [
        rep-size cell /i 1 max
        [ int-regs get [ pop* ] unless-empty ] times
    ] [ drop ] if ;

: ?dummy-fp-params ( rep -- )
    drop dummy-fp-params? [ float-regs get [ pop* ] unless-empty ] when ;

GENERIC: next-reg-param ( odd-register? rep -- reg )

M: int-rep next-reg-param
    [ nip ?dummy-stack-params ]
    [ nip ?dummy-fp-params ]
    [ drop [
        int-regs get last even?
        [ int-regs get pop* ] when
    ] when ]
    2tri int-regs get pop ;

M: object next-reg-param
    nip [ ?dummy-stack-params ] [ ?dummy-int-params ] bi
    float-regs get pop ;

: reg-class-full? ( reg-class odd-register? -- ? )
    over length 1 = and [ dup delete-all ] when empty? ;

: init-reg-class ( abi reg-class -- )
    [ swap param-regs at <reversed> >vector ] keep set ;

: init-regs ( regs -- )
    [ <reversed> >vector swap set ] assoc-each ;

SYMBOLS: stack-values reg-values ;

! ARM64 composite arguments are assigned as a group. If there are not
! enough registers, the entire argument and later arguments of that class
! use the stack (AAPCS64 C.2/C.3 and C.12/C.13).
:: prepare-parameter-group ( rep-tuple -- )
    rep-tuple length 4 > [
        rep-tuple first reg-class-of get :> regs
        4 rep-tuple nth :> count
        count regs length > [
            regs delete-all
            compact-stack-params? get [
                ! A spilled aggregate retains its in-memory member layout.
                ! Round the whole argument, not each float member, to a cell.
                rep-tuple param-natural-size :> size
                stack-params get size cell max align :> offset
                offset stack-group-offset set
                count stack-group-remaining set
                offset count size * cell align + stack-params set
            ] unless
        ] when
    ] when ;

: alloc-parameter-stack-slot ( rep size -- n )
    stack-group-remaining get 0 or 0 > [
        nip stack-group-offset get swap stack-group-offset +@
        -1 stack-group-remaining +@
    ] [ alloc-stack-param ] if ;

:: next-parameter ( vreg rep on-stack? odd-register? size -- )
    vreg rep on-stack?
    [ dup dup reg-class-of get odd-register? reg-class-full? ] dip or
    [ size alloc-parameter-stack-slot size 4array stack-values ]
    [ odd-register? swap next-reg-param 3array reg-values ]
    if get push ;

: next-return-reg ( rep -- reg ) reg-class-of get pop ;

: with-return-regs ( quot -- )
    '[ return-regs init-regs @ ] with-scope ; inline
