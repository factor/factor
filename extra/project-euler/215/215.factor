USING: accessors kernel locals math ;
IN: project-euler.215

TUPLE: block two three ;
TUPLE: end { ways integer } ;

C: <block> block
C: <end> end
: <failure> 0 <end> ; inline
: <success> 1 <end> ; inline

: failure? ( t -- ? ) ways>> 0 = ; inline

: choice ( t p q -- t t ) [ [ two>> ] [ three>> ] bi ] 2dip bi* ; inline

GENERIC: merge ( t t -- t )
GENERIC# block-merge 1 ( t t -- t )
GENERIC# end-merge 1 ( t t -- t )
M: block merge block-merge ;
M: end   merge end-merge ;
M: block block-merge [ [ two>>   ] bi@ merge ]
                     [ [ three>> ] bi@ merge ] 2bi <block> ;
M: end   block-merge nip ;
M: block end-merge drop ;
M: end   end-merge [ ways>> ] bi@ + <end> ;

GENERIC: h-1 ( t -- t )
GENERIC: h0 ( t -- t )
GENERIC: h1 ( t -- t )
GENERIC: h2 ( t -- t )

M: block h-1 [ h1 ] [ h2 ] choice merge ;
M: block h0 drop <failure> ;
M: block h1 [ [ h1 ] [ h2 ] choice merge ]
            [ [ h0 ] [ h1 ] choice merge ] bi <block> ;
M: block h2 [ h1 ] [ h2 ] choice merge <failure> swap <block> ;

M: end h-1 drop <failure> ;
M: end h0 ;
M: end h1 drop <failure> ;
M: end h2 dup failure? [ <failure> <block> ] unless ;

: next-row ( t -- t ) [ h-1 ] [ h1 ] choice swap <block> ;

: first-row ( n -- t )
  [ <failure> <success> <failure> ] dip
  1- [| a b c | b c <block> a b ] times 2drop ;

GENERIC: total ( t -- n )
M: block total [ total ] dup choice + ;
M: end   total ways>> ;

: solve ( width height -- ways )
  [ first-row ] dip 1- [ next-row ] times total ;

: euler215 ( -- ways ) 32 10 solve ;
