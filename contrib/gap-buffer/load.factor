USING: kernel sequences parser words compiler ;

[ "circular" "gap-buffer" ]

! load
dup [ "contrib/gap-buffer/" swap append ".factor" append run-file ] each

! compile
dup [ words [ try-compile ] each ] each

! test
[ "contrib/gap-buffer/" swap append "-tests.factor" append run-file ] each

