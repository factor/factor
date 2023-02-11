! Copyright (C) 2022 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays compression.bzip3 math random sequences
tools.test ;

! Simple compression and decompression
{ B{
    0 0 0 0 0 0 0 12 66 90 51 118 49 0 4 1 0 1 0 0 0 20 0 0 0 12
    0 0 0 177 144 125 228 255 255 255 255 72 101 108 108 111 32
    87 111 114 108 100 33 0 0 0
} } [ B{ 72 101 108 108 111 32 87 111 114 108 100 33 } f compress ] unit-test
{ B{
  72 101 108 108 111 32 87 111 114 108 100 33 
} } [ B{
  0 0 0 0 0 0 0 12 66 90 51 118 49 0 4 1 0 1 0 0 0 20 0 0 0 12 0 0 0 177 144
  125 228 255 255 255 255 72 101 108 108 111 32 87 111 114 108
  100 33 0 0 0
} decompress ] unit-test

! Random byte sequences
40 [| |
  36 [ 256 random ] B{ } replicate-as :> input
  { input } [ input f compress decompress ] unit-test
] times

! Incorrect block sizes must error
[ B{ } 0 compress ] must-fail
[ B{ } 536870912 compress ] must-fail
