! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit unicode.categories kernel math
combinators splitting sequences math.parser io.files io assocs
arrays namespaces make math.ranges unicode.normalize values
io.encodings.ascii unicode.syntax unicode.data compiler.units
alien.syntax sets ;
IN: unicode.breaks

C-ENUM: Any L V T Extend Control CR LF graphemes ;

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

CATEGORY: (extend) Me Mn ;
: extend? ( ch -- ? )
    { [ (extend)? ] [ "Other_Grapheme_Extend" property? ] } 1|| ;

: grapheme-class ( ch -- class )
    {
        { [ dup jamo? ] [ jamo-class ] }
        { [ dup grapheme-control? ] [ control-class ] }
        { [ extend? ] [ Extend ] }
        [ Any ]
    } cond ;

: init-grapheme-table ( -- table )
    graphemes [ graphemes f <array> ] replicate ;

SYMBOL: table

: finish-table ( -- table )
    table get [ [ 1 = ] map ] map ;

: set-table ( class1 class2 val -- )
    -rot table get nth [ swap or ] change-nth ;

: connect ( class1 class2 -- ) 1 set-table ;
: disconnect ( class1 class2 -- ) 0 set-table ;

: connect-before ( class classes -- )
    [ connect ] with each ;

: connect-after ( classes class -- )
    [ connect ] curry each ;

: break-around ( classes1 classes2 -- )
    [ [ 2dup disconnect swap disconnect ] with each ] curry each ;

: make-grapheme-table ( -- )
    CR LF connect
    Control CR LF 3array graphemes break-around
    L L V 2array connect-before
    V V T 2array connect-before
    T T connect
    graphemes Extend connect-after ;

VALUE: grapheme-table

: grapheme-break? ( class1 class2 -- ? )
    grapheme-table nth nth not ;

: chars ( i str n -- str[i] str[i+n] )
    swap [ dupd + ] dip [ ?nth ] curry bi@ ;

: find-index ( seq quot -- i ) find drop ; inline
: find-last-index ( seq quot -- i ) find-last drop ; inline

: first-grapheme ( str -- i )
    unclip-slice grapheme-class over
    [ grapheme-class tuck grapheme-break? ] find-index
    nip swap length or 1+ ;

: (>graphemes) ( str -- )
    [
        dup first-grapheme cut-slice
        swap , (>graphemes)
    ] unless-empty ;

: >graphemes ( str -- graphemes )
    [ (>graphemes) ] { } make ;

: string-reverse ( str -- rts )
    >graphemes reverse concat ;

: last-grapheme ( str -- i )
    unclip-last-slice grapheme-class swap
    [ grapheme-class dup rot grapheme-break? ] find-last-index ?1+ nip ;

init-grapheme-table table
[ make-grapheme-table finish-table ] with-variable
to: grapheme-table
