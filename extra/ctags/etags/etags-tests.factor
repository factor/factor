USING: ctags.etags.private kernel tools.test ;
IN: ctags.etags.tests

! etag-hash
{ t }
[
  H{ { "path" V{ { if 1 } } } }
  { { if { "path" 1 } } } etag-hash =
] unit-test

! etag
{ t }
[
  "if2,11"
  { 0 11 } { if 2 } etag =
] unit-test
