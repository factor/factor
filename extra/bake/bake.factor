
USING: kernel parser namespaces sequences quotations arrays vectors splitting
       macros arrays.lib combinators.lib combinators.conditional newfx ;

IN: bake

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: ,
SYMBOL: @

: comma? ( obj -- ? ) , = ;
: atsym? ( obj -- ? ) @ = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: [bake]

: broil-element ( obj -- quot )
    {
      { [ comma?    ] [ drop [ >r ]          ] }
      { [ sequence? ] [ [bake] [ >r ] append ] }
      { [ drop t    ] [ [ >r ] prefix-on     ] }
    }
  1cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: constructor ( seq -- quot )
    {
      { [ array? ]     [ length [ narray ] prefix-on ] }
      { [ quotation? ] [ length [ ncurry ] prefix-on [ ] prefix ] }
      { [ vector? ]    [ length [ narray >vector ] prefix-on ] }
    }
  1cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [broil] ( seq -- quot )
    [ reverse [ broil-element ] map concat ]
    [ length  [ drop [ r> ]   ] map concat ]
    [ constructor ]
  tri append append
  >quotation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: saved-sequence

: [connector] ( -- quot )
  saved-sequence get quotation? [ [ compose ] ] [ [ append ] ] if ;

: [starter] ( -- quot )
  saved-sequence get
    {
      { [ quotation? ] [ drop [  [ ] ] ] }
      { [ array?     ] [ drop [  { } ] ] }
      { [ vector?    ] [ drop [ V{ } ] ] }
    }
  1cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [simmer] ( seq -- quot )

  dup saved-sequence set

  { @ } split reverse
    [ [ [bake] [connector] append [ >r ] append ] map concat ]
    [ length [ drop [ r> ] [connector] append   ] map concat ]
  bi

  >r 1 invert-index pluck r> ! remove the last append/compose

  [starter] prepend

  append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [bake] ( seq -- quot ) [ @ member? ] [ [simmer] ] [ [broil] ] 1if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: bake ( seq -- quot ) [bake] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: `{  \ } [ >array     ] parse-literal \ bake parsed ; parsing
: `V{ \ } [ >vector    ] parse-literal \ bake parsed ; parsing
: `[  \ ] [ >quotation ] parse-literal \ bake parsed ; parsing