! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces words assocs logging sorting
prettyprint io io.styles io.files io.encodings.utf8
strings combinators accessors arrays
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

: analyze-entries ( entries word-names -- errors word-histogram message-histogram )
    [
        word-names set
        V{ } clone errors set
        H{ } clone word-histogram set
        H{ } clone message-histogram set

        [
            analyze-entry
        ] each

        errors get
        word-histogram get
        message-histogram get
    ] with-scope ;

: histogram. ( assoc quot -- )
    standard-table-style [
        [ >alist sort-values <reversed> ] dip [
            [ swapd with-cell pprint-cell ] with-row
        ] curry assoc-each
    ] tabular-output ; inline

: log-entry. ( entry -- )
    "====== " write
    {
        [ date>> (timestamp>string) bl ]
        [ level>> pprint bl ]
        [ word-name>> write nl ]
        [ message>> "\n" join print ]
    } cleave ;

: errors. ( errors -- )
    [ log-entry. ] each ;

: analysis. ( errors word-histogram message-histogram -- )
    "==== INTERESTING MESSAGES:" print nl
    "Total: " write dup values sum . nl
    [
        dup level>> write ": " write message>> "\n" join write
    ] histogram.
    nl
    "==== WORDS:" print nl
    [ write ] histogram.
    nl
    "==== ERRORS:" print nl
    errors. ;

: analyze-log ( lines word-names -- )
    [ parse-log ] dip analyze-entries analysis. ;

: analyze-log-file ( service word-names -- )
    [ parse-log-file ] dip analyze-entries analysis. ;
