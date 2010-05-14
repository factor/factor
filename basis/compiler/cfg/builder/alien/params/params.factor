! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.architecture fry kernel layouts math math.order
namespaces sequences vectors ;
IN: compiler.cfg.builder.alien.params

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
    [ ?dummy-stack-params ] [ ?dummy-fp-params ] bi int-regs get pop ;

M: float-rep next-reg-param
    [ ?dummy-stack-params ] [ ?dummy-int-params ] bi float-regs get pop ;

M: double-rep next-reg-param
    [ ?dummy-stack-params ] [ ?dummy-int-params ] bi float-regs get pop ;

GENERIC: reg-class-full? ( reg-class -- ? )

M: stack-params reg-class-full? drop t ;

M: reg-class reg-class-full? get empty? ;

: init-reg-class ( abi reg-class -- )
    [ swap param-regs <reversed> >vector ] keep set ;

: with-param-regs ( abi quot -- )
    '[
        [ int-regs init-reg-class ]
        [ float-regs init-reg-class ] bi
        0 stack-params set
        @
    ] with-scope ; inline
