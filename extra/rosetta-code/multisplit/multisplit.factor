! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel make sequences ;

IN: rosetta-code.multisplit

: first-subseq ( seq separators -- n separator )
    tuck
    [ [ subseq-index ] dip 2array ] withd map-index sift-keys
    [ drop f f ] [ [ first ] minimum-by first2 rot nth ] if-empty ;

: multisplit ( string separators -- seq )
    '[
        [ dup _ first-subseq dup ] [
            length -rot cut-slice [ , ] dip swap tail-slice
        ] while 2drop ,
    ] { } make ;
