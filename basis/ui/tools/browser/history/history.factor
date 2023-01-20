! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences locals ;
IN: ui.tools.browser.history

TUPLE: history owner back forward ;

: <history> ( owner -- history )
    V{ } clone V{ } clone history boa ;

GENERIC: history-value ( object -- value )

GENERIC: set-history-value ( value object -- )

: (add-history) ( history to -- )
    swap owner>> history-value [ swap push ] [ drop ] if* ;

:: go-back/forward ( history to from -- )
    from empty? [
        history to (add-history)
        from pop history owner>> set-history-value
    ] unless ;

: go-back ( history -- )
    dup [ forward>> ] [ back>> ] bi go-back/forward ;

: go-forward ( history -- )
    dup [ back>> ] [ forward>> ] bi go-back/forward ;

: add-history ( history -- )
    dup forward>> delete-all
    dup back>> (add-history) ;
