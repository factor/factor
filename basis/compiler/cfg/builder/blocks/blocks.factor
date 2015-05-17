! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.stacks compiler.cfg.stacks.local compiler.cfg.utilities fry kernel
make math namespaces sequences ;
SLOT: in-d
SLOT: out-d
IN: compiler.cfg.builder.blocks

: set-basic-block ( basic-block -- )
    [ basic-block set ]
    [ instructions>> building set ]
    [ begin-local-analysis ] tri ;

: end-basic-block ( -- )
    basic-block get [ end-local-analysis ] when*
    building off
    basic-block off ;

: (begin-basic-block) ( -- )
    <basic-block> basic-block get [ over connect-bbs ] when* set-basic-block ;

: begin-basic-block ( -- )
    basic-block get [ end-local-analysis ] when*
    (begin-basic-block) ;

: emit-trivial-block ( quot -- )
    ##branch, begin-basic-block
    call
    ##branch, begin-basic-block ; inline

: make-kill-block ( -- )
    basic-block get t >>kill-block? drop ;

: call-height ( #call -- n )
    [ out-d>> length ] [ in-d>> length ] bi - ;

: emit-call-block ( word height -- )
    adjust-d ##call, make-kill-block ;

: emit-primitive ( node -- )
    [
        [ word>> ] [ call-height ] bi emit-call-block
    ] emit-trivial-block ;

: begin-branch ( -- )
    height-state [ clone-height-state ] change
    (begin-basic-block) ;

: end-branch ( -- pair/f )
    basic-block get dup [
        ##branch,
        end-local-analysis
        height-state get clone-height-state 2array
    ] when* ;

: with-branch ( quot -- pair/f )
    [ begin-branch call end-branch ] with-scope ; inline

: emit-conditional ( branches -- )
    ! branches is a sequence of pairs as above
    end-basic-block
    sift [
        dup first second height-state set
        begin-basic-block
        [ first ] map basic-block get connect-Nto1-bbs
    ] unless-empty ;
