! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.architecture fry kernel layouts math math.order
namespaces sequences vectors assocs arrays ;
IN: compiler.cfg.builder.alien.params

SYMBOL: stack-params

: alloc-stack-param ( rep -- n )
    stack-params get
    [ rep-size cell align stack-params +@ ] dip ;

: ?dummy-stack-params ( rep -- )
    dummy-stack-params? [ alloc-stack-param drop ] [ drop ] if ;

: ?dummy-int-params ( rep -- )
    dummy-int-params? [
        rep-size cell /i 1 max
        [ int-regs get [ pop* ] unless-empty ] times
    ] [ drop ] if ;

: ?dummy-fp-params ( rep -- )
    drop dummy-fp-params? [ float-regs get [ pop* ] unless-empty ] when ;

GENERIC: next-reg-param ( rep -- reg )

M: int-rep next-reg-param
    [ ?dummy-stack-params ] [ ?dummy-fp-params ] bi
    int-regs get pop ;

M: float-rep next-reg-param
    [ ?dummy-stack-params ] [ ?dummy-int-params ] bi
    float-regs get pop ;

M: double-rep next-reg-param
    [ ?dummy-stack-params ] [ ?dummy-int-params ] bi
    float-regs get pop ;

: reg-class-full? ( reg-class -- ? ) get empty? ;

: init-reg-class ( abi reg-class -- )
    [ swap param-regs at <reversed> >vector ] keep set ;

: init-regs ( regs -- )
    [ <reversed> >vector swap set ] assoc-each ;

: with-param-regs ( abi quot -- )
    '[ param-regs init-regs 0 stack-params set @ ] with-scope ; inline

SYMBOLS: stack-values reg-values ;

: next-parameter ( vreg rep on-stack? -- )
    [ dup dup reg-class-of reg-class-full? ] dip or
    [ alloc-stack-param stack-values ] [ next-reg-param reg-values ] if
    [ 3array ] dip get push ;

: next-return-reg ( rep -- reg ) reg-class-of get pop ;

: with-return-regs ( quot -- )
    '[ return-regs init-regs @ ] with-scope ; inline
