! PPC64 unnamed floating arguments also occupy the integer parameter bank.
USING: accessors arrays assocs compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params cpu.architecture kernel layouts locals
math namespaces sequences system vectors ;
IN: cpu.ppc.64.varargs

SYMBOLS: ppc64-argument-index ppc64-named-count ppc64-unnamed-vregs ;

! Parameter types are unboxed in declaration order; only their data-stack
! indices run backwards. Track the declaration index for the named boundary.
M: ppc64 prepare-abi-call
    [ drop 0 1array ppc64-argument-index set ]
    [ varargs?>> ppc64-named-count set ] bi
    H{ } clone ppc64-unnamed-vregs set ;

:: ppc64-record-argument ( vregs reps -- vregs reps )
    ppc64-argument-index get :> cursor
    cursor [
        cursor first dup 1 + cursor set-first :> index
        ppc64-named-count get :> named
        named integer? [ index named >= [
            vregs [ t swap ppc64-unnamed-vregs get set-at ] each
        ] when ] when
    ] when
    vregs reps ;

M: ppc64 unbox-scalar-parameter
    call-next-method ppc64-record-argument ;

M: ppc64 unbox-struct-parameter
    call-next-method ppc64-record-argument ;

! The fourth field survives operand renaming and names the byte offset of
! this floating payload in the parameter save area. Several HFA fields can
! share one GP word; the emitter writes all fields before loading that word.
:: ppc64-shadow-reg-input ( vreg rep reg offset -- input )
    vreg rep reg 3array
    ppc64-unnamed-vregs get
    [ vreg swap key? ] [ f ] if* [ offset suffix ] when ;

:: ppc64-alloc-float-parameter ( vreg rep on-stack? odd-register? size -- handled? )
    rep reg-class-of float-regs = [
        stack-params get :> offset
        on-stack? float-regs get empty? or [
            vreg rep rep size alloc-parameter-stack-slot size 4array stack-values get push
        ] [
            odd-register? rep next-reg-param :> reg
            offset rep float-rep? float-right-align-on-stack? and [ 4 + ] when :> payload-offset
            vreg rep reg payload-offset ppc64-shadow-reg-input reg-values get push
        ] if
        t
    ] [ f ] if ;

M: ppc64 alloc-abi-parameter ppc64-alloc-float-parameter ;
