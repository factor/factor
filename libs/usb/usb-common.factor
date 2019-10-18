! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: usb
USING: kernel alien math namespaces sequences parser ;

: define-packed-field ( offset type name -- offset )
    >r parse-c-decl 
    >r 1 r> 
    >r swapd align r> r> 
    "struct-name" get swap "-" swap 3append
    3dup define-getter 3dup define-setter
    drop c-size rot * + ;

: PACKED-FIELD: ( offset -- offset )
  scan scan define-packed-field ; parsing

