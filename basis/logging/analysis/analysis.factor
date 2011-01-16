! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces words assocs logging sorting
prettyprint io io.styles io.files io.encodings.utf8
strings combinators accessors arrays math
logging.server logging.parser calendar.format ;
IN: logging.analysis

SYMBOL: word-names
SYMBOL: errors
SYMBOL: word-histogram
SYMBOL: message-histogram

: analyze-entry ( entry -- )
    dup level>> { ERROR CRITICAL } member-eq? [ dup errors get push ] when
    dup word-name>> word-histogram get inc-at
    dup word-name>> word-names get member? [
        dup [ level>> ] [ word-name>> ] [ message>> ] tri 3array
        message-histogram get inc-at
    ] when
    drop ;

: recent-histogram ( assoc n -- alist )
    [ >alist sort-values <reversed> ] dip short head ;

: analyze-entries ( entries word-names -- errors word-histogram message-histogram )
    [
        word-names set
        V{ } clone errors set
        H{ } clone word-histogram set
        H{ } clone message-histogram set

        [ analyze-entry ] each

        errors get
        word-histogram get 10 recent-histogram
        message-histogram get 10 recent-histogram
    ] with-scope ;

: histogram. ( assoc quot -- )
    standard-table-style [
        [
            [ swapd with-cell pprint-cell ] with-row
        ] curry assoc-each
    ] tabular-output ; inline

: 10-most-recent ( errors -- errors )
    10 tail* "Only showing 10 most recent errors" print nl ;

: errors. ( errors -- )
    dup length 10 >= [ 10-most-recent ] when
    log-entries. ;

: analysis. ( errors word-histogram message-histogram -- )
    nl "==== FREQUENT MESSAGES:" print nl
    "Total: " write dup values sum . nl
    [
        [ first name>> write bl ]
        [ second write ": " write ]
        [ third "\n" join write ]
        tri
    ] histogram.
    nl nl
    "==== FREQUENT WORDS:" print nl
    [ write ] histogram.
    nl nl
    "==== ERRORS:" print nl
    errors. ;

: analyze-log ( lines word-names -- )
    [ parse-log ] dip analyze-entries analysis. ;

: analyze-log-file ( service word-names -- )
    [ parse-log-file ] dip analyze-entries analysis. ;
