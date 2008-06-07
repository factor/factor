
USING: kernel
       combinators
       sequences
       math
       io.sockets
       unicode.case
       accessors
       combinators.cleave
       newfx
       dns ;

IN: dns.server

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: records ( -- vector ) V{ } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: filter-by-name ( records name -- records ) swap [ name>> = ] with filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: {name-type-class} ( obj -- array )
  { [ name>> >lower ] [ type>> ] [ class>> ] } <arr> ;

: rr=query? ( obj obj -- ? ) [ {name-type-class} ] bi@ = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: matching-rrs  ( query -- rrs ) records [ rr=query? ] with filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: matching-rrs? ( query -- query rrs/f ? ) dup matching-rrs dup empty? not ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: matching-cname? ( query -- query rr/f ? )
  dup clone CNAME >>type matching-rrs
  dup empty? [ drop f f ] [ 1st t ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: query->rrs

: query-canonical ( query rr -- rrs )
  tuck [ clone ] [ rdata>> ] bi* >>name query->rrs prefix-on ;

: query->rrs ( query -- rrs/f )
    {
      { [      matching-rrs?   ] [ nip ] }
      { [ drop matching-cname? ] [ query-canonical ] }
      { [ drop t               ] [ drop f ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cdr-name ( name -- name ) dup CHAR: . index 1+ tail ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: delegate-servers? ( name -- name rrs ? )
  dup NS IN query boa matching-rrs dup empty? not ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: delegate-servers ( name -- rrs )
    {
      { [ dup "" = ]          [ drop { } ] }
      { [ delegate-servers? ] [ nip ] }
      { [ drop t ]            [ cdr-name delegate-servers ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: delegate-addresses ( rrs-ns -- rrs-a )
  [ rdata>> A IN query boa matching-rrs ] map concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: have-delegates? ( query -- query rrs-ns ? )
  dup name>> delegate-servers dup empty? not ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fill-additional ( message -- message )
  dup authority-section>> delegate-addresses >>additional-section ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: no-records-with-name? ( query -- query ? )
  dup name>> records [ name>> = ] with filter empty? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: find-answer ( message -- message )
  dup message-query                     ! message query
    {
      { [ dup query->rrs dup   ] [ nip >>answer-section 1 >>aa ] }
      { [ drop have-delegates? ] [ nip >>authority-section fill-additional ] }
      { [ drop no-records-with-name? ] [ drop NAME-ERROR >>rcode ] }
      { [ drop t ] [ ] }
    }
  cond ;

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