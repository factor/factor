USING: accessors assocs fry generalizations kernel locals math
namespaces parser sequences shuffle words ;
IN: set-n
: get* ( var n -- val ) namestack dup length rot - head assoc-stack ;

: set* ( val var n -- ) 1 + namestack [ length swap - ] keep nth set-at ;

! dynamic lambda
SYNTAX: :| (:) dup in>> dup length [ spin '[ _ narray _ swap zip _ bind ] ] 2curry dip define-declared ;
