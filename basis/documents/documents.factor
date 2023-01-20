! Copyright (C) 2006, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.order ranges
models sequences splitting ;
IN: documents

: +col ( loc n -- newloc ) [ first2 ] dip + 2array ;

: +line ( loc n -- newloc ) [ first2 swap ] dip + swap 2array ;

: =col ( n loc -- newloc ) first swap 2array ;

: =line ( n loc -- newloc ) second 2array ;

: lines-equal? ( loc1 loc2 -- ? ) [ first ] bi@ number= ;

TUPLE: edit old-string new-string from old-to new-to ;

C: <edit> edit

TUPLE: document < model locs undos redos inside-undo? ;

: clear-undo ( document -- )
    V{ } clone >>undos
    V{ } clone >>redos
    drop ;

: <document> ( -- document )
    { "" } document new-model
    V{ } clone >>locs
    dup clear-undo ;

: add-loc ( loc document -- ) locs>> push ;

: remove-loc ( loc document -- ) locs>> remove! drop ;

: update-locs ( loc document -- )
    locs>> [ set-model ] with each ;

: doc-line ( n document -- string ) value>> nth ;

: line-end ( line# document -- loc )
    [ drop ] [ doc-line length ] 2bi 2array ;

: doc-lines ( from to document -- slice )
    [ 1 + ] [ value>> ] bi* <slice> ;

: start-on-line ( from line# document -- n1 )
    drop over first =
    [ second ] [ drop 0 ] if ;

:: end-on-line ( to line# document -- n2 )
    to first line# =
    [ to second ] [ line# document doc-line length ] if ;

: each-doc-line ( ... from to quot: ( ... line -- ... ) -- ... )
    2over = [ 3drop ] [
        [ [ first ] bi@ [a..b] ] dip each
    ] if ; inline

: map-doc-lines ( ... from to quot: ( ... line -- ... result ) -- ... results )
    collector [ each-doc-line ] dip ; inline

: start/end-on-line ( from to line# document -- n1 n2 )
    [ start-on-line ] [ end-on-line ] bi-curry bi-curry bi* ;

: last-line# ( document -- line )
    value>> length 1 - ;

CONSTANT: doc-start { 0 0 }

: doc-end ( document -- loc )
    [ last-line# ] keep line-end ;

<PRIVATE

: (doc-range) ( from to line# document -- slice )
    [ start/end-on-line ] 2keep doc-line <slice> ;

:: text+loc ( lines loc -- loc )
    lines length 1 = [
        loc first2
    ] [
        loc first lines length 1 - + 0
    ] if lines last length + 2array ;

: prepend-first ( str seq -- )
    0 swap [ append ] change-nth ;

: append-last ( str seq -- )
    index-of-last [ prepend ] change-nth ;

: loc-col/str ( loc document -- str col )
    [ first2 swap ] dip nth swap ;

: prepare-insert ( new-lines from to lines -- new-lines )
    [ loc-col/str head-slice ] [ loc-col/str tail-slice ] bi-curry bi*
    pick append-last over prepend-first ;

: (set-doc-range) ( doc-lines from to lines -- changed-lines )
    [ prepare-insert ] 3keep
    [ [ first ] bi@ 1 + ] dip
    replace-slice ;

: entire-doc ( document -- start end document )
    [ [ doc-start ] dip doc-end ] keep ;

: with-undo ( ..a document quot: ( ..a document -- ..b ) -- ..b )
    [ t >>inside-undo? ] dip keep f >>inside-undo? drop ; inline

: ?split-lines ( str -- seq )
    [ split-lines ] keep ?last
    [ "\r\n" member? ] [ t ] if*
    [ "" suffix ] when ;

PRIVATE>

:: doc-range ( from to document -- string )
    from to [ [ from to ] dip document (doc-range) ] map-doc-lines
    join-lines ;

: add-undo ( edit document -- )
    dup inside-undo?>> [ 2drop ] [
        [ undos>> push ] keep
        redos>> delete-all
    ] if ;

:: set-doc-range ( string from to document -- )
    from to = string empty? and [
        string ?split-lines :> new-lines
        new-lines from text+loc :> new-to
        from to document doc-range :> old-string
        old-string string from to new-to <edit> document add-undo
        new-lines from to document [ (set-doc-range) ] models:change-model
        new-to document update-locs
    ] unless ;

:: set-doc-range* ( string from to document -- )
    from to = string empty? and [
        string ?split-lines :> new-lines
        new-lines from text+loc :> new-to
        new-lines from to document [ (set-doc-range) ] models:change-model
        new-to document update-locs
    ] unless ;

: change-doc-range ( from to document quot -- )
    '[ doc-range @ ] 3keep set-doc-range ; inline

: remove-doc-range ( from to document -- )
    [ "" ] 3dip set-doc-range ;

: validate-line ( line document -- line )
    last-line# min 0 max ;

: validate-col ( col line document -- col )
    doc-line length min 0 max ;

: line-end? ( loc document -- ? )
    [ first2 swap ] dip doc-line length = ;

: validate-loc ( loc document -- newloc )
    2dup [ first ] [ value>> length ] bi* >= [
        nip doc-end
    ] [
        over first 0 < [
            2drop { 0 0 }
        ] [
            [ first2 over ] dip validate-col 2array
        ] if
    ] if ;

: doc-string ( document -- str )
    entire-doc doc-range ;

: set-doc-string ( string document -- )
    entire-doc set-doc-range ;

: clear-doc ( document -- )
    [ "" ] dip set-doc-string ;

<PRIVATE

: undo/redo-edit ( edit document string-quot to-quot -- )
    '[ [ _ [ from>> ] _ tri ] dip set-doc-range ] with-undo ; inline

: undo-edit ( edit document -- )
    [ old-string>> ] [ new-to>> ] undo/redo-edit ;

: redo-edit ( edit document -- )
    [ new-string>> ] [ old-to>> ] undo/redo-edit ;

: undo/redo ( document source-quot dest-quot do-quot -- )
    [ dupd call [ drop ] ] 2dip
    '[ pop swap [ @ push ] _ 2bi ] if-empty ; inline

PRIVATE>

: undo ( document -- )
    [ undos>> ] [ redos>> ] [ undo-edit ] undo/redo ;

: redo ( document -- )
    [ redos>> ] [ undos>> ] [ redo-edit ] undo/redo ;
