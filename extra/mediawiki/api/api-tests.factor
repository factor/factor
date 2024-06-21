USING: assocs kernel mediawiki.api mediawiki.api.private
namespaces tools.test ;
IN: mediawiki.api.tests

{ { { "action" "query" } } }
[ { { "action" "query" } } prepare ] unit-test

{ { { "maxlag" "5" } } }
[ { { "maxlag" 5 } } prepare ] unit-test

{ { { "bot" "true" } } }
[ { { "bot" t } } prepare ] unit-test

{ { { "titles" "A|B" } } }
[ { { "titles" { "A" "B" } } } prepare ] unit-test

{ { { "namespaces" "0|1" } } }
[ { { "namespaces" { 0 1 } } } prepare ] unit-test

"mediawiki.api unit-test" contact set-global
"https://en.wikipedia.org/w/api.php" endpoint set-global

! XXX: don't hit the network for unit tests
! { t } [ { { "meta" "userinfo" } } query "anon" of ] unit-test

! { } [ {
!     { "action" "parse" }
!     { "title" "Factor (programming language)" }
! } api-call drop ] unit-test ! test warnings
