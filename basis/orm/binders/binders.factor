! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: constructors ;
IN: orm.binders

TUPLE: column-binder-in column value ;
CONSTRUCTOR: <column-binder-in> column-binder-in ( column value -- obj ) ;

TUPLE: column-binder-out column ;
CONSTRUCTOR: <column-binder-out> column-binder-out ( column -- obj ) ;
