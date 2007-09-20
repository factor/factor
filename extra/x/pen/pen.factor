
USING: kernel arrays math.vectors mortar x.gc slot-accessors geom.pos ;

IN: x.pen

SYMBOL: <pen>

<pen> <pos> { "window" "gc" } accessors define-simple-class

<pen> "create" !( window <pen> -- pen )
[ new-empty swap >>window <gc> new* >>gc 0 0 2array >>pos ]
add-class-method

<pen> {

"line-to" ! ( pen point -- pen )
  [ 2dup >r dup $window swap dup $gc swap $pos r> <---- draw-line >>pos ]

"line-by" ! ( pen offset -- pen )
  [ 2dup >r dup $window swap dup $gc swap $pos dup r> v+ <---- draw-line
    <-- move-by ]

"draw-string" ! ( pen string -- pen )
  [ >r dup dup $window swap dup $gc swap $pos r> <---- draw-string ]

} add-methods