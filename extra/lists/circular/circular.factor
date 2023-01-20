! Copyright (C) 2022 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: circular kernel lists sequences ;
IN: lists.circular

M: circular car 0 swap nth ;

M: circular cdr [ rotate-circular ] keep ;
