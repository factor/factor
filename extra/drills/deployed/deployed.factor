USING: accessors arrays cocoa.dialogs combinators continuations
fry grouping io.encodings.utf8 io.files io.styles kernel math
math.parser models models.arrow models.history namespaces random
sequences splitting ui ui.gadgets.alerts ui.gadgets.book-extras
ui.gadgets.books ui.gadgets.buttons ui.gadgets.frames
ui.gadgets.grids ui.gadgets.labels ui.gadgets.tracks fonts
wrap.strings system ;

IN: drills.deployed
SYMBOLS: it startLength ;
: big ( gadget -- gadget ) T{ font { name "sans-serif" } { size 30 } } >>font ;
: card ( model quot -- button ) <arrow> <label-control> big [ next ] <book-btn> ;
: op ( quot str -- gadget ) <label> big swap <book-bevel-btn> ;

: show ( model -- gadget ) dup it set-global [ random ] <arrow>
   { [ [ first ] card ]
     [ [ second ] card ]
     [ '[ |<< it get _ model-changed ] "No" op ]
          [ '[ |<< [ it get [
        _ value>> swap remove
        [ [ it get go-back ] "Drill Complete" alert return ] when-empty
     ] change-model ] with-return ] "Yes" op ]
   } cleave
2array { 1 0 } <track> swap [ 0.5 track-add ] each
3array <book*> 3 3 <frame> { 1 1 } >>filled-cell { 450 175 } >>pref-dim swap { 1 1 } grid-add
it get [ length startLength get swap - number>string "/" startLength get number>string 3append ] <arrow> <label-control> { 1 2 } grid-add ;

: drill ( -- ) [
   open-panel [
         [ utf8 file-lines [ "\t" split [ 25 wrap-string ] map ] map dup [ first2 swap 2array ] map append ] map concat
            [ length startLength set-global ] keep <history> [ add-history ] [ show ] bi
         "Got it?" open-window
   ] [ 0 exit ] if*
] with-ui ;

MAIN: drill