! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.private generic.standard.engines namespaces make
arrays assocs sequences.private quotations kernel.private
math slots.private math.private kernel accessors words
layouts sorting sequences ;
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

M: lo-tag-dispatch-engine engine>quot
    methods>> engines>quots*
    [ >r lo-tag-number r> ] assoc-map
    [
        picker % [ tag ] % [
            ! >alist sort-keys reverse
            linear-dispatch-quot
        ] [
            num-tags get direct-dispatch-quot
        ] if-small? %
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
    methods>> engines>quots* [ >r hi-tag-number r> ] assoc-map
    [
        picker % hi-tag-quot % [
            linear-dispatch-quot
        ] [
            num-tags get , \ fixnum-fast ,
            [ >r num-tags get - r> ] assoc-map
            num-hi-tags direct-dispatch-quot
        ] if-small? %
    ] [ ] make ;
