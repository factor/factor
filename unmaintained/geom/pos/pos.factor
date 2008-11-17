
USING: kernel arrays sequences math.vectors mortar slot-accessors ;

IN: geom.pos

SYMBOL: <pos>

<pos> { "pos" } accessors define-independent-class

<pos> {

"x" !( pos -- x ) [ $pos first ]

"y" !( pos -- y ) [ $pos second ]

"set-x" !( pos x -- pos ) [ 0 pick $pos set-nth ]

"set-y" !( pos y -- pos ) [ 1 pick $pos set-nth ]

"distance" !( pos pos -- distance ) [ $pos swap $pos v- norm ]

"move-by" !( pos offset -- pos ) [ over $pos v+ >>pos ]

"move-by-x" !( pos x-offset -- pos ) [ 0 2array <-- move-by ]

"move-by-y" !( pos y-offset -- pos ) [ 0 swap 2array <-- move-by ]

} add-methods