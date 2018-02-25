! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences sorting tools.coverage
tools.coverage.private tools.coverage.testvocab
tools.coverage.testvocab.child tools.coverage.testvocab.private
tools.test vocabs.loader ;

{ "foo.private" } [ "foo" private-vocab-name ] unit-test
{ "foo.private" } [ "foo.private" private-vocab-name ] unit-test

{
  { halftested mconcat testcond testfry testif testifprivate testmacro untested
}
} [ "tools.coverage.testvocab" [ ] map-words natural-sort ] unit-test

{ t } [
  "tools.coverage.testvocab"
    [ V{ } clone [ [ push ] curry each-word ] keep >array ]
    [ [ ] map-words ] bi =
] unit-test

{
  { testifprivate }
} [ "tools.coverage.testvocab.private" [ ] map-words natural-sort ] unit-test

{ t } [
  "tools.coverage.testvocab.private"
    [ V{ } clone [ [ push ] curry each-word ] keep >array ]
    [ [ ] map-words ] bi =
] unit-test

{ 3 } [ \ testif count-callables ] unit-test

! Need to reload to flush macro cache
! and have correct coverage statistics
{
  {
    { halftested { [ ] } }
    { mconcat { } }
    { testcond { } }
    { testfry { } }
    { testif { } }
    { testifprivate { } }
    { testmacro { } }
    { untested { [ ] } }
  }
} [ "tools.coverage.testvocab" [ reload ] [ test-coverage natural-sort ] bi ] unit-test

{ 0.75 } [ "tools.coverage.testvocab.child" [ reload ] [ %coverage ] bi ] unit-test

{
  {
    {
        "tools.coverage.testvocab"
        {
            { halftested { [ ] } }
            { mconcat { } }
            { testcond { } }
            { testfry { } }
            { testif { } }
            { testifprivate { } }
            { testmacro { } }
            { untested { [ ] } }
        }
    }
    {
        "tools.coverage.testvocab.child"
        { { child-halftested { [ ] } } { foo { } } }
    }
}
} [
  "tools.coverage.testvocab.child" reload
  "tools.coverage.testvocab" [ reload ] [ test-coverage-recursively ] bi natural-sort
  [ first2 natural-sort 2array ] map
] unit-test
