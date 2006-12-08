! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences
words strings arrays math help errors prettyprint-internals styles test definitions ;

! For presentations
TUPLE: module-link name ;

M: module-link module-name module-link-name ;

: module-tests* ( module -- seq )
    dup module-name swap module-tests process-files ;

: test-module ( name -- )
    dup require
    module module-tests* run-tests ;

: test-modules ( -- )
    modules get [ module-tests* ] map concat run-tests ;

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

M: module where module-loc ;

: module-dir? ( path -- ? )
    "load.factor" path+ resource-path exists? ;

: (available-modules) ( path -- )
    dup resource-path directory [ path+ ] map-with
    dup [ module-dir? ] subset %
    [ (available-modules) ] each ;

: small-modules ( path -- seq )
    dup resource-path directory [ path+ ] map-with
    [ ".factor" tail? ] subset
    [ ".factor" ?tail drop ] map ;

: available-modules ( -- seq )
    [
        "core" (available-modules)
        "apps" (available-modules)
        "apps" small-modules %
        "libs" (available-modules)
        "libs" small-modules %
        "demos" (available-modules)
        "demos" small-modules %
    ] { } make natural-sort
    [ dup module [ ] [ <module-link> ] ?if ] map ;

: module-string ( obj -- str )
    dup module-name swap module? [ " (loaded)" append ] when ;

: modules. ( -- )
    available-modules
    [ [ module-string ] keep write-object terpri ] each ;
