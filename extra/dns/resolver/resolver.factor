
USING: kernel accessors namespaces continuations
       io io.sockets io.binary io.timeouts io.encodings.binary
       destructors
       locals strings sequences random prettyprint calendar dns dns.misc ;

IN: dns.resolver

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: send-receive-udp ( BA SERVER -- ba )
   T{ inet4 f f 0 } <datagram>
   T{ duration { second 3 } } over set-timeout
     [| SOCKET | BA SERVER SOCKET send SOCKET receive drop ]
   with-disposal ;

:: send-receive-tcp ( BA SERVER -- ba )
   [let | BA [ BA length 2 >be BA append ] |
     SERVER binary
       [
         T{ duration { second 3 } } input-stream get set-timeout
         BA write flush 2 read be> read
       ]
     with-client                                        ] ;

:: send-receive-server ( BA SERVER -- msg )
   [let | RESULT [ BA SERVER send-receive-udp parse-message ] |
     RESULT tc>> 1 =
       [ BA SERVER send-receive-tcp parse-message ]
       [ RESULT                                   ]
     if                                                 ] ;

: >dns-inet4 ( obj -- inet4 ) dup string? [ 53 <inet4> ] [ ] if ;

:: send-receive-servers ( BA SERVERS -- msg )
   SERVERS empty? [ "send-receive-servers: servers list empty" throw ] when
   [let | SERVER [ SERVERS random >dns-inet4 ] |
     ! if this throws an error ...
     [ BA SERVER send-receive-server ]
     ! we try with the other servers...
     [ drop BA SERVER SERVERS remove send-receive-servers ]
     recover                                            ] ;

:: ask-servers ( MSG SERVERS -- msg )
   MSG message->ba SERVERS send-receive-servers ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fully-qualified ( name -- name ) dup "." tail? [ ] [ "." append ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dns-servers ( -- seq )
  \ dns-servers get
    [ ]
    [ resolv-conf-servers \ dns-servers set dns-servers ]
  if* ;

! : dns-server ( -- server ) dns-servers random ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dns-ip4 ( name -- ips )
  fully-qualified
  [let | MSG [ A IN query boa query->message dns-servers ask-servers ] |
    MSG rcode>> NO-ERROR =
      [ MSG answer-section>> [ type>> A = ] filter [ rdata>> ] map ]
      [ "dns-ip: rcode = " MSG rcode>> unparse append throw        ]
    if ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

