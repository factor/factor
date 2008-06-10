
USING: kernel
       combinators
       vectors
       sequences
       io.sockets
       accessors
       combinators.lib
       newfx
       dns dns.cache dns.misc ;

IN: dns.forwarding

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DNS server - caching, forwarding
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (socket) ( -- vec ) V{ f } ;

: socket ( -- socket ) (socket) 1st ;

: init-socket-on-port ( port -- )
  f swap <inet4> <datagram> 0 (socket) as-mutate ;

: init-socket ( -- ) 53 init-socket-on-port ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (upstream-server) ( -- vec ) V{ f } ;

: upstream-server ( -- ip ) (upstream-server) 1st ;

: set-upstream-server ( ip -- ) 0 (upstream-server) as-mutate ;

: init-upstream-server ( -- )
  upstream-server not
    [ resolv-conf-server set-upstream-server ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rrs? ( obj -- ? ) { [ NX = not ] [ f = not ] } 1&& ;

: query->answer/cache ( query -- rrs/NX/f )
  dup cache-get* dup { [ rrs? ] [ NX = ] } 1||
    [ nip ]
    [
      drop
      dup clone CNAME >>type cache-get* dup { [ NX = ] [ f = ] } 1||
        [ nip ]
        [                                       ! query rrs
          tuck                                  ! rrs query rrs
          1st                                   ! rrs query rr/cname
          rdata>>                               ! rrs query name
          >r clone r> >>name                    ! rrs query
          query->answer/cache                   ! rrs rrs/NX/f
          dup rrs? [ append ] [ nip ] if
        ]
      if
    ]
  if ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start ( -- ) init-socket init-upstream-server loop ;

MAIN: start