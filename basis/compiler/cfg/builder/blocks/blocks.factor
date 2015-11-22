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

: end-basic-block ( block -- )
    [ end-local-analysis ] when* building off basic-block off ;

: (begin-basic-block) ( block -- )
    <basic-block> swap [ over connect-bbs ] when* set-basic-block ;

: begin-basic-block ( block -- )
    dup [ end-local-analysis ] when* (begin-basic-block) ;

: emit-trivial-block ( quot -- )
    ##branch, basic-block get begin-basic-block
    basic-block get [ swap call ] keep
    ##branch, begin-basic-block ; inline

: make-kill-block ( block -- )
    t swap kill-block?<< ;

: call-height ( #call -- n )
    [ out-d>> length ] [ in-d>> length ] bi - ;

: emit-call-block ( word height block -- )
    make-kill-block adjust-d ##call, ;

: emit-primitive ( node -- )
    [ word>> ] [ call-height ] bi
    [ emit-call-block ] emit-trivial-block ;

: begin-branch ( block -- )
    height-state [ clone-height-state ] change (begin-basic-block) ;

: end-branch ( block -- pair/f )
    dup [
        ##branch,
        end-local-analysis
        height-state get clone-height-state 2array
    ] when* ;

: with-branch ( quot -- pair/f )
    [
        basic-block get begin-branch
        call
        basic-block get end-branch
    ] with-scope ; inline

: emit-conditional ( branches block -- )
    ! branches is a sequence of pairs as above
    end-basic-block
    sift [
        dup first second height-state set
        basic-block get begin-basic-block
        [ first ] map basic-block get connect-Nto1-bbs
    ] unless-empty ;
