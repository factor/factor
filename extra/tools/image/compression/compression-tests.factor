! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel literals math random sequences
tools.image tools.image.compression tools.test ;
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

CONSTANT: dummy-image.1 $[ "vocab:tools/image/dummy.64.image" load-factor-image ]
CONSTANT: dummy-image.2 $[ "vocab:tools/image/dummy.64.image" load-factor-image ] ! we currently lack a GENERIC: deep-clone ( obj -- deep-cloned )

{ t } [ dummy-image.1 compressable-image? ] unit-test
{ f } [ dummy-image.1 dummy-image.2 eq? ] unit-test
{ t } [ dummy-image.1 dummy-image.2 =   ] unit-test
{ t } [ dummy-image.1 dummy-image.2 uncompress-image = ] unit-test
{ f } [ dummy-image.1 dummy-image.2   compress-image = ] unit-test
{ t } [ dummy-image.1 dummy-image.2 compress-image uncompress-image = ] unit-test

{ f } [ dummy-image.1 [ header>> 1 >>data-size drop ] keep compressable-image? ] unit-test
      [ dummy-image.1 [ header>> 1 >>data-size drop ] keep compress-image ] must-fail
      [ dummy-image.1 [ header>> 1 >>data-size drop ] keep compress-image ] [ uncompressable-image? ] must-fail-with
