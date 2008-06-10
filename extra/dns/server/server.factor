
USING: kernel
       combinators
       sequences
       math
       io.sockets
       unicode.case
       accessors
       combinators.cleave combinators.lib
       newfx
       dns dns.util ;

IN: dns.server

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: records ( -- vector ) V{ } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: {name-type-class} ( obj -- array )
  { [ name>> >lower ] [ type>> ] [ class>> ] } <arr> ;

: rr=query? ( obj obj -- ? ) [ {name-type-class} ] bi@ = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: matching-rrs  ( query -- rrs ) records [ rr=query? ] with filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! query->rrs
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: query->rrs

: matching-rrs? ( query -- rrs/f ) matching-rrs [ empty? ] [ drop f ] [ ] 1if ;

: matching-cname? ( query -- rrs/f )
  [ ] [ clone CNAME >>type matching-rrs ] bi ! query rrs
  [ empty? not ]
    [ 1st swap clone over rdata>> >>name query->rrs prefix-on ]
    [ 2drop f ]
  1if ;

: query->rrs ( query -- rrs/f ) { [ matching-rrs? ] [ matching-cname? ] } 1|| ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! have-answers
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: have-answers ( message -- message/f )
  dup message-query query->rrs        ! message rrs/f
  [ empty? ] [ 2drop f ] [ >>answer-section ] 1if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! have-delegates?
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cdr-name ( name -- name ) dup CHAR: . index 1+ tail ;

: is-soa? ( name -- ? ) SOA IN query boa matching-rrs empty? not ;

: have-ns? ( name -- rrs/f )
  NS IN query boa matching-rrs [ empty? ] [ drop f ] [ ] 1if ;

: name->delegates ( name -- rrs-ns )
  {
    [ "" =    { } and ]
    [ is-soa? { } and ]
    [ have-ns? ]
    [ cdr-name name->delegates ]
  }
    1|| ;

: have-delegates ( message -- message/f )
  dup message-query name>> name->delegates ! message rrs-ns
  [ empty? ]
    [ 2drop f ]
    [
      dup [ rdata>> A IN query boa matching-rrs ] map concat
                                           ! message rrs-ns rrs-a
      [ >>authority-section ]
      [ >>additional-section ]
      bi*
    ]
  1if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! is-nx
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: is-nx ( message -- message/f )
  [ message-query name>> records [ name>> = ] with filter empty? ]
    [ NAME-ERROR >>rcode ]
    [ drop f ]
  1if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: find-answer ( message -- message )
    { [ have-answers ] [ have-delegates ] [ is-nx ] [ ] } 1|| ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (socket) ( -- vec ) V{ f } ;

: socket ( -- socket ) (socket) 1st ;

: init-socket-on-port ( port -- )
  f swap <inet4> <datagram> 0 (socket) as-mutate ;

: init-socket ( -- ) 53 init-socket-on-port ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: loop ( -- )
  socket receive
  swap
  parse-message
  find-answer
  message->ba
  swap
  socket send
  loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start ( -- ) init-socket loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: start
