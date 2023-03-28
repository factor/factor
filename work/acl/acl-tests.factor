! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors acl alien classes classes.tuple file.security kernel
sequences tools.continuations tools.test unix.ffi words ;

IN: acl.tests

{ t } [ <ACL> [
    break
    [ class-of ] keep swap
    ACL =
    [ tuple-slots
      0 over remove-nth
      0 over remove-nth
      2nip
      [ first class-of ] keep
      second class-of
      alien = swap
      alien = and
      [ t ]
      [ f ]
      if
    ]
    [ drop f ] if
] ] unit-test

