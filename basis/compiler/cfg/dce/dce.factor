! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sets kernel namespaces sequences
compiler.cfg.instructions compiler.cfg.def-use ;
IN: compiler.cfg.dce

! Maps vregs to sequences of vregs
SYMBOL: liveness-graph

! vregs which participate in side effects and thus are always live
SYMBOL: live-vregs

: init-dead-code ( -- )
    H{ } clone liveness-graph set
    H{ } clone live-vregs set ;

GENERIC: update-liveness-graph ( insn -- )

M: ##flushable update-liveness-graph
    [ uses-vregs ] [ dst>> ] bi liveness-graph get set-at ;

: record-live ( vregs -- )
    [
        dup live-vregs get key? [ drop ] [
            [ live-vregs get conjoin ]
            [ liveness-graph get at record-live ]
            bi
        ] if
    ] each ;

M: insn update-liveness-graph uses-vregs record-live ;

GENERIC: live-insn? ( insn -- ? )

M: ##flushable live-insn? dst>> live-vregs get key? ;

M: insn live-insn? drop t ;

: eliminate-dead-code ( rpo -- )
    init-dead-code
    [ [ instructions>> [ update-liveness-graph ] each ] each ]
    [ [ [ [ live-insn? ] filter ] change-instructions drop ] each ]
    bi ;