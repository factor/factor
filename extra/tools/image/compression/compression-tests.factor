! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test tools.image.compression ;
IN: tools.image.compression.tests

{ B{ } } [ f (compress) uncompress ] unit-test