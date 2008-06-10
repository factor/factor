
USING: kernel sequences random accessors dns ;

IN: dns.stub

! Stub resolver
! 
! Generally useful, but particularly when running a forwarding,
! caching, nameserver on localhost with multiple Factor instances
! querying it.

: name->ip ( name -- ip )
  A IN query boa
  query->message
  ask
  dup rcode>> NAME-ERROR =
    [ message-query name>> name-error ]
    [ answer-section>> [ type>> A = ] filter random rdata>> ]
  if ;

