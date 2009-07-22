! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors documents kernel math math.order
sequences fry io.styles ;
IN: ui.tools.listener.history

TUPLE: history document elements index ;

: <history> ( document -- history )
    V{ } clone 0 history boa ;

: history-add ( history -- input )
    dup elements>> length 1+ >>index
    [ document>> doc-string [ <input> ] [ empty? ] bi ] keep
    '[ [ _ elements>> push ] keep ] unless ;

<PRIVATE

: (save-history) ( input index elements -- )
    2dup length > [
        [ [ T{ input f "" } ] dip push ] keep
        (save-history)
    ] [ set-nth ] if ;

: save-history ( history -- )
    [ document>> doc-string ] keep
    '[ <input> _ [ index>> ] [ elements>> ] bi (save-history) ]
    unless-empty ;

: update-document ( history -- )
    [ [ index>> ] [ elements>> ] bi nth string>> ] [ document>> ] bi
    [ set-doc-string ] [ clear-undo drop ] 2bi ;

: change-history-index ( history i -- )
    over elements>> length 1-
    '[ _ + _ min 0 max ] change-index drop ;

: history-recall ( history i -- )
    [ [ elements>> empty? ] keep ] dip '[
        _
        [ save-history ]
        [ _ change-history-index ]
        [ update-document ]
        tri
    ] unless ;

PRIVATE>

: history-recall-previous ( history -- )
    -1 history-recall ;

: history-recall-next ( history -- )
    1 history-recall ;
