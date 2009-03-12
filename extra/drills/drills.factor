USING: accessors arrays cocoa.dialogs combinators continuations
fry grouping io.encodings.utf8 io.files io.styles kernel math
math.parser models models.filter models.history namespaces random
sequences splitting ui ui.gadgets.alerts ui.gadgets.book-extras
ui.gadgets.books ui.gadgets.buttons ui.gadgets.frames
ui.gadgets.grids ui.gadgets.labels ui.gadgets.tracks ui.gestures ;

IN: drills
SYMBOLS: it startLength ;
: big ( gadget -- gadget ) { "sans-serif" plain 30 } >>font ;
: card ( model quot -- button ) <filter> <label-control> big [ next ] <book-btn> ;
: op ( quot str -- gadget ) <label> big swap <book-bevel-btn> ;

: show ( model -- gadget ) dup it set-global [ random ] <filter>
   { [ [ first ] card ]
   [ [ [ second ] [ drop [ "malformed input" throw ] "Malformed Input" alert ] recover ] card ]
   [ '[ |<< [ it get [
      _ value>> swap remove
      [ [ it get go-back ] "Drill Complete" alert return ] when-empty
   ] change-model ] with-return ] "Yes" op ]
   [ '[ |<< it get _ model-changed ] "No" op ] } cleave
2array { 1 0 } <track> swap [ 0.5 track-add ] each
3array <book*> <frame> { 450 175 } >>pref-dim swap @center grid-add
it get [ length startLength get swap - number>string "/" startLength get number>string 3append ] <filter> <label-control> @bottom grid-add ;

: drill ( -- ) [ 
   open-panel [
      [ utf8 file-lines [ "\t" split
         [ " " split 4 group [ " " join ] map ] map ] map ] map concat dup [ [ first ] [ second ] bi swap 2array ] map append
         [ length startLength set-global ] keep <history> [ add-history ] [ show ] bi
      "Got it?" open-window
   ] when*
] with-ui ;


MAIN: drill

    
! FIXME: command-line opening
! TODO: Menu bar
! TODO: Pious hot-buttons