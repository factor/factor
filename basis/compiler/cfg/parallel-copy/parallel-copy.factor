! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs compiler.cfg.hats compiler.cfg.instructions
deques dlists fry kernel locals namespaces sequences
sets hashtables ;
IN: compiler.cfg.parallel-copy

SYMBOLS: mapping dependency-graph work-list ;

: build-dependency-graph ( mapping -- deps )
    H{ } clone [ '[ _ conjoin-at ] assoc-each ] keep ;

: build-work-list ( mapping graph -- work-list )
    [ keys ] dip '[ _ key? not ] filter <dlist> [ push-all-front ] keep ;

: init ( mapping -- work-list )
    dup build-dependency-graph
    [ [ >hashtable mapping set ] [ dependency-graph set ] bi* ]
    [ build-work-list dup work-list set ]
    2bi ;

:: retire-copy ( dst src -- )
    dst mapping get delete-at
    src dependency-graph get at :> deps
    dst deps delete-at
    deps assoc-empty? [
        src mapping get key? [
            src work-list get push-front
        ] when
    ] when ;

: perform-copy ( dst -- )
    dup mapping get at
    [ ##copy ] [ retire-copy ] 2bi ;

: break-cycle ( dst src -- dst src' )
    [ i dup ] dip ##copy ;

: break-cycles ( mapping -- )
    >alist [ break-cycle ] { } assoc-map-as [ ##copy ] assoc-each ;

: parallel-copy ( mapping -- )
    [
        init [ perform-copy ] slurp-deque
        mapping get dup assoc-empty? [ drop ] [ break-cycles ] if
    ] with-scope ;