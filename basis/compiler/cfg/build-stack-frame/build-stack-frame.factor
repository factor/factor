! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math.order assocs kernel sequences
combinators make classes words cpu.architecture layouts
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stack-frame ;
IN: compiler.cfg.build-stack-frame

SYMBOL: frame-required?

GENERIC: compute-stack-frame* ( insn -- )

: request-stack-frame ( stack-frame -- )
    frame-required? on
    stack-frame [ max-stack-frame ] change ;

UNION: stack-frame-insn
    ##alien-invoke
    ##alien-indirect
    ##alien-callback ;

M: stack-frame-insn compute-stack-frame*
    stack-frame>> request-stack-frame ;

M: ##call compute-stack-frame*
    word>> sub-primitive>> [ frame-required? on ] unless ;

M: ##gc compute-stack-frame*
    frame-required? on
    stack-frame new swap tagged-values>> length cells >>gc-root-size
    request-stack-frame ;

M: _spill-area-size compute-stack-frame*
    n>> stack-frame get (>>spill-area-size) ;

M: insn compute-stack-frame*
    class frame-required? word-prop [
        frame-required? on
    ] when ;

\ _spill t frame-required? set-word-prop
\ ##unary-float-function t frame-required? set-word-prop
\ ##binary-float-function t frame-required? set-word-prop

: compute-stack-frame ( insns -- )
    frame-required? off
    stack-frame new stack-frame set
    [ compute-stack-frame* ] each
    stack-frame get dup stack-frame-size >>total-size drop ;

GENERIC: insert-pro/epilogues* ( insn -- )

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
