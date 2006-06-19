! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences words ;

TUPLE: module name files tests ;

: module-path ( name -- path )
    "/contrib/" swap append ;

: module-paths ( name seq -- seq )
    >r module-path r> [ "/" swap append3 ] map-with ;

C: module ( name files tests -- module )
    [ >r >r over r> module-paths r> set-module-tests ] keep
    [ >r dupd module-paths r> set-module-files ] keep
    [ set-module-name ] keep ;

: module-def ( name -- path )
    module-path dup ".factor" append dup resource-path exists?
    [ nip ] [ drop "/load.factor" append ] if ;

SYMBOL: modules

H{ } clone modules set-global

: module modules get hash ;

: require ( name -- )
    dup module [
        drop
    ] [
        "Loading module " write dup write "..." print
        module-def run-resource
    ] if ;

: run-resources ( seq -- )
    bootstrapping? get
    [ parse-resource % ] [ run-resource ] ? each ;

: load-module ( module -- ) module-files run-resources ;

: provide ( name files tests -- )
    <module> dup load-module
    dup module-name modules get set-hash ;

: reload-module ( name -- ) module load-module ;

: test-module ( name -- ) module module-tests run-resources ;
