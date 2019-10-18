! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences
test words strings arrays math ;

SYMBOL: modules

TUPLE: module name files tests ;

: module-def ( name -- path )
    "resource:" over ".factor" append3
    dup ?resource-path exists? [
        nip
    ] [
        drop "resource:" swap "/load.factor" append3
    ] if ;

: prefix-paths ( name seq -- newseq )
    [ path+ "resource:" swap append ] map-with ;

C: module ( name files tests -- module )
    [ >r >r over r> prefix-paths r> set-module-tests ] keep
    [ >r dupd prefix-paths r> set-module-files ] keep
    [ set-module-name ] keep ;

: module modules get assoc ;

: load-module ( name -- )
    [
        "Loading module " write dup write "..." print
        [ dup module-def run-file ] assert-depth drop
    ] no-parse-hook ;

: require ( name -- )
    dup module [ drop ] [ load-module ] if do-parse-hook ;

: process-files ( seq -- newseq )
    [ dup string? [ [ t ] 2array ] when ] map
    [ second call ] subset
    [ first ] map ;

: add-module ( module -- )
    dup module-name swap 2array modules get push ;

: remove-module ( name -- )
    modules get [ first = ] find-with nip
    [ modules get delete ] when* ;

: provide ( name files tests -- )
    pick remove-module
    [ process-files ] 2apply <module>
    [ module-files run-files ] keep
    add-module ;

: test-module ( name -- ) module module-tests run-tests ;

: all-modules ( -- seq ) modules get [ second ] map ;

: all-module-names ( -- seq ) modules get [ first ] map ;

: test-modules ( -- )
    all-modules [ module-tests ] map concat run-tests ;

: modules. ( -- )
    all-module-names natural-sort [ print ] each ;

: reload-module ( module -- )
    dup module-name module-def source-modified? [
        module-name load-module
    ] [
        module-files [ source-modified? ] subset run-files
    ] if ;

: reload-modules ( -- )
    all-modules [ reload-module ] each do-parse-hook ;
