! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences
test words strings arrays math help prettyprint-internals
definitions ;

SYMBOL: modules

TUPLE: module name loc files tests help main ;

: module-def ( name -- path )
    "resource:" over ".factor" append3
    dup ?resource-path exists? [
        nip
    ] [
        drop "resource:" swap "/load.factor" append3
    ] if ;

M: module <=> [ module-name ] 2apply <=> ;

: module modules get [ module-name = ] find-with nip ;

: load-module ( name -- )
    [
        "Loading module " write dup write "..." print
        [ dup module-def run-file ] assert-depth drop
    ] no-parse-hook ;

: require ( name -- )
    dup module [ drop ] [ load-module ] if do-parse-hook ;

: process-files ( name seq -- newseq )
    [ dup string? [ [ t ] 2array ] when ] map
    [ second call ] subset
    0 <column> >array
    [ path+ "resource:" swap append ] map-with ;

: module-files* ( module -- seq )
    dup module-name swap module-files process-files ;

: module-tests* ( module -- seq )
    dup module-name swap module-tests process-files ;

: remove-module ( name -- )
    module [ modules get delete ] when* ;

: alist>module ( name loc hash -- module )
    alist>hash [
        +files+ get +tests+ get +help+ get
    ] bind f <module> ;

: module>alist ( module -- hash )
    [
        +files+ over module-files 2array ,
        +tests+ over module-tests 2array ,
        +help+ swap module-help 2array ,
    ] { } make ;

: provide ( name loc hash -- )
    pick remove-module
    alist>module
    [ module-files* run-files ] keep
    modules get push ;

: test-module ( name -- ) module module-tests* run-tests ;

: test-modules ( -- )
    modules get [ module-tests* ] map concat run-tests ;

: modules. ( -- )
    modules get natural-sort
    [ [ module-name ] keep write-object terpri ] each ;

: reload-module ( module -- )
    dup module-name module-def source-modified? [
        module-name load-module
    ] [
        module-files* [ source-modified? ] subset run-files
    ] if ;

: reload-modules ( -- )
    modules get [ reload-module ] each do-parse-hook ;

: run-module ( name -- )
    dup require
    dup module module-main [
        assert-depth
    ] [
        "The module " write write
        " does not define an entry point." print
        "To define one, see the documentation for the " write
        \ MAIN: ($link) " word." print
    ] ?if ;

: modules-help ( -- seq )
    modules get [ module-help ] map [ ] subset ;

M: module synopsis* \ PROVIDE: pprint-word module-name text ;

M: module definition module>alist t ;

M: module where* module-loc ;
