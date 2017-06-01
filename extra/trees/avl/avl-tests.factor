USING: kernel tools.test trees trees.avl math random sequences
assocs accessors trees.avl.private trees.private arrays ;
IN: trees.avl.tests

{ "key1" 0 "key3" "key2" 0 } [
    T{ avl-node f "key1" f f T{ avl-node f "key2" f T{ avl-node f "key3" } f 1 } 2 }
    [ single-rotate ] go-left
    [ left>> dup key>> swap balance>> ] keep
    [ left>> right>> key>> ] keep
    dup key>> swap balance>>
] unit-test

{ "key1" 0 "key3" "key2" 0 } [
    T{ avl-node f "key1" f f T{ avl-node f "key2" f T{ avl-node f "key3" } f 1 } 2 }
    [ select-rotate ] go-left
    [ left>> dup key>> swap balance>> ] keep
    [ left>> right>> key>> ] keep
    dup key>> swap balance>>
] unit-test

{ "key1" 0 "key3" "key2" 0 } [
    T{ avl-node f "key1" f T{ avl-node f "key2" f f T{ avl-node f "key3" } -1 } f -2 }
    [ single-rotate ] go-right
    [ right>> dup key>> swap balance>> ] keep
    [ right>> left>> key>> ] keep
    dup key>> swap balance>>
] unit-test

{ "key1" 0 "key3" "key2" 0 } [
    T{ avl-node f "key1" f T{ avl-node f "key2" f f T{ avl-node f "key3" } -1 } f -2 }
    [ select-rotate ] go-right
    [ right>> dup key>> swap balance>> ] keep
    [ right>> left>> key>> ] keep
    dup key>> swap balance>>
] unit-test

{ "key1" -1 "key2" 0 "key3" 0 }
[ T{ avl-node f "key1" f f
        T{ avl-node f "key2" f
            T{ avl-node f "key3" f f f 1 } f -1 } 2 }
    [ double-rotate ] go-left
    [ left>> dup key>> swap balance>> ] keep
    [ right>> dup key>> swap balance>> ] keep
    dup key>> swap balance>> ] unit-test
{ "key1" 0 "key2" 0 "key3" 0 }
[ T{ avl-node f "key1" f f
        T{ avl-node f "key2" f
            T{ avl-node f "key3" f f f 0 } f -1 } 2 }
    [ double-rotate ] go-left
    [ left>> dup key>> swap balance>> ] keep
    [ right>> dup key>> swap balance>> ] keep
    dup key>> swap balance>> ] unit-test
{ "key1" 0 "key2" 1 "key3" 0 }
[ T{ avl-node f "key1" f f
        T{ avl-node f "key2" f
            T{ avl-node f "key3" f f f -1 } f -1 } 2 }
    [ double-rotate ] go-left
    [ left>> dup key>> swap balance>> ] keep
    [ right>> dup key>> swap balance>> ] keep
    dup key>> swap balance>> ] unit-test

{ "key1" 1 "key2" 0 "key3" 0 }
[ T{ avl-node f "key1" f
        T{ avl-node f "key2" f f
            T{ avl-node f "key3" f f f -1 } 1 } f -2 }
    [ double-rotate ] go-right
    [ right>> dup key>> swap balance>> ] keep
    [ left>> dup key>> swap balance>> ] keep
    dup key>> swap balance>> ] unit-test
{ "key1" 0 "key2" 0 "key3" 0 }
[ T{ avl-node f "key1" f
        T{ avl-node f "key2" f f
            T{ avl-node f "key3" f f f 0 } 1 } f -2 }
    [ double-rotate ] go-right
    [ right>> dup key>> swap balance>> ] keep
    [ left>> dup key>> swap balance>> ] keep
    dup key>> swap balance>> ] unit-test
{ "key1" 0 "key2" -1 "key3" 0 }
[ T{ avl-node f "key1" f
        T{ avl-node f "key2" f f
            T{ avl-node f "key3" f f f 1 } 1 } f -2 }
    [ double-rotate ] go-right
    [ right>> dup key>> swap balance>> ] keep
    [ left>> dup key>> swap balance>> ] keep
    dup key>> swap balance>> ] unit-test

{ "eight" } [
    <avl> "seven" 7 pick set-at
    "eight" 8 pick set-at "nine" 9 pick set-at
    root>> value>>
] unit-test

{ "another eight" } [ ! ERROR!
    <avl> "seven" 7 pick set-at
    "another eight" 8 pick set-at 8 of
] unit-test

: test-tree ( -- tree )
    AVL{
        { 7 "seven" }
        { 9 "nine" }
        { 4 "four" }
        { 4 "replaced four" }
        { 7 "replaced seven" }
    } clone ;

! test set-at, at, at*
{ t } [ test-tree avl? ] unit-test
{ "seven" } [ <avl> "seven" 7 pick set-at 7 of ] unit-test
{ "seven" t } [ <avl> "seven" 7 pick set-at 7 ?of ] unit-test
{ 8 f } [ <avl> "seven" 7 pick set-at 8 ?of ] unit-test
{ "seven" } [ <avl> "seven" 7 pick set-at 7 of ] unit-test
{ "replacement" } [ <avl> "seven" 7 pick set-at "replacement" 7 pick set-at 7 of ] unit-test
{ "nine" } [ test-tree 9 of ] unit-test
{ "replaced four" } [ test-tree 4 of ] unit-test
{ "replaced seven" } [ test-tree 7 of ] unit-test

! test delete-at--all errors!
{ f } [ test-tree 9 over delete-at 9 of ] unit-test
{ "replaced seven" } [ test-tree 9 over delete-at 7 of ] unit-test
{ "nine" } [ test-tree 7 over delete-at 4 over delete-at 9 of ] unit-test

! test assoc-size
{ 3 } [ test-tree assoc-size ] unit-test
{ 2 } [ test-tree 9 over delete-at assoc-size ] unit-test

! test that converting from a balanced tree doesn't reshape
! the tree
{ t } [ 10 <iota> >array reverse dup zip >avl dup >avl = ] unit-test
