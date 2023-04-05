! File: basis.shortuuid
! Version: 0.1
! DRI: Dave Carlton
! Description: Generates short uuid per http://mrjbq7.github.io/re-factor/2023/03/short-uuid.html
! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math prettyprint sequences strings uuid
uuid.private  ;

IN: basis.shortuuid


CONSTANT: alphabet
"23456789ABCDEFGHJKLMNPQRSTUVWXYZ"

! We encode a numeric input by repeatedly “divmod”, indexing into an alphabet, until exhausted.

: encode-uuid ( uuid -- short-uuid )
    [ dup length 0 > ]
    [ unclip   
       alphabet [ length /mod ] [ nth ] bi
       nip ]
      produce nip >string
    ; 
     
! We decode using a reverse process, looking up the position of each character in the alphabet, re-assembling the numeric input for each character in the shortuuid.

: decode-uuid ( shortuuid -- uuid )
    0 [
        alphabet index [ alphabet length * ] dip +
    ] reduce ;

: short-uuid ( -- shortuuid )
    uuid4 encode-uuid ;
