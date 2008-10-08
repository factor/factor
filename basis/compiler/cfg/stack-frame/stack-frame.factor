! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math.order assocs kernel sequences
combinators make compiler.cfg.instructions
compiler.cfg.instructions.syntax compiler.cfg.registers ;
IN: compiler.cfg.stack-frame

SYMBOL: frame-required?

SYMBOL: spill-counts

: init-stack-frame-builder ( -- )
    frame-required? off
    T{ stack-frame } clone stack-frame set ;

GENERIC: compute-stack-frame* ( insn -- )

: max-stack-frame ( frame1 frame2 -- frame3 )
    {
        [ [ size>> ] bi@ max ]
        [ [ params>> ] bi@ max ]
        [ [ return>> ] bi@ max ]
        [ [ total-size>> ] bi@ max ]
    } 2cleave
    stack-frame boa ;

M: ##stack-frame compute-stack-frame*
    frame-required? on
    stack-frame>> stack-frame [ max-stack-frame ] change ;

M: _spill-integer compute-stack-frame*
    drop frame-required? on ;

M: _spill-float compute-stack-frame*
    drop frame-required? on ;

M: insn compute-stack-frame* drop ;

: compute-stack-frame ( insns -- )
    [ compute-stack-frame* ] each ;

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
        init-stack-frame-builder
        [
            [ compute-stack-frame ]
            [ insert-pro/epilogues ]
            bi
        ] change-instructions
    ] with-scope ;
