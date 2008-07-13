USING: kernel ctags ctags.etags tools.test io.backend sequences arrays prettyprint hashtables assocs ;
IN: ctags.etags.tests


[ H{ { "path" V{ if { "path" 1 } } } } ]
[ H{ } clone dup V{ if { "path" 1 } } "path" rot set-at ] unit-test

[ { "path" V{ if { "path" 1 } } } ]
[ H{ } clone dup { "path" V{ if { "path" 1 } } } "path" rot set-at "path" swap at ] unit-test


[ V{ if { "path" 1 } } ]
[ "path" H{ { "path" V{ if { "path" 1 } } } } at ] unit-test

[ "path" ] [ { if { "path" 1 } } ctag-path ] unit-test

[ V{ } ]
[ "path" H{ } clone etag-at ] unit-test

[ V{ if { "path" 1 } } ]
[ "path" H{ { "path" V{ if { "path" 1 } } } } etag-at ] unit-test

[ { if 28 } ]
[ { if { "resource:core/kernel/kernel.factor" 28 } } etag-pair ] unit-test

[ V{ } ] [ { if { "path" 1 } } H{ } clone etag-vector ] unit-test

[ V{ if { "path" 1 } } ]
[ { if { "path" 1 } }
  { { "path" V{ if { "path" 1 } } } } >hashtable
  etag-vector
] unit-test

[ H{ { "path" V{ { if  1 } } } } ]
[ { if { "path" 1 } } H{ } clone [ etag-add ] keep ] unit-test

[ H{ { "path" V{ { if 1 } } } } ]
[ { { if { "path" 1 } } } etag-hash ] unit-test

[ "if28,704" ]
[ "resource:core/kernel/kernel.factor" file>lines { if 28 } etag ] unit-test

! [ V{ "" "resource:core/kernel/kernel.factor,22" "if28,704" "unless31,755" } ]
! [ { { "resource:core/kernel/kernel.factor"
!      V{ { if 28 }
!         { unless 31 } } } } etag-strings ] unit-test

