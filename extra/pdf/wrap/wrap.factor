! Copyright (C) 2011-2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel fry make math sequences ui.text unicode.categories
wrap ;

IN: pdf.wrap

<PRIVATE

: word-index ( string -- n/f )
    dup [ blank? ] find drop [
        1 + swap [ blank? not ] find-from drop
    ] [ drop f ] if* ;

PRIVATE>

: word-split1 ( string -- before after/f )
    dup word-index [ cut ] [ f ] if* ;

<PRIVATE

: word-split, ( string -- )
    [ word-split1 [ , ] [ dup empty? not ] bi* ] loop drop ;

PRIVATE>

: word-split ( string -- seq )
    [ word-split, ] { } make ;

<PRIVATE

: string>elements ( string font -- elements )
    [ word-split ] dip '[
        dup word-split1 "" or
        [ _ swap text-width ] bi@
        <element>
    ] map ;

PRIVATE>

: visual-wrap ( line font line-width -- lines )
    [ string>elements ] dip dup wrap [ concat ] map ;

