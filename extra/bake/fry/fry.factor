
USING: kernel combinators arrays vectors quotations sequences splitting
       parser macros sequences.deep combinators.conditional bake newfx ;

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
  { _ } last-split1 dup
    [
      shallow-fry [ >r ] rot
      deep-fry    [ [ dip ] curry r> compose ] 4array concat
    ]
    [ drop shallow-fry ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fry-specifier? ( obj -- ? ) { , @ } member-of? ;

: count-inputs ( quot -- n ) flatten [ fry-specifier? ] count ;

: [fry] ( quot -- quot' )
    [
      {
        {
          [ callable? ]
          [ [ count-inputs \ , <repetition> ] [ [fry] ] bi append ]
        }
        {
          [ array? ]
          [ [ count-inputs \ , <repetition> ] [ [bake] ] bi append ]
        }
        {
          [ vector? ]
          [ [ count-inputs \ , <repetition> ] [ [bake] ] bi append ]
        }
        { [ drop t ] [ 1quotation   ] }
      }
        1cond
    ]
  map concat deep-fry ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: fry ( seq -- quot ) [fry] ;

: `[ \ ] [ >quotation ] parse-literal \ fry parsed ; parsing