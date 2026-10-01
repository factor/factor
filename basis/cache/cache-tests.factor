USING: accessors assocs cache destructors kernel locals math namespaces
tools.test ;
IN: cache.tests

TUPLE: mock-disposable < disposable n ;

: <mock-disposable> ( n -- mock-disposable )
    mock-disposable new-disposable swap >>n ;

M: mock-disposable dispose* drop ;

{ } [ <cache-assoc> "cache" set ] unit-test

{ 0 } [ "cache" get assoc-size ] unit-test

[ "cache" get 2 >>max-age ] must-not-fail

{ } [ 1 <mock-disposable> dup "a" set 2 "cache" get set-at ] unit-test

{ 1 } [ "cache" get assoc-size ] unit-test

{ } [ "cache" get purge-cache ] unit-test

{ } [ 2 <mock-disposable> 3 "cache" get set-at ] unit-test

{ 2 } [ "cache" get assoc-size ] unit-test

{ } [ "cache" get purge-cache ] unit-test

{ 1 } [ "cache" get assoc-size ] unit-test

{ } [ 3 <mock-disposable> dup "b" set 4 "cache" get set-at ] unit-test

{ 2 } [ "cache" get assoc-size ] unit-test

{ } [ "cache" get purge-cache ] unit-test

{ 1 } [ "cache" get assoc-size ] unit-test

{ f } [ 2 "cache" get key? ] unit-test

{ 3 } [ 4 "cache" get at n>> ] unit-test

{ t } [ "a" get disposed>> ] unit-test

{ f } [ "b" get disposed>> ] unit-test

{ } [ "cache" get clear-assoc ] unit-test

{ t } [ "b" get disposed>> ] unit-test

SYMBOL: test-clock

! Drawing additional frames must not evict a recently used native object.
! Reads refresh its idle timer, and expiry still releases the resource.
{ t t f t 0 } [ [let
    0 test-clock set
    <timed-cache-assoc> 100 >>max-age [ test-clock get ] >>clock :> cache
    1 <mock-disposable> :> value
    value "key" cache set-at
    1000 [ cache purge-cache ] times
    "key" cache key?
    99 test-clock set
    "key" cache at value eq?
    100 test-clock set cache purge-cache
    value disposed>>
    199 test-clock set cache purge-cache
    value disposed>>
    cache assoc-size
    cache dispose
] ] unit-test

! A missing key must not create or revive an expired entry.
{ f f t } [ [let
    0 test-clock set
    <timed-cache-assoc> 100 >>max-age [ test-clock get ] >>clock :> cache
    "missing" cache at*
    1 <mock-disposable> :> value
    value "key" cache set-at
    100 test-clock set cache purge-cache
    value disposed>>
    cache dispose
] ] unit-test
