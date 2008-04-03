USING: classes.private generic.standard.engines namespaces
arrays assocs sequences.private quotations kernel.private
math slots.private math.private kernel accessors words
layouts ;
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
    methods>> engines>quots* [ >r lo-tag-number r> ] assoc-map
    [
        picker % [ tag ] % [
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

: num-hi-tags num-types get num-tags get - ;

: hi-tag-number ( class -- n )
    "type" word-prop num-tags get - ;

: hi-tag-quot ( -- quot )
    [ hi-tag ] num-tags get [ fixnum-fast ] curry compose ;

M: hi-tag-dispatch-engine engine>quot
    methods>> engines>quots* [ >r hi-tag-number r> ] assoc-map
    [
        picker % hi-tag-quot % [
            linear-dispatch-quot
        ] [
            num-hi-tags direct-dispatch-quot
        ] if-small? %
    ] [ ] make ;
