USING: kernel alien sequences ;
IN: alien-contrib

: copy-seq-to-float-array ( seq byte-array -- byte-array )
swap dup length [ pick set-float-nth ] 2each ;

: >float-array ( seq -- byte-array )
dup length "float" <c-array> copy-seq-to-float-array ;

: float-array>array ( byte-array n -- array ) [ swap float-nth ] map-with ;

PROVIDE: contrib/alien ;