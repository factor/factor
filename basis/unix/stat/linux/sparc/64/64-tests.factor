USING: alien.c-types classes.struct sequences tools.test unix.stat unix.types ;
IN: unix.stat.linux.sparc.64.tests

{ 144 } [ stat heap-size ] unit-test
{ 4 } [ nlink_t heap-size ] unit-test
{ { 0 16 24 28 32 36 40 56 64 72 80 96 112 128 136 } } [
    { "st_dev" "st_ino" "st_mode" "st_nlink" "st_uid" "st_gid"
      "st_rdev" "st_size" "st_blksize" "st_blocks" "st_atimespec"
      "st_mtimespec" "st_ctimespec" "__glibc_reserved4" "__glibc_reserved5" }
    [ stat offset-of ] map
] unit-test
