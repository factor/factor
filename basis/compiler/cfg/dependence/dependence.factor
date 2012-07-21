! Copyright (C) 2009, 2010 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.registers fry kernel
locals namespaces sequences sets sorting math.vectors
make math combinators.short-circuit vectors ;
FROM: namespaces => set ;
IN: compiler.cfg.dependence

! Dependence graph construction

SYMBOL: roots
SYMBOL: node-number
SYMBOL: nodes

SYMBOL: +data+
SYMBOL: +control+

! Nodes in the dependency graph
! These need to be numbered so that the same instruction
! will get distinct nodes if it occurs multiple times
TUPLE: node
    number insn precedes follows
    children parent
    registers parent-index ;

M: node equal? over node? [ [ number>> ] same? ] [ 2drop f ] if ;

M: node hashcode* nip number>> ;

: <node> ( insn -- node )
    node new
        node-number counter >>number
        swap >>insn
        H{ } clone >>precedes
        V{ } clone >>follows ;

: ready? ( node -- ? ) precedes>> assoc-empty? ;

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

: set-follows ( nodes -- )
    [
        dup precedes>> keys [
            follows>> push
        ] with each
    ] each ;

: set-roots ( nodes -- )
    [ ready? ] V{ } filter-as roots set ;

: build-dependence-graph ( instructions -- )
    [ <node> ] map {
        [ add-control-edges ]
        [ add-data-edges ]
        [ set-follows ]
        [ set-roots ]
        [ nodes set ]
    } cleave ;

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

: attach-parent ( node parent -- )
    [ >>parent drop ]
    [ [ ?push ] change-children drop ] 2bi ;

: keys-for ( assoc value -- keys )
    '[ nip _ = ] assoc-filter keys ;

: choose-parent ( node -- )
    ! If a node has control dependences, it has to be a root
    ! Otherwise, choose one of the data dependences for a parent
    dup precedes>> +control+ keys-for empty? [
        dup precedes>> +data+ keys-for [ drop ] [
            first attach-parent
        ] if-empty
    ] [ drop ] if ;

: make-trees ( -- trees )
    nodes get
    [ [ choose-parent ] each ]
    [ [ parent>> not ] filter ] bi ;

ERROR: node-missing-parent trees nodes ;
ERROR: node-missing-children trees nodes ;

: flatten-tree ( node -- nodes )
    [ children>> [ flatten-tree ] map concat ] keep
    suffix ;

: verify-parents ( trees -- trees )
    nodes get over '[ [ parent>> ] [ _ member? ] bi or ] all?
    [ nodes get node-missing-parent ] unless ;

: verify-children ( trees -- trees )
    dup [ flatten-tree ] map concat
    nodes get
    { [ [ length ] same? ] [ set= ] } 2&&
    [ nodes get node-missing-children ] unless ;

: verify-trees ( trees -- trees )
    verify-parents verify-children ;

: build-fan-in-trees ( -- )
    make-trees verify-trees [
        -1/0. >>parent-index 
        calculate-registers drop
    ] each ;
