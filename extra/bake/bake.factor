
USING: kernel parser combinators sequences splitting quotations arrays macros
       arrays.lib combinators.cleave combinators.conditional newfx ;

IN: bake

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: ,
SYMBOL: @

: comma? ( obj -- ? ) , = ;
: atsym? ( obj -- ? ) @ = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: [bake-array]

: broil-element ( obj -- quot )
    {
      { [ comma? ] [ drop [ >r ]               ] }
      { [ array? ] [ [bake-array] [ >r ] append ] }
      { [ drop t ] [ [ >r ] prefix-on          ] }
    }
  1cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [broil] ( array -- quot )
    [ reverse [ broil-element ] map concat ]
    [ length [ drop [ r> ] ] map concat ]
    [ length [ narray ] prefix-on ]
  tri append append
  >quotation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [simmer] ( array -- quot )

  { @ } split reverse
    [        [ [bake-array] [ append ] append [ >r ] append ] map concat ]
    [ length [ drop [ r> append ]                          ] map concat ]
  bi

  >r 2 head* [ >r ] append r> ! remove the last append

  [ { } ] swap append

  append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [bake-array] ( array -- quot ) [ @ member? ] [ [simmer] ] [ [broil] ] 1if ;

MACRO: bake-array ( array -- quot ) [bake-array] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: `{ \ } [ >array ] parse-literal \ bake-array parsed ; parsing