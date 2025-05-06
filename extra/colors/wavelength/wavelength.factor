USING: colors combinators kernel math math.functions ;
IN: colors.wavelength

:: wavelength>rgba ( w -- rgba )
    {
        { [ w 380 >= w 440 < and ] [ 440 w - 440 380 - / 0.0 1.0 ] }
        { [ w 440 >= w 490 < and ] [ 0.0 w 440 - 490 440 - / 1.0 ] }
        { [ w 490 >= w 510 < and ] [ 0.0 1.0 510 w - 510 490 - / ] }
        { [ w 510 >= w 580 < and ] [ w 510 - 580 510 - / 1.0 0.0 ] }
        { [ w 580 >= w 645 < and ] [ 1.0 645 w - 645 580 - / 0.0 ] }
        { [ w 645 >= w 781 < and ] [ 1.0 0.0 0.0 ] }
        [ 0.0 0.0 0.0 ]
    } cond :> ( r g b )

    {
        { [ w 380 >= w 420 < and ] [ w 380 - 420 380 - / 0.7 * 0.3 + ] }
        { [ w 420 >= w 701 < and ] [ 1.0 ] }
        { [ w 701 >= w 781 < and ] [ 780 w - 780 700 - / 0.7 * 0.3 + ] }
        [ 0.0 ]
    } cond :> factor

    0.80 :> gamma

    r g b [ dup 0 > [ factor * gamma ^ ] [ drop 0.0 ] if ] tri@ 1.0 <rgba> ;
