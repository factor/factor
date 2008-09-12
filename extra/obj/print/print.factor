
USING: kernel arrays strings sequences assocs io io.styles prettyprint colors
       combinators.conditional ;

IN: obj.print

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: write-wrapped ( string -- ) H{ { wrap-margin 500 } } [ write ] with-nesting ;

! : print-elt ( val -- )
!   {
!     { [ string? ] [ write-wrapped ] }
!     { [ array?  ] [ [ . ] each    ] }
!     { [ drop t  ] [ . ] }
!   }
!   1cond ;

USING: accessors vocabs help.markup ;

: print-elt ( val -- )
  {
    { [ vocab?  ] [ [ name>> ] [ ] bi write-object ] }
    { [ string? ] [ write-wrapped ] }
    { [ array?  ] [ [ . ] each    ] }
    { [ drop t  ] [ . ] }
  }
  1cond ;

: print-grid ( grid -- )
  H{ { table-gap { 10 10 } } { table-border T{ rgba f 0 0 0 1 } } }
  [ [ [ [ [ print-elt ] with-cell ] each ] with-row ] each ] tabular-output ;

: print-table ( assoc -- ) >alist print-grid ;

: print-seq ( seq -- ) [ 1array ] map print-grid ;

