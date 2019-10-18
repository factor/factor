IN: temporary
USING: coroutines kernel sequences prettyprint ;

: test1 ( list -- co )
  [ swap [ over coyield 2drop ] each f swap coyield ] cocreate ; 
  
: test2 ( -- co )
  [ 1 over coyield drop 2 over coyield drop 3 over coyield ] cocreate ;

test2 f swap coresume . f swap coresume . f swap coresume . drop

: test3 ( -- co )
  [ [ 1 2 3 ] [ over coyield drop ] each ] cocreate ;

test3 f swap coresume . f swap coresume . f swap coresume . drop
