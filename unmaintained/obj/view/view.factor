
USING: kernel words namespaces arrays sequences prettyprint
       help.topics help.markup bake combinators.cleave
       obj obj.misc obj.print ;

IN: obj.view

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: $tab ( seq -- ) first print-table ;
: $obj ( seq -- ) first print-table ;
: $seq ( seq -- ) first print-seq   ;
: $ptr ( seq -- ) first get print-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PREDICATE: obj-type < symbol types member? ;

M: obj-type article-title ( type -- title ) unparse ;

M: obj-type article-content ( type -- content )
   objects [ type -> = ] with filter
   { $seq , } bake ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: ptr article-title ( ptr -- title ) [ title -> ] [ unparse ] bi or ;

M: ptr article-content ( ptr -- content )
   {
     [ get     { $obj , } bake ]
     [ drop { $heading "Related\n" } ]
     [ related { $seq , } bake ]
   }
   1arr ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PREDICATE: obj-list < word \ objects = ;

M: obj-list article-title ( objects -- title ) drop "Objects" ;

! M: obj-list article-content ( objects -- title )
!    execute
!    [ [ type -> ] [ ] bi 2array ] map
!    { $tab , } bake ;

M: obj-list article-content ( objects -- title )
   drop
   objects
   [ [ type -> ] [ ] bi 2array ] map
   { $tab , } bake ;