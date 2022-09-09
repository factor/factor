! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex io.pathnames
kernel sequences system ui.images ui.pens.image ui.pens.solid ;
IN: ui.tools.environment.theme

CONSTANT: content-background-colour HEXCOLOR: 002b36

CONSTANT: dark-background { HEXCOLOR: 5C8284 HEXCOLOR: 26515A }
CONSTANT: green-background { HEXCOLOR: ACDC3F HEXCOLOR: 79B900 }
CONSTANT: white-background { HEXCOLOR: D4DFDF HEXCOLOR: A3BEBD }
CONSTANT: blue-background { HEXCOLOR: 56C5FF HEXCOLOR: 1B94FF }
CONSTANT: red-background { HEXCOLOR: FF7C65 HEXCOLOR: FE2F26 }
CONSTANT: yellow-background { HEXCOLOR: DCC23F HEXCOLOR: B9A013 }
CONSTANT: inactive-background { HEXCOLOR: 004457 HEXCOLOR: 002B36 }
CONSTANT: active-background { HEXCOLOR: 006581 HEXCOLOR: 004153 }

CONSTANT: content-text-colour HEXCOLOR: E5E5E5
CONSTANT: dark-text-colour COLOR: black
CONSTANT: light-text-colour HEXCOLOR: C4DCDE
CONSTANT: faded-text-colour HEXCOLOR: 93A1A1

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
