
USING: kernel strings arrays sequences sequences.lib math x11.xlib
       mortar slot-accessors x x.pen x.widgets ;

IN: x.widgets.keymenu

SYMBOL: <keymenu>

<keymenu> <widget> { "items" "pen" } accessors define-simple-class

<keymenu> "create" !( <keymenu> -- keymenu )
  [ new-empty <- keymenu-init ]
add-class-method

: numbers-and-letters ( -- seq )
"1234567890abcdefghijklmnopqrstuvwxyz" [ 1string ] { } map-as ;

<keymenu> {

"keymenu-init" !( keymenu -- keymenu ) [
  dup <pen> new* >>pen
  ExposureMask KeyPressMask bitor >>mask
  <- init-widget
]

"item-labels" !( keymenu -- labels ) [ $items [ first ] map ]

"item-actions" !( keymenu -- actions ) [ $items [ second ] map ]

"keymenu-labels" !( keymenu -- seq )
[ numbers-and-letters swap <- item-labels [ " - " swap 3append ] 2map ]

"reset-pen" !( keymenu -- keymenu ) [
  dup $pen
    1 <-- set-x
    dup $gc $font <- ascent 1+ <-- set-y
  drop ]

"handle-expose" !( event keymenu -- ) [
  nip
  <- reset-pen
  dup $pen swap <- keymenu-labels
  [ <-- draw-string dup $gc $font <- height <-- move-by-y ] each drop ]

"keymenu-handle-key-press" !( event keymenu -- ) [
  swap 0 key-event-to-string numbers-and-letters index
  [ swap <- item-actions ?nth [ call ] when* ]
  [ drop ]
  if* ]

"handle-key-press" !( event keymenu -- ) [ <- keymenu-handle-key-press ]

"calc-height" !( keymenu -- height )
  [ dup $items length swap $pen $gc $font <- height * ]

"calc-width" !( keymenu -- width )
  [ dup $pen $gc $font
    swap $items [ first "    " append ] map
    dup empty? [ drop "" ] [ longest ] if
    <-- text-width ]

"calc-size" !( keymenu -- size )
  [ dup <- calc-width swap <- calc-height 2array ]

} add-methods