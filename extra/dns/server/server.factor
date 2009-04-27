
USING: kernel combinators sequences sets math threads namespaces continuations
       debugger io io.sockets unicode.case accessors destructors
       combinators.short-circuit combinators.smart
       fry arrays
       dns dns.util dns.misc ;

IN: dns.server

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: records-var

: records ( -- records ) records-var get ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: {name-type-class} ( obj -- array )
  [ [ name>> >lower ] [ type>> ] [ class>> ] tri ] output>array ; 

: rr=query? ( obj obj -- ? ) [ {name-type-class} ] bi@ = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: matching-rrs  ( query -- rrs ) records [ rr=query? ] with filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! zones
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: zones    ( -- names ) records [ type>> NS  = ] filter [ name>> ] map prune ;
: my-zones ( -- names ) records [ type>> SOA = ] filter [ name>> ] map ;

: delegated-zones ( -- names ) zones my-zones diff ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! name->zone
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: name->zone ( name -- zone/f )
  zones sort-largest-first [ name-in-domain? ] with find nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! name->authority
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: name->authority ( name -- rrs-ns ) name->zone NS IN query boa matching-rrs ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! extract-names
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rr->rdata-names ( rr -- names/f )
    {
      { [ dup type>> NS    = ] [ rdata>>            1array ] }
      { [ dup type>> MX    = ] [ rdata>> exchange>> 1array ] }
      { [ dup type>> CNAME = ] [ rdata>>            1array ] }
      { [ t ]                  [ drop f ] }
    }
  cond ;

: extract-rdata-names ( message -- names )
  [ answer-section>> ] [ authority-section>> ] bi append
  [ rr->rdata-names ] map concat ;

: extract-names ( message -- names )
  [ message-query name>> ] [ extract-rdata-names ] bi swap prefix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! fill-authority
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fill-authority ( message -- message )
  dup
    extract-names [ name->authority ] map concat prune
    over answer-section>> diff
  >>authority-section ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! fill-additional
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: name->rrs-a ( name -- rrs-a ) A IN query boa matching-rrs ;

: fill-additional ( message -- message )
  dup
    extract-rdata-names [ name->rrs-a ] map concat prune
    over answer-section>> diff
  >>additional-section ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! query->rrs
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: query->rrs

: matching-rrs? ( query -- rrs/f ) matching-rrs [ empty? ] [ drop f ] [ ] 1if ;

: matching-cname? ( query -- rrs/f )
  [ ] [ clone CNAME >>type matching-rrs ] bi ! query rrs
  [ empty? not ]
    [ first swap clone over rdata>> >>name query->rrs swap prefix ]
    [ 2drop f ]
  1if ;

: query->rrs ( query -- rrs/f ) { [ matching-rrs? ] [ matching-cname? ] } 1|| ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! have-answers
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: have-answers ( message -- message/f )
  dup message-query query->rrs
  [ empty? ]
    [ 2drop f ]
    [ >>answer-section fill-authority fill-additional ]
  1if ;

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
! outsize-zones
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: outside-zones ( message -- message/f )
  dup message-query name>> name->zone f =
    [ ]
    [ drop f ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! is-nx
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: is-nx ( message -- message/f )
  [ message-query name>> records [ name>> = ] with filter empty? ]
    [
      NAME-ERROR >>rcode
      dup
        message-query name>> name->zone SOA IN query boa matching-rrs
      >>authority-section
    ]
    [ drop f ]
  1if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: none-of-type ( message -- message )
  dup
    message-query name>> name->zone SOA IN query boa matching-rrs
  >>authority-section ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: find-answer ( message -- message )
    {
      [ have-answers   ]
      [ have-delegates ]
      [ outside-zones  ]
      [ is-nx          ]
      [ none-of-type   ]
    }
  1|| ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (handle-request) ( packet -- )
  [ [ find-answer ] with-message-bytes ] change-data respond ;

: handle-request ( packet -- ) [ (handle-request) ] curry in-thread ;

: receive-loop ( socket -- )
  [ receive-packet handle-request ] [ receive-loop ] bi ;

: loop ( addr-spec -- )
  [ <datagram> '[ _ [ receive-loop ] with-disposal ] try ] [ loop ] bi ;

