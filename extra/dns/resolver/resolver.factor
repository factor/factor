
USING: kernel vectors sequences combinators random
       accessors newfx dns dns.cache ;

IN: dns.resolver

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: canonical/cache ( name -- name )
  dup CNAME IN query boa cache-get dup vector? ! name result ?
    [ nip 1st rdata>> ]
    [ drop            ]
  if ;

: name->ip/cache ( name -- ip )
  canonical/cache
  dup A IN query boa cache-get ! name result
    {
      { [ dup NX = ] [ 2drop f ] }
      { [ dup f = ]  [ 2drop f ] }
      { [ t ]        [ nip random rdata>> ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: canonical/server ( name -- name )
  dup CNAME IN query boa query->message ask cache-message answer-section>>
  [ type>> CNAME = ] filter dup empty? not
    [ nip 1st rdata>> ]
    [ drop ]
  if ;

: name->ip/server ( name -- ip )
  canonical/server
  dup A IN query boa query->message ask cache-message answer-section>>
  [ type>> A = ] filter dup empty? not
    [ nip random rdata>> ]
    [ 2drop f ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: name->ip ( name -- ip )
  fully-qualified
  dup name->ip/cache dup
    [ nip ]
    [ drop name->ip/server ]
  if ;
