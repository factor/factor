USING: kernel ctags ctags.etags tools.test io.backend sequences arrays prettyprint hashtables assocs ;
IN: ctags.etags.tests

! etag-at
[ t ]
[
  V{ }
  "path" H{ } clone etag-at =
] unit-test

[ t ]
[
  V{ if { "path" 1 } }
  "path" H{ { "path" V{ if { "path" 1 } } } } etag-at =
] unit-test

! etag-vector
[ t ]
[
  V{ }
  { if { "path" 1 } } H{ } clone etag-vector =
] unit-test

[ t ]
[
  V{ if { "path" 1 } }
  { if { "path" 1 } }
  { { "path" V{ if { "path" 1 } } } } >hashtable
  etag-vector =
] unit-test

! etag-pair 
[ t ]
[
  { if 28 }
  { if { "resource:core/kernel/kernel.factor" 28 } } etag-pair =
] unit-test

! etag-add
[ t ]
[
  H{ { "path" V{ { if  1 } } } }
  { if { "path" 1 } } H{ } clone [ etag-add ] keep =
] unit-test

! etag-hash
[ t ]
[
  H{ { "path" V{ { if 1 } } } }
  { { if { "path" 1 } } } etag-hash =
] unit-test

! line-bytes (note that for each line implicit \n is counted)
[ t ]
[
  17
  { "1234567890" "12345" } 2 lines>bytes =
] unit-test

! etag
[ t ]
[
  "if2,11"
  { "1234567890" "12345" } { if 2 } etag =
] unit-test
