! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel make math namespaces sequences
compiler.cfg compiler.cfg.instructions compiler.cfg.stacks
compiler.cfg.stacks.local ;
IN: compiler.cfg.builder.blocks

: set-basic-block ( basic-block -- )
    [ basic-block set ] [ instructions>> building set ] bi
    begin-local-analysis ;

: initial-basic-block ( -- )
    <basic-block> set-basic-block ;

: end-basic-block ( -- )
    basic-block get [ end-local-analysis ] when
    building off
    basic-block off ;

: (begin-basic-block) ( -- )
    <basic-block>
    basic-block get [ dupd successors>> push ] when*
    set-basic-block ;

: begin-basic-block ( -- )
    basic-block get [ end-local-analysis ] when
    (begin-basic-block) ;

: emit-trivial-block ( quot -- )
    building get empty? [ ##branch begin-basic-block ] unless
    call
    ##branch begin-basic-block ; inline

: call-height ( #call -- n )
    [ out-d>> length ] [ in-d>> length ] bi - ;

: emit-primitive ( node -- )
    [
        [ word>> ##call ]
        [ call-height adjust-d ] bi
    ] emit-trivial-block ;

: begin-branch ( -- ) clone-current-height (begin-basic-block) ;

: end-branch ( -- pair/f )
    ! pair is { final-bb final-height }
    basic-block get dup [
        ##branch
        end-local-analysis
        current-height get clone 2array
    ] when ;

: with-branch ( quot -- pair/f )
    [ begin-branch call end-branch ] with-scope ; inline

: set-successors ( branches -- )
    ! Set the successor of each branch's final basic block to the
    ! current block.
    basic-block get dup [
        '[ [ [ _ ] dip first successors>> push ] when* ] each
    ] [ 2drop ] if ;

: merge-heights ( branches -- )
    ! If all elements are f, that means every branch ended with a backward
    ! jump so the height is irrelevant since this block is unreachable.
    [ ] find nip [ second current-height set ] [ end-basic-block ] if* ;

: emit-conditional ( branches -- )
    ! branchies is a sequence of pairs as above
    end-basic-block
    [ merge-heights begin-basic-block ]
    [ set-successors ]
    bi ;

