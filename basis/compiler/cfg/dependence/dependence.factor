! Copyright (C) 2009, 2010 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.registers fry kernel locals
namespaces sequences sorting make math math.vectors sets vectors ;
FROM: namespaces => set ;
IN: compiler.cfg.dependence

SYMBOLS: +data+ +control+ ;

TUPLE: node < identity-tuple insn precedes children registers parent-index ;

: <node> ( insn -- node )
    node new swap >>insn H{ } clone >>precedes ;

:: precedes ( first second how -- )
    how second first precedes>> set-at ;

:: add-data-edges ( nodes -- )
    ! This builds up def-use information on the fly, since
    ! we only care about local def-use
    H{ } clone :> definers
    nodes [| node |
        node insn>> defs-vregs [ node swap definers set-at ] each
        node insn>> uses-vregs [ definers at [ node +data+ precedes ] when* ] each
    ] each ;

UNION: stack-insn ##peek ##replace ##replace-imm ;

UNION: slot-insn
    ##read ##write ;

UNION: memory-insn
    ##allot
    ##load-memory ##load-memory-imm
    ##store-memory ##store-memory-imm
    ##write-barrier ##write-barrier-imm
    alien-call-insn
    slot-insn ;

: chain ( node var -- )
    dup get [
        pick +control+ precedes
    ] when*
    set ;

GENERIC: add-control-edge ( node insn -- )

M: stack-insn add-control-edge loc>> chain ;
M: memory-insn add-control-edge drop memory-insn chain ;
M: object add-control-edge 2drop ;

: add-control-edges ( nodes -- )
    [ [ dup insn>> add-control-edge ] each ] with-scope ;

: build-dependence-graph ( nodes -- )
    [ add-control-edges ] [ add-data-edges ] bi ;

! Sethi-Ulmann numbering
:: calculate-registers ( node -- registers )
    node children>> [ 0 ] [
        [ [ calculate-registers ] map natural-sort ]
        [ length iota ]
        bi v+ supremum
    ] if-empty
    node insn>> temp-vregs length +
    dup node registers<< ;

! Constructing fan-in trees
: keys-for ( assoc value -- keys )
    '[ nip _ = ] assoc-filter keys ;

: attach-parent ( child parent -- )
    [ ?push ] change-children drop ;

! Arbitrary tie-breaker to make the ordering deterministic.
: tiebreak-parents ( nodes -- node/f )
    [ f ] [ [ insn>> insn#>> ] infimum-by ] if-empty ;

: select-parent ( precedes -- parent/f )
    ! If a node has no control dependencies, then its parent is the tie-breaked
    ! data dependency, if it has one. Otherwise it is a root node.
    [ +control+ keys-for empty? ] [ +data+ keys-for tiebreak-parents ] bi f ? ;

: maybe-set-parent ( node -- )
    dup precedes>> select-parent [ attach-parent ] [ drop ] if* ;

: initialize-scores ( trees -- )
    [ -1/0. >>parent-index calculate-registers drop ] each ;

: build-fan-in-trees ( nodes -- )
    dup [ maybe-set-parent ] each
    dup [ children>> ] map concat diff initialize-scores ;
