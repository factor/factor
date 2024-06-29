! Copyright (C) 2013 Charles Alston, John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: arrays formatting help.stylesheet io io.encodings.utf8
io.launcher io.pathnames io.styles kernel locals memoize
namespaces sequences sequences.generalizations splitting
wrap.strings ;
IN: spotlight

! -----
! TO DO:
! -need to test sudo-mdutil; intercept auth prompt
! -handle case-sensitivity properly (macOS)
! -test composing variant shell command constructions,
!  i.e., those which do or don't need spaces, parens,
!  single quotes, etc. (work through examples at end of file)
! -access o.e.d & calculator through spotlight
! -emit some sort of 'not-found' msg for unsuccessful search
! -trap errors! ...
! -----

: attr== ( item-name attr-name -- string )
    swap "%s == '%s'" sprintf ;

: attr!= ( item-name attr-name -- string )
    swap "%s != '%s'" sprintf ;

: attr> ( item-name attr-name -- string )
    swap "%s > '%s'" sprintf ;

: attr>= ( item-name attr-name -- string )
    swap "%s >= '%s'" sprintf ;

: attr< ( item-name attr-name -- string )
    swap "%s < '%s'" sprintf ;

: attr<= ( item-name attr-name -- string )
    swap "%s <= '%s'" sprintf ;

: attr&& ( attr1 attr2 -- string )
    " && " glue ;

: attr|| ( attr1 attr2 -- string )
    " || " glue ;

: mdfind ( query -- results )
    "mdfind -onlyin . %s" sprintf process-lines ;

: mdfind. ( query -- )
    mdfind [ dup <pathname> write-object nl ] each ;

: mdls ( path -- )
    absolute-path "mdls" swap 2array process-lines
    [ print ] each ;

: mdutil ( flags on|off volume -- seq )
    [ "mdfind" swap "-" prepend "-i" ] 2dip 5 narray
    process-lines ;

: mdimport ( path -- seq )
    absolute-path "mdimport " prepend process-lines ;

: mdimport-with ( path options -- seq )
    swap absolute-path "mdimport %s %s" sprintf process-lines ;

MEMO: kMDItems ( -- seq )
    "mdimport -A" process-lines
    [ "'kMDItem" head? ] filter
    [ "\t" split harvest [ but-last rest ] map ] map ;

: kMDItems. ( -- )
    kMDItems table-style get [
        [
            [
                [ [ 64 wrap-string write ] with-cell ] each
            ] with-row
        ] each
    ] tabular-output nl ;
