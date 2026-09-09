USING: accessors alien assocs effects io kernel kernel.private namespaces
sequences tools.test vocabs vocabs.loader words ;
{ f } [ "alien-callback-varargs" "alien" lookup-word ] unit-test
{ 2 } [ CALLBACK-STUB special-object length ] unit-test
CALLBACK-STUB special-object "old-callback-template" set
"bootstrap.compat" require
{ t } [ "alien-callback-varargs" "alien" lookup-word word? ] unit-test
{ t } [
    "alien-callback-varargs" "alien" lookup-word "declared-effect" word-prop
    ( return named-parameters abi quot -- alien ) =
] unit-test
"bootstrap.compat.arm64" require
{ 3 } [ CALLBACK-STUB special-object length ] unit-test
{ t } [ CALLBACK-STUB special-object 2 head "old-callback-template" get = ] unit-test
"alien-callback-varargs" "alien" lookup-word dup "compat-word" set
[ def>> "compat-definition" set ] [ 123 "compat-marker" set-word-prop ] bi
"bootstrap.compat" reload
{ t t 123 } [
    "alien-callback-varargs" "alien" lookup-word
    [ "compat-word" get eq? ] [ def>> "compat-definition" get eq? ]
    [ "compat-marker" word-prop ] tri
] unit-test
CALLBACK-STUB special-object "upgraded-template" set
"bootstrap.compat.arm64" reload
{ t } [ CALLBACK-STUB special-object "upgraded-template" get eq? ] unit-test
"Old seed callback interfaces upgraded" print
