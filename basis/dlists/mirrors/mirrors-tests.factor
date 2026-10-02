USING: accessors arrays assocs deques dlists dlists.mirrors inspector io.streams.string kernel locals mirrors
sequences tools.test ;
IN: dlists.mirrors.tests

{ { { 0 "first" } { 1 f } { 2 "last" } } } [
    { "first" f "last" } >dlist make-mirror >alist
] unit-test

{ { { f t } { f f } { f f } { f f } { f f } } } [
    [let
        { f } >dlist make-mirror :> mirror
        { 0 1 -1 "front" 1/2 } [ mirror at* 2array ] map
    ]
] unit-test

{ { 0 1 2 } { "a" "b" "c" } 3 } [
    { "a" "b" "c" } >dlist make-mirror
    [ keys >array ] [ values >array ] [ assoc-size ] tri
] unit-test

! Editing changes the original nodes rather than a detached snapshot.
{ { "a" "changed" "c" } } [
    { "a" "b" "c" } >dlist [
        make-mirror "changed" 1 rot set-at
    ] keep dlist>sequence >array
] unit-test

[ "new" 3 { "a" } >dlist make-mirror set-at ] [ no-such-slot? ] must-fail-with

! Mirrors follow list mutations, including shifted indices after deletion.
{ { "b" "d" } { { 0 "b" } { 1 "d" } } } [
    [let
        { "a" "b" "c" } >dlist :> list
        list make-mirror :> mirror
        0 mirror delete-at
        1 mirror delete-at
        99 mirror delete-at
        "d" list push-back
        list dlist>sequence >array mirror >alist
    ]
] unit-test

{ t { } 0 } [
    { "a" "b" } >dlist [ make-mirror dup clear-assoc ] keep
    deque-empty? swap [ >alist ] [ assoc-size ] bi
] unit-test

! Positional entry keys must not be formatted as tuple slot names.
{ t } [
    [ { "a" "b" } >dlist describe ] with-string-writer
    "0" swap subseq?
] unit-test
