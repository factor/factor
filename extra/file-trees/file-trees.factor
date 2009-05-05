USING: accessors arrays delegate delegate.protocols
io.pathnames kernel locals namespaces prettyprint sequences
ui.frp vectors ;
IN: file-trees

TUPLE: tree node children ;
CONSULT: sequence-protocol tree children>> ;

: <tree> ( start -- tree ) V{ } clone
   [ tree boa dup children>> ] [ ".." swap tree boa ] bi swap push ;

DEFER: (tree-insert)

: tree-insert ( path tree -- ) [ unclip <tree> ] [ children>> ] bi* (tree-insert) ;
:: (tree-insert) ( path-rest path-head tree-children -- )
   tree-children [ node>> path-head node>> = ] find nip
   [ path-rest swap tree-insert ]
   [ 
      path-head tree-children push
      path-rest [ path-head tree-insert ] unless-empty
   ] if* ;
: create-tree ( file-list -- tree ) [ path-components ] map
   t <tree> [ [ tree-insert ] curry each ] keep ;

: <dir-table> ( tree-model -- table )
   <frp-list*> [ node>> 1array ] >>quot
   [ selected-value>> <switch> ]
   [ swap >>model ] bi ;