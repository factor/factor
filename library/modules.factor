! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences
test words strings arrays math ;

SYMBOL: modules

TUPLE: module name files tests modified ;

: module-def ( name -- path )
    dup ".factor" append dup resource-path exists?
    [ nip ] [ drop "/load.factor" append ] if ;

: record-def-modified ( module hash -- )
    >r module-name module-def
    [ resource-path file-modified ] keep
    r> set-hash ;

: record-modified ( module -- )
    dup module-files
    [ dup resource-path file-modified ] map>hash
    2dup record-def-modified
    swap set-module-modified ;

: modified? ( file module -- ? )
    dupd module-modified hash
    swap resource-path file-modified < ;

: prefix-paths ( name seq -- newseq )
    [ "/" swap append3 ] map-with ;

C: module ( name files tests -- module )
    [ >r >r over r> prefix-paths r> set-module-tests ] keep
    [ >r dupd prefix-paths r> set-module-files ] keep
    [ set-module-name ] keep ;

: module modules get assoc ;

: load-module ( name -- )
    [
        "Loading module " write dup write "..." print
        [ dup module-def run-resource ] assert-depth drop
    ] no-parse-hook ;

: require ( name -- )
    dup module [ drop ] [ load-module ] if do-parse-hook ;

: run-resources ( seq -- )
    [
        bootstrapping? get
        [ parse-resource % ] [ run-resource ] ? each
    ] no-parse-hook ;

: process-files ( seq -- newseq )
    [ dup string? [ [ t ] 2array ] when ] map
    [ second call ] subset
    [ first ] map ;

: add-module ( module -- )
    dup module-name swap 2array modules get push ;

: remove-module ( name -- )
    module [ modules get delete ] when* ;

: provide ( name files tests -- )
    pick remove-module
    [ process-files ] 2apply <module> dup record-modified
    [ module-files run-resources ] keep
    add-module ;

: test-module ( name -- ) module module-tests run-tests ;

: all-modules ( -- seq ) modules get [ second ] map ;

: all-module-names ( -- seq ) modules get [ first ] map ;

: test-modules ( -- )
    all-modules [ module-tests ] map concat run-tests ;

: modules. ( -- )
    all-module-names natural-sort [ print ] each ;

: reload-module ( module -- )
    dup module-name module-def over modified? [
        module-name load-module
    ] [
        dup dup module-files [ swap modified? ] subset-with
        run-resources
        record-modified
    ] if ;

: reload-modules ( -- )
    all-modules [ reload-module ] each do-parse-hook ;

: reset-modified ( -- ) all-modules [ record-modified ] each ;
