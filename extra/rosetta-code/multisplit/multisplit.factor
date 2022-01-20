! Copyright (C) 2020 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel make sequences ;

IN: rosetta-code.multisplit

: ?pair ( ? x -- {?,x}/f )
    over [ 2array ] [ 2drop f ] if ;

: best-separator ( seq -- pos index )
    dup [ first ] map infimum '[ first _ = ] find nip first2 ;

: first-subseq ( separators seq -- n separator )
    dupd [ swap [ subseq-start ] dip ?pair ] curry map-index sift
    [ drop f f ] [ best-separator rot nth ] if-empty ;

: multisplit ( string separators -- seq )
    '[
        [ _ over first-subseq dup ] [
            length -rot cut-slice swap , swap tail-slice
        ] while 2drop ,
    ] { } make ;
