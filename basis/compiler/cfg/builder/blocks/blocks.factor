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

: (begin-basic-block) ( block -- block' )
    <basic-block> swap [ over connect-bbs ] when* dup set-basic-block ;

: begin-basic-block ( block -- block' )
    dup [ end-local-analysis ] when* (begin-basic-block) ;

: emit-trivial-block ( block quot: ( ..a block' -- ..b ) -- block' )
    ##branch, swap begin-basic-block
    [ swap call ] keep
    ##branch, begin-basic-block ; inline

: make-kill-block ( block -- )
    t swap kill-block?<< ;

: call-height ( #call -- n )
    [ out-d>> length ] [ in-d>> length ] bi - ;

: emit-call-block ( word height block -- )
    make-kill-block adjust-d ##call, ;

: emit-primitive ( block node -- block' )
    [ word>> ] [ call-height ] bi rot
    [ emit-call-block ] emit-trivial-block ;

: begin-branch ( block -- block' )
    height-state [ clone-height-state ] change (begin-basic-block) ;

: end-branch ( block -- pair/f )
    dup [
        ##branch,
        end-local-analysis
        height-state get clone-height-state 2array
    ] when* ;

: with-branch ( block quot: ( ..a block -- ..b block' ) -- pair/f )
    [ [ begin-branch ] dip call end-branch ] with-scope ; inline

: emit-conditional ( block branches -- block' )
    swap end-basic-block
    sift [ f ] [
        dup first second height-state set
        [ first ] map
        f begin-basic-block
        [ connect-Nto1-bbs ] keep
    ] if-empty ;
