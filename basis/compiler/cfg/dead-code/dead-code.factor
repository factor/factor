! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sets kernel namespaces sequences
compiler.cfg.instructions compiler.cfg.def-use ;
IN: compiler.cfg.dead-code

! Dead code elimination -- assumes compiler.cfg.alias-analysis
! has already run.

! Maps vregs to sequences of vregs
SYMBOL: liveness-graph

! vregs which participate in side effects and thus are always live
SYMBOL: live-vregs

! mapping vregs to stack locations
SYMBOL: vregs>locs

: init-dead-code ( -- )
    H{ } clone liveness-graph set
    H{ } clone live-vregs set
    H{ } clone vregs>locs set ;

GENERIC: compute-liveness ( insn -- )

M: ##flushable compute-liveness
    [ uses-vregs ] [ dst>> ] bi liveness-graph get set-at ;

M: ##peek compute-liveness
    [ [ loc>> ] [ dst>> ] bi vregs>locs get set-at ]
    [ call-next-method ]
    bi ;

: live-replace? ( ##replace -- ? )
    [ src>> vregs>locs get at ] [ loc>> ] bi = not ;

M: ##replace compute-liveness
    dup live-replace? [ call-next-method ] [ drop ] if ;

: record-live ( vregs -- )
    [
        dup live-vregs get key? [ drop ] [
            [ live-vregs get conjoin ]
            [ liveness-graph get at record-live ]
            bi
        ] if
    ] each ;

M: insn compute-liveness uses-vregs record-live ;

GENERIC: live-insn? ( insn -- ? )

M: ##flushable live-insn? dst>> live-vregs get key? ;

M: ##replace live-insn? live-replace? ;

M: insn live-insn? drop t ;

: eliminate-dead-code ( insns -- insns' )
    init-dead-code
    [ [ compute-liveness ] each ] [ [ live-insn? ] filter ] bi ;
