! Copyright (C) 2007 Adam Wendt.
! See http://factorcode.org/license.txt for BSD license.
!
IN: temporary

USING: kernel mad mad.api alien alien.c-types tools.test
namespaces ;

: setup-buffer ( -- )
  0 <alien> buffer-start set 0 buffer-length set ;

[ t ] [ 0 "mad_stream" malloc-object setup-buffer input MAD_FLOW_STOP = ] unit-test
