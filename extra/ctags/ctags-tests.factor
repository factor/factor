USING: arrays ctags.private io.backend kernel sequences
tools.test ;

{ t } [
  "if\t" "resource:extra/unix/unix.factor" normalize-path "\t91" 3append
  \ if "resource:extra/unix/unix.factor" 91 ctag =
] unit-test

{ t } [
  "if\t" "resource:extra/unix/unix.factor" normalize-path "\t91" 3append 1array
  { { if { "resource:extra/unix/unix.factor" 91 } } } make-ctags =
] unit-test
