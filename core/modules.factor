! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: modules
USING: hashtables io kernel namespaces parser sequences
words strings arrays math help errors ;

SYMBOL: modules

TUPLE: module name loc directory files tests help main ;

: module-def ( name -- path )
    "resource:" over "/load.factor" 3append
    dup ?resource-path exists? [
        nip
    ] [
        drop "resource:" swap ".factor" 3append
    ] if ;

: module modules get [ module-name = ] find-with nip ;

: process-files ( name seq -- newseq )
    [ dup string? [ [ t ] 2array ] when ] map
    [ second call ] subset
    0 <column> >array
    [ path+ "resource:" swap append ] map-with ;

: module-files* ( module -- seq )
    dup module-directory swap module-files process-files ;

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

: reload-modules ( -- )
    modules get [ reload-module ] each do-parse-hook ;

: require ( name -- )
    dup module [ drop ] [ load-module ] if do-parse-hook ;

: remove-module ( name -- )
    module [ modules get delete ] when* ;

: alist>module ( name loc hash -- module )
    alist>hash [
        +directory+ get [ over ] unless*
        +files+ get
        +tests+ get
        +help+ get
    ] bind f <module> ;

: module>alist ( module -- hash )
    [
        +directory+ over module-directory 2array ,
        +files+ over module-files 2array ,
        +tests+ over module-tests 2array ,
        +help+ swap module-help 2array ,
    ] { } make ;

: provide ( name loc hash -- )
    pick remove-module
    alist>module
    [ module-files* run-files ] keep
    modules get push ;
