! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences
test words strings arrays math help prettyprint-internals
definitions styles ;

SYMBOL: modules

TUPLE: module name loc files tests help main ;

! For presentations
TUPLE: module-link name ;

M: module-link module-name module-link-name ;

: module-def ( name -- path )
    "resource:" over ".factor" append3
    dup ?resource-path exists? [
        nip
    ] [
        drop "resource:" swap "/load.factor" append3
    ] if ;

: module modules get [ module-name = ] find-with nip ;

: process-files ( name seq -- newseq )
    [ dup string? [ [ t ] 2array ] when ] map
    [ second call ] subset
    0 <column> >array
    [ path+ "resource:" swap append ] map-with ;

: module-files* ( module -- seq )
    dup module-name swap module-files process-files ;

: load-module ( name -- )
    [
        "Loading module " write dup write "..." print
        [ dup module-def run-file ] assert-depth drop
    ] no-parse-hook ;

: reload-module ( module -- )
    dup module-name module-def source-modified? [
        module-name load-module
    ] [
        module-files* [ source-modified? ] subset run-files
    ] if ;

: require ( name -- )
    dup module
    [ reload-module ] [ load-module ] ?if
    do-parse-hook ;

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

M: module synopsis*
    \ PROVIDE: pprint-word
    [ module-name ] keep presented associate styled-text ;

M: module definition module>alist t ;

M: module where* module-loc ;

: module-dir? ( path -- ? )
    "load.factor" path+ resource-path exists? ;

: (available-modules) ( path -- )
    dup directory [ path+ ] map-with
    dup [ module-dir? ] subset %
    [ (available-modules) ] each ;

: small-modules ( path -- seq )
    dup resource-path directory [ path+ ] map-with
    [ ".factor" tail? ] subset
    [ ".factor" ?tail drop ] map ;

: available-modules ( -- seq )
    [
        "library" (available-modules)
        "contrib" (available-modules)
        "contrib" small-modules %
        "examples" (available-modules)
        "examples" small-modules %
    ] { } make natural-sort
    [ dup module [ ] [ <module-link> ] ?if ] map ;

: module-string ( obj -- str )
    dup module-name swap module? [ " (loaded)" append ] when ;

: modules. ( -- )
    available-modules
    [ [ module-string ] keep write-object terpri ] each ;
