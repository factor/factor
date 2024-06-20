USING: arrays assocs assocs.extras kernel math math.order
sequences tools.test ;

{
    H{ { 1 V{ 10 } } { 2 V{ 10 } } { 3 V{ 10 } } { 4 V{ 10 } } { 5 V{ 10 } } }
} [
    H{ } clone 10 { 1 2 3 4 5 } pick push-at-each
] unit-test

{ f } [ f { } deep-of ] unit-test
{ f } [ f { "foo" } deep-of ] unit-test
{ f } [ H{ } { 1 2 3 } deep-of ] unit-test
{ f } [ H{ { "a" H{ { "b" 1 } } } } { "a" "c" } deep-of ] unit-test
{ 1 } [ H{ { "a" H{ { "b" 1 } } } } { "a" "b" } deep-of ] unit-test
{ 4 } [ H{ { 1 H{ { 2 H{ { 3 4 } } } } } } { 1 2 3 } deep-of ] unit-test

{ H{ { 1 H{ { 2 H{ { 3 44 } } } } } } } [
    H{ { 1 H{ { 2 H{ { 3 4 } } } } } } dup { 1 2 3 } [ 40 + ] deep-change-of
] unit-test

{ H{ { 1 H{ { 2 H{ { 3 40 } } } } } } } [
    H{ { 1 H{ { 2 H{ { 3 4 } } } } } } dup { 1 2 3 } 40 deep-set-of
] unit-test

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


{
    H{
        { 41 V{ 401 } }
        { 10 V{ 100 } }
        { 20 V{ 200 } }
        { 30 V{ 300 } }
    }
} [
    { { 10 100 } { 20 200 } { 30 300 } { 41 401 } }
    [ ] collect-assoc-by
] unit-test

{
    H{ { t V{ 100 200 300 } } { f V{ 401 } } }
} [
    { { 10 100 } { 20 200 } { 30 300 } { 41 401 } }
    [ [ even? ] dip ] collect-assoc-by
] unit-test

{
    H{
        { t V{ { 10 100 } { 20 200 } { 30 300 } } }
        { f V{ { 41 401 } } }
    }
} [
    { { 10 100 } { 20 200 } { 30 300 } { 41 401 } }
    [ [ drop even? ] [ 2array ] 2bi ] collect-assoc-by
] unit-test


{
    H{ { t V{ 10 21 } } { f V{ 30 41 } } }
} [
    { { 10 100 } { 21 200 } { 30 301 } { 41 401 } }
    [ nip even? ] collect-key-by
 ] unit-test

{
    H{ { t V{ 10 30 } } { f V{ 21 41 } } }
} [
    { { 10 100 } { 21 200 } { 30 301 } { 41 401 } }
    [ drop even? ] collect-key-by
 ] unit-test


{
    H{ { t V{ 100 200 } } { f V{ 301 401 } } }
} [
    { { 10 100 } { 21 200 } { 30 301 } { 41 401 } }
    [ nip even? ] collect-value-by
 ] unit-test

{
    H{ { t V{ 100 301 } } { f V{ 200 401 } } }
} [
    { { 10 100 } { 21 200 } { 30 301 } { 41 401 } }
    [ drop even? ] collect-value-by
 ] unit-test

{
    H{
        { 1 V{ 10 20 30 40 50 60 } }
        { 2 V{ 10 20 30 40 50 60 } }
        { 3 V{ 10 20 30 40 50 60 } }
        { 4 V{ 10 20 30 40 50 60 } }
        { 5 V{ 10 20 30 40 50 60 } }
    }
} [
    { 10 20 30 } [ drop { 1 2 3 4 5 } ] collect-by-multi
    { 40 50 60 } [ drop { 1 2 3 4 5 } ] collect-by-multi!
] unit-test



{
    H{
        { 20 V{ 20 } }
        { 21 V{ 20 } }
        { 41 V{ 41 } }
        { 10 V{ 10 } }
        { 11 V{ 10 } }
        { 42 V{ 41 } }
        { 30 V{ 30 } }
        { 31 V{ 30 } }
    }
} [
    { { 10 100 } { 20 200 } { 30 300 } { 41 401 } }
    [ drop dup 1 + 2array ] collect-key-by-multi
] unit-test


{
    H{
        { 401 V{ 401 } }
        { 402 V{ 401 } }
        { 100 V{ 100 } }
        { 101 V{ 100 } }
        { 200 V{ 200 } }
        { 201 V{ 200 } }
        { 300 V{ 300 } }
        { 301 V{ 300 } }
    }
} [
    { { 10 100 } { 20 200 } { 30 300 } { 41 401 } }
    [ nip dup 1 + 2array ] collect-value-by-multi
] unit-test


{
    H{
        { 20 V{ 200 } }
        { 21 V{ 200 } }
        { 41 V{ 401 } }
        { 10 V{ 100 } }
        { 11 V{ 100 } }
        { 42 V{ 401 } }
        { 30 V{ 300 } }
        { 31 V{ 300 } }
    }
} [
    { { 10 100 } { 20 200 } { 30 300 } { 41 401 } }
    [ [ dup 1 + 2array ] dip ] collect-assoc-by-multi
] unit-test

{ H{ { 1 2 } { 3 4 } } } [
    H{ { 1 2 } { 3 4 } { 5 6 } }
    { 1 3 } intersect-keys
] unit-test

{ { { 1 2 } { 3 4 } } } [
    H{ { 1 2 } { 3 4 } { 5 6 } }
    { 1 3 } { } intersect-keys-as
] unit-test


{ H{ { 1 100 } } } [
    H{ } clone 1 100 set-of
] unit-test

{ H{ { 1 V{ 100 200 } } } } [
    H{ } clone 1 100 push-of 1 200 push-of
] unit-test

{ H{ { 123 556 } } } [
    H{ { 123 456 } } 123 [ 100 + ] change-of
] unit-test

{ H{ { 123 556 } } } [
    H{ { 123 456 } } 123 [ 100 + ] ?change-of
] unit-test

{ H{ { 123 456 } } } [
    H{ { 123 456 } } 1234 [ 100 + ] ?change-of
] unit-test

{ H{ { 10 2 } } } [
    H{ { 10 1 } } 10 inc-of
] unit-test

{ H{ { 10 1001 } } } [
    H{ { 10 1 } } 10 1000 of+
] unit-test

{ H{ { 1 10 } } } [
    H{ { 1 2 } } 1 10 set-of
] unit-test

{ H{ { 1 100 } } f } [
    H{ { 1 100 } } 1 100 maybe-set-of
] unit-test

{ H{ { 1 100 } { 2 100 } } t } [
    H{ { 1 100 } } 2 100 maybe-set-of
] unit-test

{ H{ { 1 100 } } t } [
    H{ { 1 100 } } 1 101 maybe-set-of
] unit-test
