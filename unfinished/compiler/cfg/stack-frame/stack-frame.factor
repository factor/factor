! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math.order assocs kernel sequences
make compiler.cfg.instructions compiler.cfg.instructions.syntax
compiler.cfg.registers ;
IN: compiler.cfg.stack-frame

SYMBOL: frame-required?

SYMBOL: frame-size

SYMBOL: spill-counts

: init-stack-frame-builder ( -- )
    frame-required? off
    0 frame-size set ;

GENERIC: compute-frame-size* ( insn -- )

M: ##frame-required compute-frame-size*
    frame-required? on
    n>> frame-size [ max ] change ;

M: _spill-integer compute-frame-size*
    drop frame-required? on ;

M: _spill-float compute-frame-size*
    drop frame-required? on ;

M: insn compute-frame-size* drop ;

: compute-frame-size ( insns -- )
    [ compute-frame-size* ] each ;

GENERIC: insert-pro/epilogues* ( insn -- )

M: ##frame-required insert-pro/epilogues* drop ;

M: ##prologue insert-pro/epilogues*
    drop frame-required? get [ _prologue ] when ;

M: ##epilogue insert-pro/epilogues*
    drop frame-required? get [ _epilogue ] when ;

M: insn insert-pro/epilogues* , ;

: insert-pro/epilogues ( insns -- insns )
    [ [ insert-pro/epilogues* ] each ] { } make ;

: build-stack-frame ( mr -- mr )
    [
        init-stack-frame-builder
        [
            [ compute-frame-size ]
            [ insert-pro/epilogues ]
            bi
        ] change-instructions
        frame-size get >>frame-size
    ] with-scope ;
