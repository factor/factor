! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math random sequences tools.image
tools.image.compression tools.test ;
IN: tools.image.compression.tests

{ B{ } } [ f (compress) uncompress ] unit-test
{ B{ } } [ B{ } (compress) uncompress ] unit-test
{ t } [ 10 random-bytes dup (compress) uncompress = ] unit-test
{ t } [ 100 random-bytes dup (compress) uncompress = ] unit-test
{ t } [ 1000 random-bytes dup (compress) uncompress = ] unit-test

CONSTANT: incompressable-bytes B{ 252 117 112 64 231 78 148 118 109 209 }
CONSTANT: compressable-bytes B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }

{ t } [ incompressable-bytes dup compress = ] unit-test
{ f } [   compressable-bytes dup compress = ] unit-test
{ t } [ incompressable-bytes [ (compress) ] [ compress ] bi = not ] unit-test
{ f } [   compressable-bytes [ (compress) ] [ compress ] bi = not ] unit-test
{ t } [ incompressable-bytes [ (compress) ] [ compress ] bi [ length ] bi@ > ] unit-test
{ f } [   compressable-bytes [ (compress) ] [ compress ] bi [ length ] bi@ > ] unit-test
