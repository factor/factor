
USING: kernel
       combinators
       vectors
       io.sockets
       accessors
       newfx
       dns dns.cache ;

IN: dns.forwarding

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DNS server - caching, forwarding
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (socket) ( -- vec ) V{ f } ;

: socket ( -- socket ) (socket) 1st ;

: init-socket ( -- ) f 5353 <inet4> <datagram> 0 (socket) as-mutate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (upstream-server) ( -- vec ) V{ f } ;

: upstream-server ( -- ip ) (upstream-server) 1st ;

: set-upstream-server ( ip -- ) 0 (upstream-server) as-mutate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: query->answer/cache ( query -- rrs/NX/f )
    {
      { [ dup type>> CNAME = ] [ cache-get* ] }
      {
        [ dup clone CNAME >>type cache-get* vector? ]
        [
          dup clone CNAME >>type cache-get* 1st       ! query rr/cname
          dup rdata>>                                 ! query rr/cname cname
          >r swap clone r>                            ! rr/cname query cname
          >>name                                      ! rr/cname query
          query->answer/cache                         ! rr/cname rrs/NX/f
            {
              { [ dup vector? ] [ clone push-on ] }
              { [ dup NX = ]    [ nip ] }
              { [ dup f = ]     [ nip ] }
            }
          cond
        ]
      }
      { [ t ] [ cache-get* ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: answer-from-cache ( message -- message/f )
  dup message-query                        ! message query
  dup query->answer/cache                  ! message query rrs/NX/f
    {
      { [ dup f = ]  [ 3drop f ] }
      { [ dup NX = ] [ 2drop NAME-ERROR >>rcode ] }
      { [ t ]        [ nip >>answer-section ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: answer-from-server ( message -- message )
  upstream-server ask-server
  cache-message ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: find-answer ( message -- message )
  dup answer-from-cache dup
    [ nip ]
    [ drop answer-from-server ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: loop ( -- )
  socket receive                              ! byte-array addr-spec
  swap                                        ! addr-spec byte-array
  parse-message                               ! addr-spec message
  find-answer                                 ! addr-spec message
  message->ba                                 ! addr-spec byte-array
  swap                                        ! byte-array addr-spec
  socket send
  loop ;