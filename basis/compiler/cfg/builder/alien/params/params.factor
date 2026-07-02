! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs cpu.architecture fry kernel layouts locals
math math.order namespaces sequences vectors ;
IN: compiler.cfg.builder.alien.params

SYMBOL: stack-params

SYMBOL: compact-stack-params?

: param-natural-size ( rep-tuple -- size )
    dup length 3 > [ fourth ] [ drop cell ] if ;

GENERIC#: alloc-stack-param 1 ( rep size -- n )

:: alloc-compact-param ( size -- n )
    stack-params get size align dup size + stack-params set ;

M:: object alloc-stack-param ( rep size -- n )
    compact-stack-params? get
    [ size alloc-compact-param ]
    [ stack-params get dup rep rep-size cell align + stack-params set ]
    if ;

M:: float-rep alloc-stack-param ( rep size -- n )
    compact-stack-params? get
    [ size alloc-compact-param ]
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

:: next-parameter ( vreg rep on-stack? odd-register? size -- )
    vreg rep on-stack?
    [ dup dup reg-class-of get odd-register? reg-class-full? ] dip or
    [ size alloc-stack-param size 4array stack-values ]
    [ odd-register? swap next-reg-param 3array reg-values ]
    if get push ;

: next-return-reg ( rep -- reg ) reg-class-of get pop ;

: with-return-regs ( quot -- )
    '[ return-regs init-regs @ ] with-scope ; inline
