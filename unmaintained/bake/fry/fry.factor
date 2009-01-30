
USING: kernel combinators arrays vectors quotations sequences splitting
       parser macros sequences.deep
       combinators.short-circuit combinators.conditional bake newfx ;

IN: bake.fry

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: _

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: (shallow-fry)
DEFER: shallow-fry

: ((shallow-fry)) ( accum quot adder -- result )
  >r shallow-fry r>
  append swap dup empty?
    [ drop ]
    [ [ prepose ] curry append ]
  if ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (shallow-fry) ( accum quot -- result )
  dup empty?
    [ drop 1quotation ]
    [
      unclip
        {
          { \ , [ [ curry   ] ((shallow-fry)) ] }
          { \ @ [ [ compose ] ((shallow-fry)) ] }
          [ swap >r suffix r> (shallow-fry) ]
        }
      case
    ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: shallow-fry ( quot -- quot' ) [ ] swap (shallow-fry) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: deep-fry ( quot -- quot )
  { _ } split1-last dup
    [
      shallow-fry [ >r ] rot
      deep-fry    [ [ dip ] curry r> compose ] 4array concat
    ]
    [ drop shallow-fry ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bakeable? ( obj -- ? ) { [ array? ] [ vector? ] } 1|| ;

: fry-specifier? ( obj -- ? ) { , @ } member-of? ;

: count-inputs ( quot -- n ) flatten [ fry-specifier? ] count ;

: commas ( n -- seq ) , <repetition> ;

: [fry] ( quot -- quot' )
    [
        {
          { [ callable? ] [ [ count-inputs commas ] [ [fry]  ] bi append ] }
          { [ bakeable? ] [ [ count-inputs commas ] [ [bake] ] bi append ] }
          { [ drop t    ] [ 1quotation                                   ] }
        }
      1cond
    ]
  map concat deep-fry ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: fry ( seq -- quot ) [fry] ;

: '[ \ ] [ >quotation ] parse-literal \ fry parsed ; parsing
