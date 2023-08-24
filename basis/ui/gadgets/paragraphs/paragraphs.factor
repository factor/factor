! Copyright (C) 2005, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel math math.order sequences
ui.baseline-alignment ui.gadgets ui.gadgets.labels
ui.gadgets.packs.private ui.render wrap.words ;
IN: ui.gadgets.paragraphs

MIXIN: word-break

! A word break gadget
TUPLE: word-break-gadget < label ;

: <word-break-gadget> ( text -- gadget )
    word-break-gadget new-label ;

M: word-break-gadget draw-gadget* drop ;

INSTANCE: word-break-gadget word-break

! A gadget that arranges its children in a word-wrap style.
TUPLE: paragraph < aligned-gadget margin wrapped ;

: <paragraph> ( margin -- gadget )
    paragraph new
    horizontal >>orientation
    swap >>margin ;

<PRIVATE

: gadget>word ( gadget -- word )
    [ ] [ pref-dim first ] [ word-break? ] tri <wrapping-word> ;

: line-width ( words -- n )
    [ break?>> ] trim-tail-slice [ width>> ] map-sum ;

TUPLE: line words width height baseline ;

: <line> ( words -- line )
    [ ] [ line-width ] [ [ key>> ] map dup pref-dims ] tri
    measure-height-metrics drop line boa ;

: wrap-paragraph ( paragraph -- wrapped-paragraph )
    [ children>> [ gadget>word ] map ] [ margin>> ] bi
    wrap-words [ <line> ] map! ;

: cached-wrapped ( paragraph -- wrapped-paragraph )
    [ wrapped>> ]
    [ [ wrap-paragraph dup ] keep wrapped<< ] ?unless ;

: max-line-width ( wrapped-paragraph -- x )
    [ width>> ] [ max ] map-reduce ;

: sum-line-heights ( wrapped-paragraph -- y )
    [ height>> ] map-sum ;

M: paragraph pref-dim*
    cached-wrapped [
        { 0 0 }
    ] [
        [ max-line-width ] [ sum-line-heights ] bi 2array
    ] if-empty ;

: line-y-coordinates ( wrapped-paragraph -- ys )
    0 [ height>> + ] accumulate nip ;

: word-x-coordinates ( wrapped-line -- xs )
    0 [ width>> + ] accumulate nip ;

: layout-word ( word x y -- )
    [ key>> ] 2dip 2array >>loc prefer ;

: layout-line ( wrapped-line y -- )
    [
        words>>
        [ ]
        [ word-x-coordinates ]
        [ [ key>> ] map align-baselines ] tri
    ] dip '[ _ + layout-word ] 3each ;

M: paragraph layout*
    f >>wrapped
    cached-wrapped dup line-y-coordinates [ layout-line ] 2each ;

M: paragraph baseline*
    cached-wrapped [ f ] [ first baseline>> ] if-empty ;

M: paragraph cap-height* pack-cap-height ;

PRIVATE>
