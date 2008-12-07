! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.private generic.standard.engines namespaces make
arrays assocs sequences.private quotations kernel.private
math slots.private math.private kernel accessors words
layouts sorting sequences combinators ;
IN: generic.standard.engines.tag

TUPLE: lo-tag-dispatch-engine methods ;

C: <lo-tag-dispatch-engine> lo-tag-dispatch-engine

: direct-dispatch-quot ( alist n -- quot )
    default get <array>
    [ <enum> swap update ] keep
    [ dispatch ] curry >quotation ;

: lo-tag-number ( class -- n )
     dup \ hi-tag bootstrap-word eq? [
        drop \ hi-tag tag-number
    ] [
        "type" word-prop
    ] if ;

: sort-tags ( assoc -- alist ) >alist sort-keys reverse ;

: tag-dispatch-test ( tag# -- quot )
    picker [ tag ] append swap [ eq? ] curry append ;

: tag-dispatch-quot ( alist -- quot )
    [ default get ] dip
    [ [ tag-dispatch-test ] dip ] assoc-map
    alist>quot ;

M: lo-tag-dispatch-engine engine>quot
    methods>> engines>quots*
    [ [ lo-tag-number ] dip ] assoc-map
    [
        [ sort-tags tag-dispatch-quot ]
        [ picker % [ tag ] % num-tags get direct-dispatch-quot ]
        if-small? %
    ] [ ] make ;

TUPLE: hi-tag-dispatch-engine methods ;

C: <hi-tag-dispatch-engine> hi-tag-dispatch-engine

: convert-hi-tag-methods ( assoc -- assoc' )
    \ hi-tag bootstrap-word
    \ <hi-tag-dispatch-engine> convert-methods ;

: num-hi-tags ( -- n ) num-types get num-tags get - ;

: hi-tag-number ( class -- n )
    "type" word-prop ;

: hi-tag-quot ( -- quot )
    \ hi-tag def>> ;

M: hi-tag-dispatch-engine engine>quot
    methods>> engines>quots*
    [ [ hi-tag-number ] dip ] assoc-map
    [
        picker % hi-tag-quot % [
            sort-tags linear-dispatch-quot
        ] [
            num-tags get , \ fixnum-fast ,
            [ [ num-tags get - ] dip ] assoc-map
            num-hi-tags direct-dispatch-quot
        ] if-small? %
    ] [ ] make ;
