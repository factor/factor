USING: kernel math.constants ;
IN: random-tester.databank

: databank ( -- array )
    {
        ! V{ } H{ } V{ 3 } { 3 } { } "" "asdf"
        pi 1/0. -1/0. 0/0. [ ]
        f t "" 0 0.0 3.14 2 -3 -7 20 3/4 -3/4 1.2/3 3.5
        C{ 2 2 } C{ 1/0. 1/0. }
    } ;

