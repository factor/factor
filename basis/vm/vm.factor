! Copyright (C) 2009 Phil Dawes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.structs alien.syntax ;
IN: vm

C-STRUCT: vm { "context*" "stack_chain" } ;

: vm-field-offset ( field -- offset ) "vm" offset-of ;