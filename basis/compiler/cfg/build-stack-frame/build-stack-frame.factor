! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math.order assocs kernel sequences
combinators make classes words cpu.architecture
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stack-frame ;
IN: compiler.cfg.build-stack-frame

SYMBOL: frame-required?

SYMBOL: spill-counts

GENERIC: compute-stack-frame* ( insn -- )

: request-stack-frame ( stack-frame -- )
    stack-frame [ max-stack-frame ] change ;

M: ##stack-frame compute-stack-frame*
    frame-required? on
    stack-frame>> request-stack-frame ;

M: ##call compute-stack-frame*
    word>> sub-primitive>> [ frame-required? on ] unless ;

M: _gc compute-stack-frame*
    frame-required? on
    stack-frame new swap gc-root-size>> >>gc-root-size
    request-stack-frame ;

M: _spill-counts compute-stack-frame*
    counts>> stack-frame get (>>spill-counts) ;

M: insn compute-stack-frame*
    class frame-required? word-prop [
        frame-required? on
    ] when ;

\ _spill t frame-required? set-word-prop
\ ##fixnum-add t frame-required? set-word-prop
\ ##fixnum-sub t frame-required? set-word-prop
\ ##fixnum-mul t frame-required? set-word-prop
\ ##fixnum-add-tail f frame-required? set-word-prop
\ ##fixnum-sub-tail f frame-required? set-word-prop
\ ##fixnum-mul-tail f frame-required? set-word-prop

: compute-stack-frame ( insns -- )
    frame-required? off
    T{ stack-frame } clone stack-frame set
    [ compute-stack-frame* ] each
    stack-frame get dup stack-frame-size >>total-size drop ;

GENERIC: insert-pro/epilogues* ( insn -- )

M: ##stack-frame insert-pro/epilogues* drop ;

M: ##prologue insert-pro/epilogues*
    drop frame-required? get [ stack-frame get _prologue ] when ;

M: ##epilogue insert-pro/epilogues*
    drop frame-required? get [ stack-frame get _epilogue ] when ;

M: insn insert-pro/epilogues* , ;

: insert-pro/epilogues ( insns -- insns )
    [ [ insert-pro/epilogues* ] each ] { } make ;

: build-stack-frame ( mr -- mr )
    [
        [
            [ compute-stack-frame ]
            [ insert-pro/epilogues ]
            bi
        ] change-instructions
    ] with-scope ;
