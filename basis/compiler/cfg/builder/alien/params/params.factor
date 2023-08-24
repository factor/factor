! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs cpu.architecture fry kernel layouts locals
math math.order namespaces sequences vectors ;
IN: compiler.cfg.builder.alien.params

SYMBOL: stack-params

GENERIC: alloc-stack-param ( rep -- n )

M: object alloc-stack-param
    stack-params get
    [ rep-size cell align stack-params +@ ] dip ;

M: float-rep alloc-stack-param
    stack-params get swap rep-size
    [ cell align stack-params +@ ] keep
    float-right-align-on-stack? [ + ] [ drop ] if ;

: ?dummy-stack-params ( rep -- )
    dummy-stack-params? [ alloc-stack-param drop ] [ drop ] if ;

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

:: next-parameter ( vreg rep on-stack? odd-register? -- )
    vreg rep on-stack?
    [ dup dup reg-class-of get odd-register? reg-class-full? ] dip or
    [ alloc-stack-param stack-values ] [ odd-register? swap next-reg-param reg-values ] if
    [ 3array ] dip get push ;

: next-return-reg ( rep -- reg ) reg-class-of get pop ;

: with-return-regs ( quot -- )
    '[ return-regs init-regs @ ] with-scope ; inline
