
USING: kernel continuations
       combinators
       sequences
       random
       unicode.case
       accessors symbols
       combinators.lib combinators.cleave
       newfx
       dns dns.cache ;

IN: dns.recursive

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: root-dns-servers ( -- servers )
  {
    "192.5.5.241"
    "192.112.36.4"
    "128.63.2.53"
    "192.36.148.17"
    "192.58.128.30"
    "193.0.14.129"
    "199.7.83.42"
    "202.12.27.33"
    "198.41.0.4"
  } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cache-message ( message -- message )
  dup dup rcode>> NAME-ERROR =
    [
      [ question-section>> 1st ]
      [ authority-section>> [ type>> SOA = ] filter random ttl>> ]
      bi
      cache-nx
    ]
    [
        {
          [ answer-section>>     cache-add-rrs ]
          [ authority-section>>  cache-add-rrs ]
          [ additional-section>> cache-add-rrs ]
        }
      cleave
    ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: query->message ( query -- message ) <query-message> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: {name-type-class} ( obj -- seq )
  [ name>> >lower ] [ type>> ] [ class>> ] tri {3} ;

: rr=query? ( rr query -- ? ) [ {name-type-class} ] bi@ = ;

: rr-filter ( rrs query -- rrs ) [ rr=query? ] curry filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: message-query ( message -- query ) question-section>> 1st ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: answer-hits ( message -- rrs )
  [ answer-section>> ] [ message-query ] bi rr-filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: name-hits ( message -- rrs )
  [ answer-section>> ] [ message-query clone A >>type ] bi rr-filter ;

: cname-hits ( message -- rrs )
  [ answer-section>> ] [ message-query clone CNAME >>type ] bi rr-filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: authority-hits ( message -- rrs )
  authority-section>> [ type>> NS = ] filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOLS: ANSWERED NO-NAME-SERVERS UNCLASSIFIED ;

: classify-message ( message -- symbol )
    {
      { [ dup rcode>> NAME-ERROR     = ] [ drop NAME-ERROR      ] }
      { [ dup rcode>> SERVER-FAILURE = ] [ drop SERVER-FAILURE  ] }
      { [ dup answer-hits empty? not   ] [ drop ANSWERED        ] }
      { [ dup cname-hits  empty? not   ] [ drop CNAME           ] }
      { [ dup authority-hits empty?    ] [ drop NO-NAME-SERVERS ] }
      { [ t                            ] [ drop UNCLASSIFIED    ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: name->ip

! : name->ip/f ( name -- ip/f ) [ name->ip ] [ drop f ] recover ;

! : extract-ns-ips ( message -- ips )
!   authority-hits [ rdata>> name->ip/f ] map [ ] filter ;

: extract-ns-ips ( message -- ips )
  authority-hits [ rdata>> name->ip ] map [ ] filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: recursive-query ( query servers -- message )
  dup random                                 ! query servers server
  pick query->message 0 >>rd                 ! query servers server message
  over ask-server                            ! query servers server message
  cache-message                              ! query servers server message
  dup classify-message                       ! query servers server message sym
    {
      { NAME-ERROR      [ -roll 3drop ] }
      { ANSWERED        [ -roll 3drop ] }
      { CNAME           [ -roll 3drop ] }
      { NO-NAME-SERVERS [ -roll 3drop ] }
      {
        SERVER-FAILURE
        [
          -roll                              ! message query servers server
          remove                             ! message query servers
          dup empty?
            [ 2drop ]
            [ rot drop recursive-query ]
          if
        ]
      }
      [                                      ! query servers server message sym
        drop nip nip                         ! query message
        extract-ns-ips                       ! query ips
        recursive-query
      ]
    }
  case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: canonical/cache ( name -- name )
  dup CNAME IN query boa cache-get dup [ nip 1st rdata>> ] [ drop ] if ;

: name->ip/cache ( name -- ip/f )
  canonical/cache
  A IN query boa cache-get dup [ random rdata>> ] [ ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:  name-hits? ( message -- message ? ) dup  name-hits empty? not ;
: cname-hits? ( message -- message ? ) dup cname-hits empty? not ;

: name->ip/server ( name -- ip-or-f )
  A IN query boa root-dns-servers recursive-query ! message
    {
      { [ name-hits? ]  [ name-hits  random rdata>>          ] }
      { [ cname-hits? ] [ cname-hits random rdata>> name->ip ] }
      { [ t           ] [ drop f ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : name->ip ( name -- ip )
!   { [ name->ip/cache ] [ name->ip/server ] [ name-error ] } 1|| ;

: name->ip ( name -- ip )
  dup name->ip/cache dup
    [ nip ]
    [
      drop dup name->ip/server dup
        [ nip ]
        [ drop name-error ]
      if
    ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
