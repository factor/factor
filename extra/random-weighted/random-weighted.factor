
USING: kernel quotations sequences math math.vectors random ;

IN: random-weighted

: probabilities ( weights -- probabilities )
dup sum [ / ] curry map ;

: layers ( probabilities -- layers )
dup length 1+ [ head ] curry* map 1 tail [ sum ] map ;

: random-weighted ( weights -- elt )
probabilities layers [ 1000 * ] map 1000 random [ > ] curry find drop ;

: random-weighted* ( seq -- elt )
dup [ second ] map swap [ first ] map random-weighted swap nth ;