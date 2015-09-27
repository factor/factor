USING: game.models.util tools.test make accessors kernel ;
IN: game.models.util.tests

{ V{ 1 2 3 4 } } [
    [ 1 , 1 , 2 , 3 , 3 , 4 , ]
    V{ } V{ } H{ } <indexed-seq> make
    dseq>>
] unit-test

{ V{ 0 0 1 2 2 3 } } [
    [ 1 , 1 , 2 , 3 , 3 , 4 , ]
    V{ } V{ } H{ } <indexed-seq> make
    iseq>>
] unit-test
