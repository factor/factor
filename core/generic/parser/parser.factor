! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators effects.parser generic
kernel namespaces parser quotations sequences words ;
IN: generic.parser

ERROR: not-in-a-method-error ;

: scan-new-generic ( -- word ) scan-new dup reset-word ;

: (GENERIC:) ( quot -- )
    [ scan-new-generic ] dip call scan-effect define-generic ; inline

: create-method-in ( class generic -- method )
    create-method dup set-word dup save-location ;

: define-inline-method ( class generic quot -- )
    [ create-method-in ] dip [ define ] [ drop make-inline ] 2bi ;

: scan-new-method ( -- method )
    scan-class bootstrap-word scan-word create-method-in ;

SYMBOL: current-method

: with-method-definition ( method quot -- )
    over current-method set call current-method off ; inline

: generic-effect ( word -- effect )
    "method-generic" word-prop "declared-effect" word-prop ;

: method-effect= ( method-effect generic-effect -- ? )
    [ [ in>> length ] bi@ = ]
    [
        over terminated?>>
        [ 2drop t ] [ [ out>> length ] bi@ = ] if
    ] 2bi and ;

ERROR: bad-method-effect ;

: check-method-effect ( effect -- )
    word generic-effect method-effect= [ bad-method-effect ] unless ;

: ?execute-parsing ( word/number -- seq )
    dup parsing-word?
    [ V{ } clone swap execute-parsing ] [ 1array ] if ;

: parse-method-definition ( -- quot )
    scan-datum {
        { \ ( [ ")" parse-effect check-method-effect parse-definition ] }
        { \ ; [ [ ] ] }
        [ ?execute-parsing \ ; parse-until append >quotation ]
    } case ;

PRIVATE>

: (M:) ( -- method def )
    scan-new-method [ parse-method-definition ] with-method-definition ;
