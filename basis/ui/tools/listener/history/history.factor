! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors documents io.styles kernel math math.order
sequences fry ;
IN: ui.tools.listener.history

TUPLE: history document elements index ;

: <history> ( document -- history )
    V{ } clone 0 history boa ;

<PRIVATE

: save-history ( history -- input )
    [ document>> doc-string [ <input> ] [ empty? ] bi ] keep
    '[ [ _ [ index>> ] [ elements>> ] bi set-nth ] keep ] unless ;

: update-document ( history -- )
    [ [ index>> ] [ elements>> ] bi nth string>> ]
    [ document>> ] bi
    set-doc-string ;

: change-history-index ( history i -- )
    over elements>> length 1-
    '[ _ + _ min 0 max ] change-index drop ;

: history-recall ( history i -- )
    [ [ elements>> empty? ] keep ] dip '[
        _
        [ save-history drop ]
        [ _ change-history-index ]
        [ update-document ]
        tri
    ] unless ;

PRIVATE>

: history-add ( history -- input )
    dup elements>> length 1+ >>index
    save-history ;

: history-recall-previous ( history -- )
    -1 history-recall ;

: history-recall-next ( history -- )
    1 history-recall ;
