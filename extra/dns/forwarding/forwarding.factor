
USING: kernel sequences combinators accessors locals random
       combinators.short-circuit
       io.sockets
       dns dns.util dns.cache.rr dns.cache.nx
       dns.resolver ;

IN: dns.forwarding

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: query->rrs ( QUERY -- rrs/f )
   [let | RRS [ QUERY cache-get ] |
     RRS
       [ RRS ]
       [
         [let | NAME  [ QUERY name>>  ]
                TYPE  [ QUERY type>>  ]
                CLASS [ QUERY class>> ] |
               
           [let | RRS/CNAME [ T{ query f NAME CNAME CLASS } cache-get ] |

             RRS/CNAME f =
               [ f ]
               [
                 [let | RR/CNAME [ RRS/CNAME first ] |
            
                   [let | REAL-NAME [ RR/CNAME rdata>> ] |
              
                     [let | RRS [
                                  T{ query f REAL-NAME TYPE CLASS } query->rrs
                                ] |

                       RRS
                         [ RRS/CNAME RRS append ]
                         [ f ]
                       if
                     ] ] ]
               ]
             if
           ] ]
       ]
     if
   ] ;

:: answer-from-cache ( MSG -- msg/f )
   [let | QUERY [ MSG message-query ] |

     [let | NX  [ QUERY name>> non-existent-name? ]
            RRS [ QUERY query->rrs                ] |

       {
         { [ NX  ] [ MSG NAME-ERROR >>rcode          ] }
         { [ RRS ] [ MSG RRS        >>answer-section ] }
         { [ t   ] [ f                               ] }
       }
       cond
     ]
   ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: message-soa ( message -- rr/soa )
  authority-section>> [ type>> SOA = ] filter first ;

! :: cache-message ( MSG -- msg )
!    MSG rcode>> NAME-ERROR =
!      [
!        [let | NAME [ MSG message-query name>> ]
!               TTL  [ MSG message-soa   ttl>>  ] |
!          NAME TTL cache-non-existent-name
!        ]
!      ]
!    when
!    MSG answer-section>>     [ cache-add ] each
!    MSG authority-section>>  [ cache-add ] each
!    MSG additional-section>> [ cache-add ] each
!    MSG ;

:: cache-message ( MSG -- msg )
   MSG rcode>> NAME-ERROR =
     [
       [let | RR/SOA [ MSG
                         authority-section>>
                         [ type>> SOA = ] filter
                       dup empty? [ drop f ] [ first ] if ] |
         RR/SOA
           [
             [let | NAME [ MSG message-query name>> ]
                    TTL  [ MSG message-soa   ttl>>  ] |
               NAME TTL cache-non-existent-name
             ]
           ]
         when
       ]
     ]
   when
   MSG answer-section>>     [ cache-add ] each
   MSG authority-section>>  [ cache-add ] each
   MSG additional-section>> [ cache-add ] each
   MSG ;

! : answer-from-server ( msg servers -- msg ) random ask-server cache-message ;

: answer-from-server ( msg servers -- msg ) ask-servers cache-message ;

:: find-answer ( MSG SERVERS -- msg )
   { [ MSG answer-from-cache ] [ MSG SERVERS answer-from-server ] } 0|| ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-server ( ADDR-SPEC SERVERS -- )

  [let | SOCKET [ ADDR-SPEC <datagram> ] |

    [
      SOCKET receive-packet
        [ parse-message SERVERS find-answer message->ba ]
      change-data
      respond
    ]
    forever

  ] ;
