! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs cpu.architecture fry kernel layouts locals
math math.order namespaces sequences system vectors ;
IN: compiler.cfg.builder.alien.params

SYMBOL: stack-params
SYMBOLS: stack-param-group-remaining stack-param-group-next ;

TUPLE: register-group count alignment ;

: register-group-count ( register-requirement -- count/f )
    dup register-group? [ count>> ] [ dup integer? [ ] [ drop f ] if ] if ;

GENERIC: alloc-stack-param ( rep -- n )

M: object alloc-stack-param
    dup stack-param-alignment stack-params get swap align
    dup stack-params set
    swap rep-size cell align stack-params +@ ;

M: float-rep alloc-stack-param
    stack-params get swap rep-size
    [ cell align stack-params +@ ] keep
    float-right-align-on-stack? [ + ] [ drop ] if ;

:: alloc-stack-param-group ( rep register-requirement -- n )
    stack-param-group-remaining get zero? [
        register-requirement register-group-count :> count
        count integer? [ count 1 > ] [ f ] if [
            register-requirement register-group?
            [ register-requirement alignment>> ]
            [ rep stack-param-alignment ] if :> alignment
            alignment stack-params get swap align :> offset
            offset rep rep-size count * cell align +
            stack-params set
            count 1 - stack-param-group-remaining set
            offset rep rep-size + stack-param-group-next set
            offset
        ] [ rep alloc-stack-param ] if
    ] [
        stack-param-group-next get
        rep rep-size stack-param-group-next +@
        -1 stack-param-group-remaining +@
    ] if ;

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

:: next-parameter ( vreg rep on-stack? odd-register? -- )
    vreg rep on-stack?
    [ dup dup reg-class-of get odd-register? reg-class-full? ] dip or
    [ odd-register? alloc-stack-param-group stack-values ]
    [ odd-register? swap next-reg-param reg-values ] if
    [ 3array ] dip get push ;

: next-return-reg ( rep -- reg ) reg-class-of get pop ;

: with-return-regs ( quot -- )
    '[ return-regs init-regs @ ] with-scope ; inline
