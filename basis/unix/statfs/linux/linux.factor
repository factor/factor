! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators kernel io.files unix.stat
math accessors system unix io.backend layouts vocabs.loader ;
IN: unix.statfs.linux

cell-bits {
    { 32 [ "unix.statfs.linux.32" require ] }
    { 64 [ "unix.statfs.linux.64" require ] }
} case
