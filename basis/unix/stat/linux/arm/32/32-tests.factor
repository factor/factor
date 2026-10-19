USING: alien.c-types classes.struct sequences tools.test unix.stat ;
IN: unix.stat.linux.arm.32.tests

{ 104 } [ stat heap-size ] unit-test
{ { 0 8 12 16 20 24 28 32 40 48 56 64 72 80 88 96 } } [
    { "st_dev" "__pad1" "__st_ino" "st_mode" "st_nlink" "st_uid"
      "st_gid" "st_rdev" "__pad2" "st_size" "st_blksize" "st_blocks"
      "st_atimespec" "st_mtimespec" "st_ctimespec" "st_ino" }
    [ stat offset-of ] map
] unit-test
