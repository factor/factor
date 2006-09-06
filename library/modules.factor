! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: compiler hashtables io kernel namespaces parser sequences
test words strings arrays ;

TUPLE: module name files tests ;

: module-paths ( name seq -- newseq )
    [ "/" swap append3 ] map-with ;

C: module ( name files tests -- module )
    [ >r >r over r> module-paths r> set-module-tests ] keep
    [ >r dupd module-paths r> set-module-files ] keep
    [ set-module-name ] keep ;

: module-def ( name -- path )
    dup ".factor" append dup resource-path exists?
    [ nip ] [ drop "/load.factor" append ] if ;

SYMBOL: modules

: module modules get hash ;

: load-module ( name -- )
    [
        "Loading module " write dup write "..." print
        [ dup module-def run-resource ] assert-depth drop
    ] no-parse-hook ;

: (require) ( name -- )
    dup module [ drop ] [ load-module ] if ;

: require ( name -- ) (require) recompile ;

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
    [ process-files ] 2apply <module>
    [ module-files run-resources ] keep
    dup module-name modules get set-hash ;

: test-module ( name -- ) module module-tests run-resources ;

: test-modules ( -- ) modules hash-keys [ test-module ] each ;

: modules. ( -- )
    modules get hash-keys natural-sort [ print ] each ;
