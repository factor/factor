
USING: kernel combinators quotations arrays sequences assocs macros fry ;

IN: combinators.short-circuit

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: short-circuit ( quots quot default -- quot )
    1quotation -rot { } map>assoc <reversed> alist>quot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: 0&& ( quots -- quot )
  [ '[ drop @ dup not ] [ drop f ] 2array ] map
  { [ t ] [ ] }                       suffix
  '[ f , cond ] ;

MACRO: 1&& ( quots -- quot )
  [ '[ drop dup @ dup not ] [ drop drop f ] 2array ] map
  { [ t ] [ nip ] }                                  suffix
  '[ f , cond ] ;

MACRO: 2&& ( quots -- quot )
  [ '[ drop 2dup @ dup not ] [ drop 2drop f ] 2array ] map
  { [ t ] [ 2nip ] }                                   suffix
  '[ f , cond ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: 0|| ( quots -- quot )
  [ '[ drop @ dup ] [ ] 2array ] map
  { [ drop t ] [ f ] } suffix
  '[ f , cond ] ;

MACRO: 1|| ( quots -- quot )
  [ '[ drop dup @ dup ] [ nip ] 2array ] map
  { [ drop drop t ] [ f ] }              suffix
  '[ f , cond ] ;

MACRO: 2|| ( quots -- quot )
  [ '[ drop 2dup @ dup ] [ 2nip ] 2array ] map
  { [ drop 2drop t ] [ f ] }               suffix
  '[ f , cond ] ;
