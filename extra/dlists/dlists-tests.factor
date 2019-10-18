IN: temporary
USING: dlists kernel strings tools.test math ;

[ "junk" ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] swap dlist-remove 
] unit-test

[ 5 20 ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] over dlist-remove drop
  [ ] dlist-each
] unit-test

[ "junk" ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ integer? ] over dlist-remove drop
  [ integer? ] over dlist-remove drop
  [ ] dlist-each
] unit-test

[ t ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] swap dlist-contains?
] unit-test

[ t ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ integer? ] swap dlist-contains?
] unit-test

[ f ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] over dlist-remove drop
  [ string? ] swap dlist-contains?
] unit-test
