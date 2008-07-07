USING: kernel ctags tools.test io.backend sequences ;
IN: columns.tests

[ t ] [
  "if\t" "resource:extra/unix/unix.factor" normalize-path "\t91" 3append
  { if  { "resource:extra/unix/unix.factor" 91 } } ctag =
] unit-test