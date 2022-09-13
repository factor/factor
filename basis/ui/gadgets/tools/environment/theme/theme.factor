! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors kernel ui.pens.solid ;
IN: ui.tools.environment.theme

CONSTANT: content-background-colour COLOR: #002b36

CONSTANT: dark-background { COLOR: #5C8284 COLOR: #26515A }
CONSTANT: green-background { COLOR: #ACDC3F COLOR: #79B900 }
CONSTANT: white-background { COLOR: #D4DFDF COLOR: #A3BEBD }
CONSTANT: blue-background { COLOR: #56C5FF COLOR: #1B94FF }
CONSTANT: red-background { COLOR: #FF7C65 COLOR: #FE2F26 }
CONSTANT: yellow-background { COLOR: #DCC23F COLOR: #B9A013 }
CONSTANT: inactive-background { COLOR: #004457 COLOR: #002B36 }
CONSTANT: active-background { COLOR: #006581 COLOR: #004153 }

CONSTANT: content-text-colour COLOR: #E5E5E5
CONSTANT: dark-text-colour COLOR: black
CONSTANT: light-text-colour COLOR: #C4DCDE
CONSTANT: faded-text-colour COLOR: #93A1A1

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
