! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: colors io.streams.256color
io.streams.256color.private tools.test ;

{ 16 } [ COLOR: black color>256color ] unit-test
{ 196 } [ COLOR: red color>256color ] unit-test
{ 28 } [ COLOR: green color>256color ] unit-test
{ 21 } [ COLOR: blue color>256color ] unit-test
{ 231 } [ COLOR: white color>256color ] unit-test
