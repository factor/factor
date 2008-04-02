USING: classes.private generic.standard.engines namespaces
arrays mirrors assocs sequences.private quotations
kernel.private layouts math slots.private math.private
kernel accessors ;
IN: generic.standard.engines.tag

TUPLE: lo-tag-dispatch-engine methods ;

C: <lo-tag-dispatch-engine> lo-tag-dispatch-engine

TUPLE: hi-tag-dispatch-engine methods ;

C: <hi-tag-dispatch-engine> hi-tag-dispatch-engine

: convert-hi-tag-methods ( assoc -- assoc' )
    \ hi-tag \ <hi-tag-dispatch-engine> convert-methods ;

: direct-dispatch-quot ( alist n -- quot )
    default get <array>
    [ <enum> swap update ] keep
    [ dispatch ] curry >quotation ;

M: lo-tag-dispatch-engine engine>quot
    methods>> engines>quots* [ >r tag-number r> ] assoc-map
    [
        picker % [ tag ] % [
            linear-dispatch-quot
        ] [
            num-tags get direct-dispatch-quot
        ] if-small? %
    ] [ ] make ;

: num-hi-tags num-types get num-tags get - ;

: hi-tag-number type-number num-tags get - ;

: hi-tag-quot ( -- quot )
    [ 0 slot ] num-tags get [ fixnum- ] curry compose ;

M: hi-tag-dispatch-engine engine>quot
    methods>> engines>quots* [ >r hi-tag-number r> ] assoc-map
    [
        picker % hi-tag-quot % [
            linear-dispatch-quot
        ] [
            num-hi-tags direct-dispatch-quot
        ] if-small? %
    ] [ ] make ;
