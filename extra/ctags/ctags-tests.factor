USING: kernel ctags tools.test io.backend sequences arrays prettyprint ;
IN: ctags.tests

[ t ] [
  91
  { if  { "resource:extra/unix/unix.factor" 91 } } ctag-lineno =
] unit-test

[ t ] [
  "resource:extra/unix/unix.factor"
  { if  { "resource:extra/unix/unix.factor" 91 } } ctag-path =
] unit-test

[ t ] [
  \ if
  { if  { "resource:extra/unix/unix.factor" 91 } } ctag-word =
] unit-test

[ t ] [
  "if\t" "resource:extra/unix/unix.factor" normalize-path "\t91" 3append
  { if  { "resource:extra/unix/unix.factor" 91 } } ctag =
] unit-test

[ t ] [
  "if\t" "resource:extra/unix/unix.factor" normalize-path "\t91" 3append 1array
  { { if  { "resource:extra/unix/unix.factor" 91 } } } ctag-strings =
] unit-test
