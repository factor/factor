
USING: kernel parser namespaces quotations vectors strings
sequences assocs tuples math combinators ;

IN: bake

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: insert-quot expr ;

C: <insert-quot> insert-quot 

: ,[ \ ] [ >quotation <insert-quot> ] parse-literal ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: splice-quot expr ;

C: <splice-quot> splice-quot

: %[ \ ] [ >quotation <splice-quot> ] parse-literal ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: exemplar

: reset-building ( -- ) 1024 <vector> building set ;

: save-exemplar ( seq -- seq ) dup exemplar set ;

: finish-baking ( -- seq ) building get exemplar get like ;

DEFER: bake

: bake-item ( item -- )
  { { [ dup \ , = ]        [ drop , ] }
    { [ dup \ % = ] 	   [ drop % ] }
    { [ dup insert-quot? ] [ insert-quot-expr call , ] }
    { [ dup splice-quot? ] [ splice-quot-expr call % ] }
    { [ dup integer? ]     [ , ] }
    { [ dup string? ]	   [ , ] }
    { [ dup tuple? ]       [ tuple>array bake >tuple , ] }
    { [ dup assoc? ]       [ [ >alist bake ] keep assoc-like , ] }
    { [ dup sequence? ]    [ bake , ] }
    { [ t ] 		   [ , ] } }
  cond ;

: bake-items ( seq -- ) [ bake-item ] each ;

: bake ( seq -- seq )
  [ reset-building save-exemplar bake-items finish-baking ] with-scope ;

