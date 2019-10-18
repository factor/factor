
USING: kernel words namespaces combinators math
       quotations strings arrays hashtables sequences
       namespaces.lib rewrite-closures ;

IN: lisp

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: && ( obj seq -- ? ) [ call ] curry* all? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (quote sym)

SYMBOL: quote

: quote-exp? ( exp -- ? ) { [ array? ] [ length 2 = ] [ first quote = ] } && ;

: eval-quote ( exp -- val ) second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: eval-symbol ( exp -- val ) get ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: eval

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (begin ...)

SYMBOL: begin

: begin-exp? ( exp -- ? ) { [ array? ] [ length 2 >= ] [ first begin = ] } && ;

: eval-begin ( exp -- val ) 1 tail dup peek >r 1 head* [ eval ] each r> eval ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (omega parameters ...)

SYMBOL: omega

: omega-exp? ( exp -- ? ) { [ array? ] [ length 3 >= ] [ first omega = ] } && ;

: eval-omega ( exp -- val )
dup second swap 2 tail { begin } swap append [ eval ] curry lambda ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (let ((var val) ...) exp ...)

SYMBOL: let

: let-exp? ( exp -- ? ) { [ array? ] [ length 2 >= ] [ first let = ] } && ;

: eval-let ( exp -- val )
dup >r second [ second ] map r>
dup 2 tail swap second [ first ] map add* omega add* add* eval ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (df name (param ...) exp ...)

SYMBOL: df

: df-exp? ( exp -- ? ) { [ array? ] [ length 3 >= ] [ first df = ] } && ;

: eval-df ( exp -- val ) dup 2 tail omega add* eval swap second tuck set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (dv var val)

SYMBOL: dv

: dv-exp? ( exp -- ? ) { [ array? ] [ length 3 = ] [ first dv = ] } && ;

: eval-dv ( exp -- val ) dup >r third eval r> second set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (set! var val)

SYMBOL: set!

: set!-exp? ( exp -- ? ) { [ array? ] [ length 3 = ] [ first set! = ] } && ;

: eval-set! ( exp -- val ) dup >r third eval r> second set* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (dyn (param ...) exp ...)

SYMBOL: dyn

: dyn-exp? ( exp -- ? ) { [ array? ] [ length 3 >= ] [ first dyn = ] } && ;

: eval-dyn ( exp -- val )
dup second swap 2 tail begin add* [ eval ] curry parametric-quot scoped-quot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (dy name (param ...) exp ...)

SYMBOL: dy

: dy-exp? ( exp -- ? ) { [ array? ] [ length 3 >= ] [ first dy = ] } && ;

: eval-dy ( exp -- val ) dup 2 tail dyn add* eval swap second tuck set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : eval-list ( exp -- val )
! [ eval ] map unclip >r [ ] each r>
! { { [ dup quotation? ] [ call ] }
!   { [ dup word? ]      [ execute ] } }
! cond ;

: eval-list ( exp -- val )
unclip eval >r [ eval ] each r>
{ { [ dup quotation? ] [ call ] }
  { [ dup word? ]      [ execute ] } }
cond ;

! should probably be:

! : eval-list ( exp -- val )
! unclip >r [ eval ] each r> eval
! { { [ dup quotation? ] [ call ] }
!   { [ dup word? ]      [ execute ] } }
! cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: eval ( exp -- val )
{ { [ dup t eq? ]   [ ] }
  { [ dup f eq? ]   [ ] }
  { [ dup number? ] [ ] }
  { [ dup string? ] [ ] }
  { [ dup quotation? ] [ ] }
  { [ dup hashtable? ] [ ] }
  { [ dup quote-exp? ] [ eval-quote ] }
  { [ dup begin-exp? ] [ eval-begin ] }
  { [ dup omega-exp? ] [ eval-omega ] }
  { [ dup let-exp? ]   [ eval-let ] }
  { [ dup df-exp? ]    [ eval-df ] }
  { [ dup dv-exp? ]    [ eval-dv ] }
  { [ dup set!-exp? ]  [ eval-set! ] }
  { [ dup dyn-exp? ]   [ eval-dyn ] }
  { [ dup dy-exp? ]   [ eval-dy ] }
  { [ dup symbol? ] [ eval-symbol ] }
  { [ dup word? ] [ ] }
  { [ dup array? ]  [ eval-list ] }
} cond ;

! : eval-quot-call ( exp -- val ) [ eval ] map unclip >r [ ] each r> call ;

! : eval-word-call ( exp -- val ) [ eval ] map unclip >r [ ] each r> execute ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

