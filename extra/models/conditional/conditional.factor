! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors kernel models threads calendar ;
IN: models.conditional

TUPLE: conditional < model condition thread ;

M: conditional model-changed
    [
        [ dup
            [ condition>> call( -- ? ) ]
            [ thread>> self = not ] bi or
            [ [ value>> ] dip set-model f ]
            [ 2drop t ] if 100 milliseconds sleep
        ] 2curry "models.conditional" spawn-server
    ] keep thread<< ;

: <conditional> ( condition -- model )
    f conditional new-model swap >>condition ;

M: conditional model-activated [ model>> ] keep model-changed ;
