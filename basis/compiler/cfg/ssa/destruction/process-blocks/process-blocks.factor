! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math math.order arrays
namespaces sequences sorting sets combinators combinators.short-circuit make
compiler.cfg.def-use
compiler.cfg.instructions
compiler.cfg.liveness.ssa
compiler.cfg.dominance
compiler.cfg.ssa.destruction.state
compiler.cfg.ssa.destruction.forest
compiler.cfg.ssa.destruction.interference ;
IN: compiler.cfg.ssa.destruction.process-blocks

! phi-union maps a vreg to the predecessor block
! that carries it to the phi node's block

! unioned-blocks is a set of bb's which defined
! the source vregs above
SYMBOLS: phi-union unioned-blocks ;

:: operand-live-into-phi-node's-block? ( bb src dst -- ? )
    src bb live-in? ;

:: phi-node-is-live-out-of-operand's-block? ( bb src dst -- ? )
    dst src def-of live-out? ;

:: operand-is-phi-node-and-live-into-operand's-block? ( bb src dst -- ? )
    { [ src insn-of ##phi? ] [ src src def-of live-in? ] } 0&& ;

:: operand-being-renamed? ( bb src dst -- ? )
    src processed-names get key? ;

:: two-operands-in-same-block? ( bb src dst -- ? )
    src def-of unioned-blocks get key? ;

: trivial-interference? ( bb src dst -- ? )
    {
        [ operand-live-into-phi-node's-block? ]
        [ phi-node-is-live-out-of-operand's-block? ]
        [ operand-is-phi-node-and-live-into-operand's-block? ]
        [ operand-being-renamed? ]
        [ two-operands-in-same-block? ]
    } 3|| ;

: don't-coalesce ( bb src dst -- )
    2nip processed-name ;

:: trivial-interference ( bb src dst -- )
    dst src bb waiting-for push-at
    src used-by-another get push ;

:: add-to-renaming-set ( bb src dst -- )
    bb src phi-union get set-at
    src def-of unioned-blocks get conjoin ;

: process-phi-operand ( bb src dst -- )
    {
        { [ 2dup eq? ] [ don't-coalesce ] }
        { [ 3dup trivial-interference? ] [ trivial-interference ] }
        [ add-to-renaming-set ]
    } cond ;

: node-is-live-in-of-child? ( node child -- ? )
    [ vreg>> ] [ bb>> ] bi* live-in? ;

: node-is-live-out-of-child? ( node child -- ? )
    [ vreg>> ] [ bb>> ] bi* live-out? ;

:: insert-copy ( bb src dst -- )
    bb src dst trivial-interference
    src phi-union get delete-at ;

:: insert-copy-for-parent ( bb src node dst -- )
    src node vreg>> eq? [ bb src dst insert-copy ] when ;

: insert-copies-for-parent ( ##phi node child -- )
    drop
    [ [ inputs>> ] [ dst>> ] bi ] dip
    '[ _ _ insert-copy-for-parent ] assoc-each ;

: defined-in-same-block? ( node child -- ? ) [ bb>> ] bi@ eq? ;

: add-interference ( ##phi node child -- )
    [ vreg>> ] bi@ 2array , drop ;

: process-df-child ( ##phi node child -- )
    {
        { [ 2dup node-is-live-out-of-child? ] [ insert-copies-for-parent ] }
        { [ 2dup node-is-live-in-of-child? ] [ add-interference ] }
        { [ 2dup defined-in-same-block? ] [ add-interference ] }
        [ 3drop ]
    } cond ;

: process-df-node ( ##phi node -- )
    dup children>>
    [ [ process-df-child ] with with each ]
    [ nip [ process-df-node ] with each ]
    3bi ;

: process-phi-union ( ##phi dom-forest -- )
    [ process-df-node ] with each ;

: add-local-interferences ( ##phi -- )
    [ phi-union get ] dip dst>> '[ drop _ 2array , ] assoc-each ;

: compute-local-interferences ( ##phi -- pairs )
    [
        [ phi-union get keys compute-dom-forest process-phi-union ]
        [ add-local-interferences ]
        bi
    ] { } make ;

:: insert-copies-for-interference ( ##phi src -- )
    ##phi inputs>> [| bb src' |
        src src' eq? [ bb src ##phi dst>> insert-copy ] when
    ] assoc-each ;

: process-local-interferences ( ##phi pairs -- )
    [
        first2 2dup interferes?
        [ drop insert-copies-for-interference ] [ 3drop ] if
    ] with each ;

: add-renaming-set ( ##phi -- )
    [ phi-union get ] dip dst>> renaming-sets get set-at
    phi-union get [ drop processed-name ] assoc-each ;

: process-phi ( ##phi -- )
    H{ } clone phi-union set
    H{ } clone unioned-blocks set
    [ [ inputs>> ] [ dst>> ] bi '[ _ process-phi-operand ] assoc-each ]
    [ dup compute-local-interferences process-local-interferences ]
    [ add-renaming-set ]
    tri ;

: process-block ( bb -- )
    instructions>>
    [ dup ##phi? [ process-phi t ] [ drop f ] if ] all? drop ;
