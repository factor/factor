IN: scratchpad
USE: arithmetic
USE: kernel
USE: stack
USE: stdio
USE: streams
USE: test
USE: workspace

! Now do a little benchmark.

: store-benchmark ( count store -- )
    over [ over dupd store-set ] times*
    over [ over store-get drop ] times*
    2drop ; word must-compile

"Time to read/write a million entries with B-tree/127: " write

"btree-store-test" fdelete drop
"btree-store-test.index" fdelete drop

1000000 "btree-store-test" 127 f <btree-store>

[ store-benchmark ] time

!"Time to read/write a million entries with file store: " write
!
![ "rm" "-rf" "file-store-test" ] exec
!1000000 "file-store-test" <file-store>
!
![ store-benchmark ] time
