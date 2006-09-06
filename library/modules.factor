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
    >r module-name module-def [ file-modified ] keep r>
    set-hash ;

: record-modified ( module -- )
    dup module-files
    [ dup resource-path file-modified ] map>hash
    2dup record-def-modified
    swap set-module-modified ;

: modified? ( file module -- ? )
    dupd module-modified hash
    swap resource-path file-modified number= not ;

: module-paths ( name seq -- newseq )
    [ "/" swap append3 ] map-with ;

C: module ( name files tests -- module )
    [ >r >r over r> module-paths r> set-module-tests ] keep
    [ >r dupd module-paths r> set-module-files ] keep
    [ set-module-name ] keep ;

: module modules get hash ;

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

: provide ( name files tests -- )
    [ process-files ] 2apply <module> dup record-modified
    [ module-files run-resources ] keep
    dup module-name modules get set-hash ;

: test-module ( name -- ) module module-tests run-tests ;

: test-modules ( -- )
    modules get hash-values
    [ module-tests ] map concat run-tests ;

: modules. ( -- )
    modules get hash-keys natural-sort [ print ] each ;

: reload-module ( module -- )
    dup module-name module-def over modified? [
        module-name load-module
    ] [
        dup dup module-files [ swap modified? ] subset-with
        run-resources
        record-modified
    ] if ;

: reload-modules ( -- )
    modules get hash-values [ reload-module ] each
    do-parse-hook ;
