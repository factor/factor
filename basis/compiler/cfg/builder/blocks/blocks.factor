! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.stacks compiler.cfg.stacks.local kernel make math
namespaces sequences ;
SLOT: in-d
SLOT: out-d
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
    ##branch, begin-basic-block
    call
    ##branch, begin-basic-block ; inline

: make-kill-block ( -- )
    basic-block get t >>kill-block? drop ;

: call-height ( #call -- n )
    [ out-d>> length ] [ in-d>> length ] bi - ;

: emit-primitive ( node -- )
    [
        [ word>> ##call, ]
        [ call-height adjust-d ] bi
        make-kill-block
    ] emit-trivial-block ;

: begin-branch ( -- ) clone-current-height (begin-basic-block) ;

: end-branch ( -- pair/f )
    ! pair is { final-bb final-height }
    basic-block get dup [
        ##branch,
        end-local-analysis
        current-height get clone 2array
    ] when ;

: with-branch ( quot -- pair/f )
    [ begin-branch call end-branch ] with-scope ; inline

: set-successors ( branches -- )
    ! Set the successor of each branch's final basic block to the
    ! current block.
    [ [ [ basic-block get ] dip first successors>> push ] when* ] each ;

: emit-conditional ( branches -- )
    ! branches is a sequence of pairs as above
    end-basic-block
    dup [ ] find nip dup [
        second current-height set
        begin-basic-block
        set-successors
    ] [ 2drop ] if ;
