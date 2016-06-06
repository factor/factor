! See http://factorcode.org/license.txt for BSD license.
USING: tools.test exercism.testing exercism.testing.private ;
FROM: namespaces => get set ;
IN: exercism.testing.tests


{
    "exercises/hello-world/hello-world-tests.factor"
    "exercises/hello-world/hello-world-example.factor"
} [
    T{ dev-env } project-env set
    "hello-world" exercise>filenames
] unit-test

{
    "exercises/leap/leap-tests.factor"
    "exercises/leap/leap-example.factor"
} [
    T{ dev-env } project-env set
    "leap" exercise>filenames
] unit-test

{
    "hello-world/hello-world-tests.factor"
    "hello-world/hello-world.factor"
} [
    T{ user-env } project-env set
    "hello-world" exercise>filenames
] unit-test

{
    "leap/leap-tests.factor"
    "leap/leap.factor"
} [
    T{ user-env } project-env set
    "leap" exercise>filenames
] unit-test

T{ dev-env } project-env set
{ t } [ { } { "hello-world" } config-exclusive? ] unit-test
{ t } [ { "hello-world" } { } config-exclusive? ] unit-test
{ t } [ { } { }               config-exclusive? ] unit-test
{ f } [ { "hello-world" }
          { "hello-world" }
          config-exclusive? ] unit-test

{ t } [ { } { } { } config-matches-fs? ] unit-test
{ t } [
          { "hello-world" }
          { "hello-world" }
          { }
        config-matches-fs? ] unit-test
{ t } [
          { "hello-world" }
          { "hello-world" }
          { "blah" }
        config-matches-fs? ] unit-test
{ f } [
          { "hello-world" }
          { "blah" }
          { "blah" }
        config-matches-fs? ] unit-test
{ f } [
          { "blah" }
          { "hello-world" }
          { "blah" }
        config-matches-fs? ] unit-test
