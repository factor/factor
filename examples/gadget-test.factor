! TrueType font rendering demo.
!
! To run this code, bootstrap Factor like so:
!
! ./f boot.image.le32
!     -libraries:sdl:name=libSDL.so
!     -libraries:sdl-gfx:name=libSDL_gfx.so
!     -libraries:sdl-ttf:name=libSDL_ttf.so
!
! (But all on one line)
!
! Then, start Factor as usual (./f factor.image) and enter this
! at the listener:
!
! "examples/text-demo.factor" run-file

IN: text-demo
USE: streams
USE: sdl
USE: sdl-event
USE: sdl-gfx
USE: sdl-video
USE: sdl-ttf
USE: namespaces
USE: math
USE: kernel
USE: test
USE: compiler
USE: strings
USE: alien
USE: prettyprint
USE: lists
USE: gadgets
USE: generic
USE: stdio
USE: prettyprint
USE: words

: grab ( gadget hand -- )
    [ swap screen-pos swap screen-pos - >rect ] 2keep
    >r [ move-gadget ] keep r> add-gadget ;

: release ( gadget world -- )
    >r dup screen-pos >r
    dup unparent
    r> >rect pick move-gadget
    r> add-gadget ;

: moving-actions
    {{
            [[ [ button-down 1 ] [ my-hand grab ] ]]
        [[ [ button-up 1 ] [ world get release ] ]]
    }} swap set-gadget-gestures ;

: filled? "filled" get checkbox-selected? ;

: <funny-rect>
    filled? [ <plain-rect> ] [ <hollow-rect> ] ifte <gadget> dup moving-actions ;

: <funny-ellipse>
    filled? [ <plain-ellipse> ] [ <hollow-ellipse> ] ifte <gadget> dup moving-actions ;

: <funny-line>
    <line> <gadget> dup moving-actions ;

: make-shapes ( -- )
    f world get set-gadget-children
    
    default-gap <pile> "pile" set
    default-gap <shelf> "shelf" set
    "Close" [ "dialog" get world get remove-gadget ] <button> "shelf" get add-gadget
    "New Rectangle" [ drop 100 100 100 100 <funny-rect> dup [ 255 255 0 ] background set-paint-property world get add-gadget ] <button> "shelf" get add-gadget
    "New Ellipse" [ drop 100 100 200 100 <funny-ellipse> dup [ 0 255 0 ] background set-paint-property world get add-gadget ] <button> "shelf" get add-gadget
    "New Line" [ drop 100 100 200 100 <funny-line> dup [ 255 0 0 ] background set-paint-property world get add-gadget ] <button> "shelf" get add-gadget
    "Filled?" <checkbox> dup "filled" set "shelf" get add-gadget
    "shelf" get "pile" get add-gadget
    "Welcome to Factor " version cat2 <label> "pile" get add-gadget
    "A field."  <field> "pile" get add-gadget
    "Another field."  <field> "pile" get add-gadget

    "pile" get bevel-border dup "dialog" set dup  
 moving-actions
  world get add-gadget ;

: gadget-demo ( -- )
    make-shapes
    start-world ;

gadget-demo
