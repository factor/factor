USING: accessors assocs cache destructors kernel namespaces
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
