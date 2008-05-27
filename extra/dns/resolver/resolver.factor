
USING: kernel vectors sequences combinators random
       accessors newfx dns dns.cache ;

IN: dns.resolver

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Need to cache records even in the case of name error

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

! Ask and cache the records

: ask* ( message -- message ) ask cache-message ;

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
    {
      [ dup NX = ]
      [ 2drop f ]
    }
    {
      [ dup f = ]
      [ 2drop f ]
    }
    {
      [ t ]
      [ nip random rdata>> ]
    }
  }
    cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: canonical/server ( name -- name )
  dup CNAME IN query boa <query-message> ask* answer-section>>
  [ type>> CNAME = ] filter dup empty? not
    [ nip 1st rdata>> ]
    [ drop ]
  if ;

: name->ip/server ( name -- ip )
  canonical/server
  dup A IN query boa <query-message> ask* answer-section>>
  [ type>> A = ] filter dup empty? not
    [ nip random rdata>> ]
    [ 2drop f ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fully-qualified ( name -- name )
    {
      { [ dup empty?         ] [ "." append ] }
      { [ dup peek CHAR: . = ] [            ] }
      { [ t                  ] [ "." append ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: name->ip ( name -- ip )
  fully-qualified
  dup name->ip/cache dup
    [ nip ]
    [ drop name->ip/server ]
  if ;
