USING: arrays assocs.extras kernel math math.order sequences tools.test ;

{ f } [ f { } deep-at ] unit-test
{ f } [ f { "foo" } deep-at ] unit-test
{ f } [ H{ } { 1 2 3 } deep-at ] unit-test
{ f } [ H{ { "a" H{ { "b" 1 } } } } { "a" "c" } deep-at ] unit-test
{ 1 } [ H{ { "a" H{ { "b" 1 } } } } { "a" "b" } deep-at ] unit-test
{ 4 } [ H{ { 1 H{ { 2 H{ { 3 4 } } } } } } { 1 2 3 } deep-at ] unit-test

{ H{ { 2 1 } { 4 3 } } } [ H{ { 1 2 } { 3 4 } } assoc-invert ] unit-test

{ H{ { "a" V{ 2 5 } } { "b" V{ 3 } } { "c" V{ 10 } } } }
[
    { H{ { "a" 2 } { "b" 3 } } H{ { "a" 5 } { "c" 10 } } }
    [ ] [ assoc-collect ] map-reduce
] unit-test

{ H{ } } [ H{ { 1 2 } } 2 over delete-value-at ] unit-test
{ H{ { 1 2 } } } [ H{ { 1 2 } } 3 over delete-value-at ] unit-test

{
    H{ { 1 3 } { 2 3 } }
} [
    {
        { { 1 2 } 3 }
    } expand-keys-set-at
] unit-test

{
    H{ { 3 4 } }
} [
    {
        { 3 { 1 2 } } { 3 4 }
    } expand-values-set-at
] unit-test

{
    H{ { 1 V{ 3 } } { 2 V{ 3 } } }
} [
    {
        { { 1 2 } 3 }
    } expand-keys-push-at
] unit-test

{
    H{ { 3 V{ 1 2 4 } } }
} [
    {
        { 3 { 1 2 } } { 3 4 }
    } expand-values-push-at
] unit-test

{
    H{ { 1 [ sq ] } { 2 [ sq ] } }
} [
    { { { 1 2 { 1 } { 2 } { 1 1 } } [ sq ] } } flatten-keys
] unit-test

{
    H{ { "1" 1 } { "2" 2 } }
} [
    H{ { "1" 1 } { "2" 2 } { "3" 3 } }
    { "1" "2" "2" }
    rekey-new-assoc
] unit-test

{ f } [
    H{ { "1" 1 } { "2" 2 } { "3" 3 } }
    [ { "1" "2" "2" } rekey-new-assoc ] keep eq?
] unit-test

{
    H{ { "1" 1 } { "2" 2 } }
} [
    H{ { "1" 1 } { "2" 2 } { "3" 3 } }
    { "1" "2" "2" }
    rekey-assoc
] unit-test

{ t } [
    H{ { "1" 1 } { "2" 2 } { "3" 3 } }
    [ { "1" "2" "2" } rekey-assoc ] keep eq?
] unit-test

{ H{ { 1 11 } { 2 22 } { 3 33 } } } [
    H{ { 1 11 } { 2 20 } }
    H{ { 2 22 } { 3 33 } }
    [ max ] assoc-merge
] unit-test

{ H{ { 1 11 } { 2 22 } { 3 33 } } } [
    H{ { 2 22 } { 3 33 } }
    H{ { 1 11 } { 2 20 } }
    [ max ] assoc-merge
] unit-test

{ H{ { 1 11 } { 2 20 } { 3 33 } } } [
    H{ { 1 11 } { 2 20 } }
    H{ { 2 22 } { 3 33 } }
    [ min ] assoc-merge
] unit-test

{ f } [ f f [ min ] assoc-merge ] unit-test

! Ensure non-destructive
{
    H{ { 1 11 } { 2 20 } }
    H{ { 2 22 } { 3 33 } }
    H{ { 1 11 } { 2 20 } { 3 33 } }
} [
    H{ { 1 11 } { 2 20 } }
    H{ { 2 22 } { 3 33 } } 2dup
    [ min ] assoc-merge
] unit-test

! Ensure destructive
{
    H{ { 1 11 } { 2 20 } { 3 33 } }
    H{ { 2 22 } { 3 33 } }
    H{ { 1 11 } { 2 20 } { 3 33 } }
} [
    H{ { 1 11 } { 2 20 } }
    H{ { 2 22 } { 3 33 } } 2dup
    [ min ] assoc-merge!
] unit-test

! assoc-collapse
{ f } [ f [ min ] assoc-collapse ] unit-test

{
    H{ { 1 11 } { 2 20 } }
    H{ { 1 11 } { 2 20 } { 3 30 } { 4 40 } }
} [
    H{ { 1 11 } { 2 20 } } dup
    H{ { 2 22 } { 3 33 } }
    H{ { 3 30 } { 4 40 } } 3array
    [ min ] assoc-collapse
] unit-test

{
    H{ { 2 22 } { 3 30 } { 4 40 } }
} [
    f
    H{ { 2 22 } { 3 33 } }
    H{ { 3 30 } { 4 40 } } 3array
    [ min ] assoc-collapse
] unit-test

{
    H{ { 1 11 } { 2 20 } { 3 30 } { 4 40 } }
} [
    H{ { 1 11 } { 2 20 } } dup
    H{ { 2 22 } { 3 33 } }
    H{ { 3 30 } { 4 40 } } 3array
    [ min ] assoc-collapse!
] unit-test

{
    H{ { 1 11 } { 2 20 } }
    V{ { 1 11 } { 2 20 } { 3 30 } { 4 40 } }
} [
    H{ { 1 11 } { 2 20 } } dup
    H{ { 2 22 } { 3 33 } }
    H{ { 3 30 } { 4 40 } } 3array
    [ min ] V{ } assoc-collapse-as
] unit-test
