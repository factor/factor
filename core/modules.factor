! Copyright (C) 2006, 2007 Slava Pestov.
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

: loading-module ( name -- )
    "quiet" get [
        drop
    ] [
        "Loading module " write print flush
    ] if ;

: load-module ( name -- )
    [
        dup loading-module module-def bootstrap-file
    ] no-parse-hook ;

: reload-module ( name -- )
    dup module-def source-modified? [
        load-module
    ] [
        module module-files*
        [ source-modified? ] subset
        run-files
    ] if ;

: reload-modules ( seq -- )
    [ reload-module ] each do-parse-hook ;

: module-names ( -- seq )
    modules get [ module-name ] map ;

: reload-core ( -- )
    module-names [ "core" head? ] subset reload-modules ;

: reload-libs ( -- )
    module-names [ "core" head? not ] subset reload-modules ;

: require ( name -- )
    dup module [ drop ] [ load-module ] if do-parse-hook ;

: remove-module ( name -- )
    module [ modules get delete ] when* ;

: alist>module ( name loc hash -- module )
    >hashtable [
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

: add-module ( module name -- )
    modules get
    [ module-name = ] find-with drop
    [ modules get set-nth ] [ modules get push ] if* ;

: provide ( name loc hash -- )
    pick >r
    alist>module
    [ module-files* bootstrap-files ] keep
    r> add-module ;

! For presentations
TUPLE: module-link name ;

M: module-link module-name module-link-name ;
