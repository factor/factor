USING: accessors arrays delegate delegate.protocols
io.pathnames kernel locals sequences
vectors make strings models.combinators ui.gadgets.controls
sequences.extras ;
IN: file-trees

TUPLE: walkable-vector vector father ;
CONSULT: sequence-protocol walkable-vector vector>> ;

M: walkable-vector set-nth [ vector>> set-nth ] 3keep nip
   father>> swap children>> vector>> push ;

TUPLE: tree node comment children ;
CONSULT: sequence-protocol tree children>> ;

: file? ( tree -- ? ) children>> [ node>> ".." = not ] filter empty? ;

: <dir-tree> ( {start,comment} -- tree ) first2 walkable-vector new vector new >>vector
   [ tree boa dup children>> ] [ ".." -rot tree boa ] 2bi swap (>>father) ;

DEFER: (tree-insert)

: tree-insert ( path tree -- ) [ unclip <dir-tree> ] [ children>> ] bi* (tree-insert) ;
:: (tree-insert) ( path-rest path-head tree-children -- )
   tree-children [ node>> path-head node>> = ] find nip
   [ path-rest swap tree-insert ]
   [ 
      path-head tree-children push
      path-rest [ path-head tree-insert ] unless-empty
   ] if* ;

: add-paths ( pathseq -- {{name,path}} )
   "" [ [ "/" glue dup ] keep swap 2array , ] [ reduce drop ] f make ;

: go-to-path ( path tree -- tree' ) over empty? [ nip ]
   [ [ unclip ] [ children>> ] bi* swap [ swap node>> = ] curry find nip go-to-path ] if ;

: find-root ( pathseq -- root ) dup flip
   [ [ dupd = [ ] [ drop f ] if ] reduce1 ] find-last drop
      [ first ] dip head-slice >string path-components ;

: create-tree ( file-list -- tree ) [ find-root ]
   [ [ path-components add-paths ] map { "/" "/" } <dir-tree> [ [ tree-insert ] curry each ] keep ] bi
   go-to-path ;

: <dir-table> ( tree-model -- table )
   <list*> [ node>> 1array ] >>quot
   [ selected>> [ file? not ] filter-model swap switch-models ]
   [ swap >>model ] bi ;
