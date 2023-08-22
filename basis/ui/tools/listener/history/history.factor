! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors documents io.styles kernel math math.order
sequences ;
IN: ui.tools.listener.history

TUPLE: history document elements index ;

: <history> ( document -- history )
    V{ } clone 0 history boa ;

<PRIVATE

: push-if-not-last ( elt seq -- )
    2dup ?last = [ 2drop ] [ push ] if ;

: current-input ( history -- input ? )
    document>> doc-string [ <input> ] [ empty? ] bi ;

PRIVATE>

: history-add ( history -- input )
    dup current-input [ nip ] [
        [
            over elements>>
            [ push-if-not-last ]
            [ length >>index drop ] bi
        ] keep
    ] if ;

<PRIVATE

: set-element ( elt history -- )
    [ index>> ] [ elements>> ] bi set-nth ;

: get-element ( history -- elt )
    [ index>> ] [ elements>> ] bi nth ;

: save-history ( history -- )
    dup current-input [ 2drop ] [ swap set-element ] if ;

: update-document ( history -- )
    [ get-element string>> ] [ document>> ] bi
    [ set-doc-string ] [ clear-undo ] bi ;

: change-history-index ( history i -- )
    over elements>> length 1 -
    '[ _ + 0 _ clamp ] change-index drop ;

: history-recall ( history i -- )
    over elements>> empty? [ 2drop ] [
        [ drop save-history ]
        [ change-history-index ]
        [ drop update-document ]
        2tri
    ] if ;

PRIVATE>

: history-recall-previous ( history -- )
    -1 history-recall ;

: history-recall-next ( history -- )
    1 history-recall ;
