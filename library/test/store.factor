IN: scratchpad
USE: arithmetic
USE: combinators
USE: kernel
USE: lists
USE: random
USE: stack
USE: stdio
USE: streams
USE: strings
USE: test
USE: workspace

: bytes>string ( bytes -- string )
    "ASCII" [ [ "byte" ] "java.lang.String" ]
    "java.lang.String" jnew ; word must-compile

: store-num ( x store -- )
    2dup in-store? [
        2drop
    ] [
        dupd store-set
    ] ifte ; word must-compile

: check-num ( x store -- )
    ! Check that it exists first
    2dup in-store? assert
    ! Now check that its value is correct
    [ dup >str swap ] dip store-get bytes>string assert= ;

: random-list ( count -- list )
    [ ] swap [ 0 10000000 random-int swons ] times ; word must-compile

: test-store ( store list -- )
    2dup
    [ over store-num ] each drop
    [ over check-num ] each close-store ;

!"File store test" print
!
![ "rm" "-rf" "file-store-test" ] exec
!"file-store-test" <file-store> test-store

"B-tree store test" print

: delete-btree-test ( -- )
    "btree-store-test" fdelete drop
    "btree-store-test.index" fdelete drop ;

: create-btree-test ( order -- store )
    delete-btree-test
    "btree-store-test" swap f <btree-store> ;

: btree-test ( order list -- )
    [ create-btree-test ] dip test-store ;

: btree-random-test ( order count -- )
    "B-tree test #1: " write 2dup " " swap cat3 print
    random-list [ btree-test ] time ;

4 2000 btree-random-test
5 2000 btree-random-test
6 2000 btree-random-test
7 2000 btree-random-test
8 2000 btree-random-test
48 5000 btree-random-test
127 10000 btree-random-test

: test-add-or-get ( x store -- )
    random-boolean [
        store-num
    ] [
        in-store? drop
    ] ifte ; word must-compile

: test-store-2 ( store list -- )
    [ over test-add-or-get ] each close-store ; word must-compile

: btree-test-2 ( order list -- )
    [ create-btree-test ] dip test-store-2 ;

: btree-random-test-2 ( order count -- )
    "B-tree test #2: " write 2dup " " swap cat3 print
    random-list [ btree-test-2 ] time ;

4 2000 btree-random-test-2
5 2000 btree-random-test-2
6 2000 btree-random-test-2
7 2000 btree-random-test-2
8 2000 btree-random-test-2
48 5000 btree-random-test-2
127 10000 btree-random-test-2
