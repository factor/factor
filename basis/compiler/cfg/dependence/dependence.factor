! Copyright (C) 2009, 2010 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.registers fry kernel
locals namespaces sequences sets sorting math.vectors
make math combinators.short-circuit ;
IN: compiler.cfg.dependence

! Dependence graph construction

SYMBOL: roots
SYMBOL: node-number
SYMBOL: nodes

! Nodes in the dependency graph
! These need to be numbered so that the same instruction
! will get distinct nodes if it occurs multiple times
TUPLE: node
    number insn precedes follows
    children parent
    registers parent-index ;

M: node equal?  [ number>> ] bi@ = ;

M: node hashcode* nip number>> ;

: <node> ( insn -- node )
    node new
        node-number counter >>number
        swap >>insn
        H{ } clone >>precedes
        H{ } clone >>follows ;

: ready? ( node -- ? ) precedes>> assoc-empty? ;

: precedes ( first second -- )
    swap precedes>> conjoin ;

:: add-data-edges ( nodes -- )
    ! This builds up def-use information on the fly, since
    ! we only care about local def-use
    H{ } clone :> definers
    nodes [| node |
        node insn>> defs-vreg [ node swap definers set-at ] when*
        node insn>> uses-vregs [ definers at [ node precedes ] when* ] each
    ] each ;

: make-chain ( nodes -- )
    [ dup rest-slice [ precedes ] 2each ] unless-empty ;

: instruction-chain ( nodes quot -- )
    '[ insn>> @ ] filter make-chain ; inline

UNION: stack-read-write ##peek ##replace ;
UNION: stack-change-height ##inc-d ##inc-r ;
UNION: stack-insn stack-read-write stack-change-height ;

GENERIC: data-stack-insn? ( insn -- ? )
M: object data-stack-insn? drop f ;
M: ##inc-d data-stack-insn? drop t ;
M: stack-read-write data-stack-insn? loc>> ds-loc? ;

: retain-stack-insn? ( insn -- ? )
    dup stack-insn? [ data-stack-insn? not ] [ drop f ] if ;

UNION: ##alien-read
    ##alien-double ##alien-float ##alien-cell ##alien-vector
    ##alien-signed-1 ##alien-signed-2 ##alien-signed-4
    ##alien-unsigned-1 ##alien-unsigned-2 ##alien-unsigned-4 ;

UNION: ##alien-write
    ##set-alien-double ##set-alien-float ##set-alien-cell ##set-alien-vector
    ##set-alien-integer-1 ##set-alien-integer-2 ##set-alien-integer-4 ;

UNION: slot-memory-insn
    ##read ##write ;

UNION: alien-memory-insn
    ##alien-read ##alien-write ;

UNION: string-memory-insn
    ##string-nth ##set-string-nth-fast ;

UNION: alien-call-insn
    ##save-context ##alien-invoke ##alien-indirect ##alien-callback ;

: add-control-edges ( nodes -- )
    {
        [ [ data-stack-insn? ] instruction-chain ]
        [ [ retain-stack-insn? ] instruction-chain ]
        [ [ alien-memory-insn? ] instruction-chain ]
        [ [ slot-memory-insn? ] instruction-chain ]
        [ [ string-memory-insn? ] instruction-chain ]
        [ [ alien-call-insn? ] instruction-chain ]
    } cleave ;

: set-follows ( nodes -- )
    [
        dup precedes>> values [
            follows>> conjoin
        ] with each
    ] each ;

: set-roots ( nodes -- )
    [ ready? ] filter V{ } like roots set ;

: build-dependence-graph ( instructions -- )
    [ <node> ] map {
        [ add-data-edges ]
        [ add-control-edges ]
        [ set-follows ]
        [ nodes set ] ! for assertions later
        [ set-roots ]
    } cleave ;

:: calculate-registers ( node -- registers )
    node children>> [ 0 ] [
        [ [ calculate-registers ] map natural-sort ]
        [ length iota ]
        bi v+ supremum
    ] if-empty
    node insn>> temp-vregs length +
    dup node (>>registers) ;

: data-dependence? ( to from -- ? )
    ! If this takes lots of time, then refactor code
    ! so that nodes store their data dependences
    [ insn>> ] bi@
    [ uses-vregs ] [ defs-vreg ] bi*
    swap member? ;

DEFER: follow-tree

: maybe-cut-node ( node -- ? )
    ! If this node has multiple successors
    ! then it needs to be made into the head of a new tree
    [ precedes>> assoc-size 1 = dup ] keep
    '[ _ dup , follow-tree ] when ;

: follow-tree ( node -- )
    ! This is bogus: it misses nodes that aren't reachable
    ! from the roots because of a control dependence
    dup dup follows>> values
    [ data-dependence? ] with filter
    [ parent>> not ] filter
    [ maybe-cut-node ] filter
    
    [ [ >>parent drop ] with each ]
    [ >>children drop ] 2bi ;

: attach-parent ( node -- )
    drop ;

: make-trees ( -- trees )
    nodes get
    [ [ attach-parent ] each ]
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
    { [ [ length ] bi@ = ] [ set= ] } 2&&
    [ nodes get node-missing-children ] unless ;

: verify-trees ( trees -- trees )
    verify-parents verify-children ;

: build-fan-in-trees ( -- )
    make-trees verify-trees [
        -1/0. >>parent-index 
        calculate-registers drop
    ] each ;
