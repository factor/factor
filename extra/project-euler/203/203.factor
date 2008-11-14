USING: fry kernel math math.primes.factors sequences sets ;
IN: project-euler.203

: iterate ( n initial quot -- results ) swapd '[ @ dup ] replicate nip ; inline
: (generate) ( seq -- seq ) [ 0 prefix ] [ 0 suffix ] bi [ + ] 2map ;
: generate ( n -- seq ) 1- { 1 } [ (generate) ] iterate concat prune ;
: squarefree ( n -- ? ) factors duplicates empty? ;
: solve ( n -- n ) generate [ squarefree ] filter sum ;
: euler203 ( -- n ) 51 solve ;
