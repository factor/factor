! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences
test words strings arrays math help ;

SYMBOL: modules

TUPLE: module name files tests main help ;

: module-def ( name -- path )
    "resource:" over ".factor" append3
    dup ?resource-path exists? [
        nip
    ] [
        drop "resource:" swap "/load.factor" append3
    ] if ;

: prefix-paths ( name seq -- newseq )
    [ path+ "resource:" swap append ] map-with ;

C: module ( name files tests help -- module )
    [ set-module-help ] keep
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
    0 <column> >array ;

: add-module ( module -- )
    dup module-name swap 2array modules get push ;

: remove-module ( name -- )
    modules get [ first = ] find-with nip
    [ modules get delete ] when* ;

: provide ( name hash -- )
    over remove-module [
        +files+ get process-files
        +tests+ get process-files
        +help+ get
    ] bind <module>
    [ module-files run-files ] keep
    add-module ;

: test-module ( name -- ) module module-tests run-tests ;

: all-modules ( -- seq ) modules get 1 <column> ;

: all-module-names ( -- seq ) modules get 0 <column> ;

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

: run-module ( name -- )
    dup require
    dup module module-main [
        call
    ] [
        "The module " write write
        " does not define an entry point." print
        "To define one, see the documentation for the " write
        \ MAIN: ($link) " word." print
    ] ?if ;

: modules-help ( -- seq )
    all-modules [ module-help ] map [ ] subset ;
