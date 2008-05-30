
USING: kernel system
       combinators
       vectors sequences assocs
       math math.functions
       prettyprint unicode.case
       accessors
       combinators.cleave
       newfx
       dns ;

IN: dns.cache

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cache ( -- table ) H{ } ;

! key: 'name type class' (as string)
! val: entry

TUPLE: entry time data ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: query->key ( query -- key )
  { [ name>> >lower ] [ type>> unparse ] [ class>> unparse ] } <arr> " " join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: table-get ( query -- result ) query->key cache of ;

: table-check ( query -- ? ) query->key cache key? ;

: table-add ( query value -- ) [ query->key ] [ ] bi* cache at-mutate ;

: table-rem ( query -- ) query->key cache delete-key-of drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: now ( -- seconds ) millis 1000.0 / round >integer ;

: ttl->time ( ttl -- seconds ) now + ;

: time->ttl ( time -- ttl ) now - ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: NX

: cache-nx ( query ttl -- ) ttl->time NX entry boa table-add ;

: nx? ( obj -- ? ) dup entry? [ data>> NX = ] [ drop f ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: query->rr ( query -- rr ) [ name>> ] [ type>> ] [ class>> ] tri f f rr boa ;

: query+entry->rrs ( query entry -- rrs )
  swap                                  ! entry query
  query->rr                             ! entry rr
  over                                  ! entry rr entry
  time>> time->ttl >>ttl                ! entry rr
  swap                                  ! rr entry
  data>> [ >r dup clone r> >>rdata ] map
  nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: expired? ( entry -- ? ) time>> time->ttl 0 <= ;

: cache-get* ( query -- rrs/NX/f )
  dup table-get               ! query result
    {
      { [ dup f = ]      [ 2drop f ]          } ! not in the cache
      { [ dup expired? ] [ drop table-rem f ] } ! here but expired
      { [ dup nx?  ]     [ 2drop NX ]         } ! negative result cached
      { [ t ]            [ query+entry->rrs ] } ! good to go
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ERROR: name-error name ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cache-get ( query -- rrs/f )
  dup cache-get* dup NX = [ drop name>> name-error ] [ nip ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rr->entry ( rr -- entry )
  [ ttl>> ttl->time ] [ rdata>> {1} >vector ] bi entry boa ;

: maybe-pushed-on ( obj seq -- )
  2dup member-of?
    [ 2drop ]
    [ pushed-on ]
  if ;

: add-rr-to-entry ( rr entry -- )
  over ttl>> ttl->time >>time
  [ rdata>> ] [ data>> ] bi* maybe-pushed-on ;

: cache-add ( query rr -- )
  over table-get          ! query rr entry
    {
      { [ dup f = ]      [ drop rr->entry table-add ] }
      { [ dup nx? ]      [ drop over table-rem rr->entry table-add ] }
      { [ dup expired? ] [ drop rr->entry table-add ] }
      { [ t ]            [ rot drop add-rr-to-entry ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rr->query ( rr -- query ) [ name>> ] [ type>> ] [ class>> ] tri query boa ;

: cache-add-rr ( rr -- ) [ rr->query ] [ ] bi cache-add ;

: cache-add-rrs ( rrs -- ) [ cache-add-rr ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! cache-name-error
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: message-soa ( message -- rr/soa )
  authority-section>> [ type>> SOA = ] filter 1st ;

: cache-name-error ( message -- message )
  dup
    [ message-query ] [ message-soa ttl>> ] bi
  cache-nx ;

: cache-message-records ( message -- message )
  dup
    {
      [ answer-section>>     cache-add-rrs ]
      [ authority-section>>  cache-add-rrs ]
      [ additional-section>> cache-add-rrs ]
    }
  cleave ;

: cache-message ( message -- message )
  dup rcode>> NAME-ERROR = [ cache-name-error ] when
  cache-message-records ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

