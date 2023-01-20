! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks.local
compiler.cfg.utilities kernel make math namespaces sequences ;
IN: compiler.cfg.builder.blocks
SLOT: in-d
SLOT: out-d

: set-basic-block ( basic-block -- )
    dup begin-local-analysis instructions>> building set ;

: end-basic-block ( block -- )
    end-local-analysis building off ;

: (begin-basic-block) ( block -- block' )
    <basic-block> dup set-basic-block [ connect-bbs ] keep ;

: begin-basic-block ( block -- block' )
    dup end-basic-block (begin-basic-block) ;

: emit-trivial-block ( block quot: ( ..a block' -- ..b ) -- block' )
    ##branch, swap begin-basic-block
    [ swap call ] keep
    ##branch, begin-basic-block ; inline

: call-height ( #call -- n )
    [ out-d>> length ] [ in-d>> length ] bi - ;

: emit-call-block ( word height block -- )
    t swap kill-block?<<
    <ds-loc> inc-stack ##call, ;

: emit-trivial-call ( block word height -- block' )
    rot [ emit-call-block ] emit-trivial-block ;

: emit-primitive ( block #call -- block' )
    [ word>> ] [ call-height ] bi emit-trivial-call ;

: begin-branch ( block -- block' )
    height-state [ clone ] change (begin-basic-block) ;

: end-branch ( block/f -- pair/f )
    dup [
        ##branch,
        end-local-analysis
        height-state get clone 2array
    ] when* ;

: with-branch ( block quot: ( ..a block -- ..b block' ) -- pair/f )
    [ [ begin-branch ] dip call end-branch ] with-scope ; inline

: emit-conditional ( block branches -- block'/f )
    swap end-basic-block
    sift [ f ] [
        dup first second height-state set
        [ first ] map
        <basic-block> dup set-basic-block
        [ connect-Nto1-bbs ] keep
    ] if-empty ;
