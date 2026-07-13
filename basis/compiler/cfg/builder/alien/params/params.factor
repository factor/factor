! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs cpu.architecture fry generalizations kernel
layouts locals math math.order namespaces sequences
sequences.generalizations system vectors ;
IN: compiler.cfg.builder.alien.params

SYMBOL: stack-params
SYMBOLS: stack-param-group-remaining stack-param-group-next ;
SYMBOL: compact-stack-params?

TUPLE: register-group count alignment ;

: register-group-count ( register-requirement -- count/f )
    dup register-group? [ count>> ] [ dup integer? [ ] [ drop f ] if ] if ;

: param-natural-size ( rep-tuple -- size )
    dup length 3 > [ fourth ] [ drop cell ] if ;

: param-signed? ( rep-tuple -- ? )
    dup length 4 > [ 4 swap nth ] [ drop f ] if ;

GENERIC#: alloc-stack-param 1 ( rep size -- n )

M:: object alloc-stack-param ( rep size -- n )
    compact-stack-params? get [
        stack-params get size align dup size + stack-params set
    ] [
        rep stack-param-alignment stack-params get swap align
        dup stack-params set
        rep rep-size cell align stack-params +@
    ] if ;

M:: float-rep alloc-stack-param ( rep size -- n )
    compact-stack-params? get [
        stack-params get size align dup size + stack-params set
    ] [
        stack-params get rep rep-size
        [ cell align stack-params +@ ] keep
        float-right-align-on-stack? [ + ] [ drop ] if
    ] if ;

:: alloc-stack-param-group ( rep register-requirement size -- n )
    stack-param-group-remaining get zero? [
        register-requirement register-group-count :> count
        count integer? [ count 1 > ] [ f ] if [
            register-requirement register-group?
            [ register-requirement alignment>> ]
            [ rep stack-param-alignment ] if :> alignment
            alignment stack-params get swap align :> offset
            count 1 - stack-param-group-remaining set
            offset size + dup stack-param-group-next set stack-params set
            offset
        ] [ rep size alloc-stack-param ] if
    ] [
        stack-param-group-next get :> offset
        size stack-param-group-next +@
        stack-param-group-next get stack-params set
        -1 stack-param-group-remaining +@
        stack-param-group-remaining get zero?
        compact-stack-params? get not and [
            stack-params get cell align stack-params set
        ] when
        offset
    ] if ;

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
    [ drop t = [
        int-regs get last even?
        [ int-regs get pop* ] when
    ] when ]
    2tri int-regs get pop ;

M: object next-reg-param
    nip [ ?dummy-stack-params ] [ ?dummy-int-params ] bi
    float-regs get pop ;

:: align-register-group ( reg-class register-requirement -- )
    register-requirement register-group? [
        reg-class int-regs get eq?
        os macos? not and
        register-requirement alignment>> cell > and
        reg-class length odd? and
        [ reg-class pop* ] when
    ] when ;

:: reg-class-full? ( reg-class register-requirement -- ? )
    reg-class register-requirement align-register-group
    register-requirement register-group-count :> count
    count
    [ reg-class length count < ]
    [ reg-class length 1 = register-requirement and ] if
    [ reg-class delete-all ] when
    reg-class empty? ;

: init-reg-class ( abi reg-class -- )
    [ swap param-regs at <reversed> >vector ] keep set ;

: init-regs ( regs -- )
    [ <reversed> >vector swap set ] assoc-each ;

SYMBOLS: stack-values reg-values ;

:: next-parameter ( vreg rep on-stack? register-requirement size signed? -- )
    rep reg-class-of get register-requirement reg-class-full? on-stack? or [
        rep register-requirement size alloc-stack-param-group :> offset
        vreg rep offset size signed? 5 narray stack-values get push
    ] [
        register-requirement rep next-reg-param :> reg
        vreg rep reg 3array reg-values get push
    ] if ;

: next-return-reg ( rep -- reg ) reg-class-of get pop ;

: with-return-regs ( quot -- )
    '[ return-regs init-regs @ ] with-scope ; inline
