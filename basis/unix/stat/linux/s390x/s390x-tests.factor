USING: alien.c-types classes.struct sequences tools.test unix.stat ;
IN: unix.stat.linux.s390x.tests
{ 144 } [ stat heap-size ] unit-test
{ { 0 8 16 24 28 32 40 48 56 72 88 104 112 } } [
    { "st_dev" "st_ino" "st_nlink" "st_mode" "st_uid" "st_gid"
      "st_rdev" "st_size" "st_atimespec" "st_mtimespec" "st_ctimespec"
      "st_blksize" "st_blocks" } [ stat offset-of ] map
] unit-test
