
USING: sequences mortar slot-accessors ;

IN: geom.dim

SYMBOL: <dim>

<dim> { "dim" } accessors define-independent-class

<dim> {

"width" !( dim -- width ) [ $dim first ]

"height" !( dim -- second ) [ $dim second ]

} add-methods