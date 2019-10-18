! Broken by recent changes

USING: kernel vocabs words combinators math
       namespaces arrays sequences assocs sorting
       inspector vars ;

IN: parser
! 
! ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
! : word-restarts ( string -- restarts )
! words-named natural-sort
! [ [ "Use the word " swap summary append ] keep 2array ] map
! { "Define this word as a symbol" 0 } add
! { "Defer this word in the 'scratchpad' vocabulary" f } add ;
! 
! : no-word-option ( obj -- word )
! { { [ dup f = ] [ drop in get create ] }
!   { [ dup 0 = ] [ drop in get create dup define-symbol ] }
!   { [ t ]       [ nip dup word-vocabulary use+ ] }
! } cond ;
! 
VAR: new-symbol-action ! ( str -- word )
! 
! [ dup no-word no-word-option ] new-symbol-action set-global 
! 
! ! For lisp:
! ! 
! ! [ in get create dup define-symbol ] >new-symbol-action
! 
! : search ( str -- word )
! { { [ dup use get assoc-stack ]
!     [ use get assoc-stack ] }
!   { [ dup words-named empty? ]
!     [ new-symbol-action> call ] }
!   { [ dup words-named length 0 > ]
!     [ dup no-word no-word-option ] }
! } cond ;
