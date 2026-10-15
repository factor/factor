USING: alien.c-types classes.struct sequences tools.test unix.stat unix.types ;
IN: unix.stat.linux.sparc.32.tests

{ 104 } [ stat heap-size ] unit-test
{ 4 } [ nlink_t heap-size ] unit-test
{ { 0 8 16 20 24 28 32 48 56 64 72 80 88 96 100 } } [
    { "st_dev" "st_ino" "st_mode" "st_nlink" "st_uid" "st_gid"
      "st_rdev" "st_size" "st_blksize" "st_blocks" "st_atimespec"
      "st_mtimespec" "st_ctimespec" "__glibc_reserved4" "__glibc_reserved5" }
    [ stat offset-of ] map
] unit-test
