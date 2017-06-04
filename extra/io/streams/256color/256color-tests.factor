! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: colors.constants io.streams.256color
io.streams.256color.private tools.test ;

{ 16 } [ color: black color>256color ] unit-test
{ 196 } [ color: red color>256color ] unit-test
{ 46 } [ color: green color>256color ] unit-test
{ 21 } [ color: blue color>256color ] unit-test
{ 231 } [ color: white color>256color ] unit-test
