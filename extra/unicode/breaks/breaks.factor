USING: unicode kernel math const combinators splitting
sequences math.parser io.files io assocs arrays namespaces
;
IN: unicode.breaks

ENUM: Any L V T Extend Control CR LF graphemes ;

: jamo-class ( ch -- class )
    dup initial? [ drop L ]
    [ dup medial? [ drop V ] [ final? T Any ? ] if ] if ;

CATEGORY: grapheme-control Zl Zp Cc Cf ;
: control-class ( ch -- class )
    {
        { CHAR: \r [ CR ] }
        { CHAR: \n [ LF ] }
        { HEX: 200C [ Extend ] }
        { HEX: 200D [ Extend ] }
        [ drop Control ]
    } case ;

: trim-blank ( str -- newstr )
    dup [ blank? not ] find-last 1+* head ;

: process-other-extend ( lines -- set )
    [ "#" split1 drop ";" split1 drop trim-blank ] map
    [ empty? not ] subset
    [ ".." split1 [ dup ] unless* [ hex> ] 2apply range ] map
    concat >set ;

: other-extend-lines ( -- lines )
    "extra/unicode/PropList.txt" resource-path <file-reader> lines ;

DEFER: other-extend
: load-other-extend 
    other-extend-lines process-other-extend
    \ other-extend define-value ; parsing
load-other-extend

CATEGORY: (extend) Me Mn ;
: extend? ( ch -- ? )
    [ (extend)? ] [ other-extend key? ] either ;

: grapheme-class ( ch -- class )
    {
        { [ dup jamo? ] [ jamo-class ] }
        { [ dup grapheme-control? ] [ control-class ] }
        { [ extend? ] [ Extend ] }
        { [ t ] [ Any ] }
    } cond ;

: init-grapheme-table ( -- table )
    graphemes [ drop graphemes f <array> ] map ;

SYMBOL: table

: finish-table ( -- table )
    table get [ [ 1 = ] map ] map ;

: set-table ( class1 class2 val -- )
    -rot table get nth [ swap or ] change-nth ;

: connect ( class1 class2 -- ) 1 set-table ;
: disconnect ( class1 class2 -- ) 0 set-table ;

: connect-before ( class classes -- )
    [ connect ] curry* each ;

: connect-after ( classes class -- )
    [ connect ] curry each ;

: break-around ( classes1 classes2 -- )
    [ [ 2dup disconnect swap disconnect ] curry* each ] curry each ;

: make-grapheme-table ( -- )
    CR LF connect
    { Control CR LF } graphemes break-around
    L { L V } connect-before
    V { V T } connect-before
    T T connect
    graphemes Extend connect-after ;

DEFER: grapheme-table
: load-grapheme-table
    init-grapheme-table table
    [ make-grapheme-table finish-table ] with-variable
    \ grapheme-table define-value ; parsing
load-grapheme-table

: grapheme-break? ( class1 class2 -- ? )
    grapheme-table nth nth not ;

: chars ( i str n -- str[i] str[i+n] )
    swap >r dupd + r> [ ?nth ] curry 2apply ;

: next-grapheme-step ( i str -- i+1 str prev-class )
    2dup nth grapheme-class >r >r 1+ r> r> ;

: (next-grapheme) ( i str prev-class -- next-i )
    3dup drop bounds-check? [
        >r next-grapheme-step r> over grapheme-break?
        [ 2drop 1- ] [ (next-grapheme) ] if
    ] [ 2drop ] if ;

: next-grapheme ( i str -- next-i )
    next-grapheme-step (next-grapheme) ;

: (>graphemes) ( i str -- )
    2dup bounds-check? [
        dupd [ next-grapheme ] keep
        [ subseq , ] 2keep (>graphemes)
    ] [ 2drop ] if ;
: >graphemes ( str -- graphemes )
    [ 0 swap (>graphemes) ] { } make* ;

: string-reverse ( str -- rts )
    >graphemes reverse concat ;

: prev-grapheme-step ( i str -- i-1 str prev-class )
    2dup nth grapheme-class >r >r 1- r> r> ;

: (prev-grapheme) ( i str next-class -- prev-i )
    pick zero? [
        >r prev-grapheme-step r> dupd grapheme-break?
        [ 2drop 1- ] [ (prev-grapheme) ] if
    ] [ 2drop ] if ;

: prev-grapheme ( i str -- prev-i )
    prev-grapheme-step (prev-grapheme) ;
