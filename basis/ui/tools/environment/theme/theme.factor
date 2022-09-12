! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs colors kernel math math.parser sequences
sorting sorting.human ui.pens.solid ;
IN: ui.tools.environment.theme

CONSTANT: content-background-colour COLOR: #002b36

CONSTANT: dark-background { COLOR: light-gray  COLOR: dark-gray }
CONSTANT: green-background { COLOR: gray68 COLOR: gray4 }
CONSTANT: white-background { COLOR: gray2 COLOR: gray2 }
CONSTANT: blue-background { COLOR: solarized-base02 COLOR: gray6 }
CONSTANT: red-background { COLOR: DodgerBlue4 COLOR: gray6 }
CONSTANT: yellow-background { COLOR: gray5 COLOR: gray4 }
CONSTANT: inactive-background { COLOR: dark-green COLOR: FactorDarkGreen }
CONSTANT: active-background { COLOR: DeepSkyBlue4 COLOR: dark-green }

CONSTANT: content-text-colour COLOR: solarized-base02
CONSTANT: dark-text-colour COLOR: black
CONSTANT: light-text-colour COLOR: gray2
CONSTANT: faded-text-colour COLOR: gray2

: set-small-font ( label -- label )
    [ 13 >>size t >>bold? ] change-font ;

: set-font ( label -- label )
    [ 15 >>size t >>bold? ] change-font ;

: set-result-font ( label -- label )
    [ 17 >>size t >>bold? content-text-colour >>foreground ] change-font ;

: faded-color ( rgba -- rgba )
    >rgba-components drop 0.4 <rgba> ;

: with-background ( gadget -- gadget )
    content-background-colour <solid> >>interior ;

: nearest-color ( hex -- color value )
    unclip drop hex>
    named-colors
    [ dup named-color color>hex ] map>alist
    [ second unclip drop hex> number>string
      [ second unclip drop hex> number>string ] dip
      human<=>
    ] sort
    [ second unclip drop hex> over > ] map-find
    2nip  [ first ] keep second 
;
    
: nc ( hex -- ) nearest-color . com-copy-object ; 
    
