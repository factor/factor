! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: arrays byte-arrays checksums checksums.cityhash
io.encodings.binary io.streams.byte-array kernel locals math
math.bitwise sequences sequences.generalizations tools.test ;
IN: checksums.cityhash.tests

! Generated with Google's C++ reference implementation:
! https://github.com/google/cityhash/blob/master/src/city.cc
! Byte i is (i * 131 + length * 17) modulo 256.
! Columns: length, 32, 64, seeded 64, 128, seeded 128.
! Seeds: 123456789, or (987654321 << 64) | 123456789 for 128 bits.
{
    { 0
        0xdc56d17a
        0x9ae16a3b2f90404f
        0x402d0934a4b5476
        0x3cb540c392e51e293df09dfc64c09a2b
        0x4ffafc027b3ce56bdacf08065f811ace
    }
    { 1
        0x93c5b9ec
        0xc1e85b3b818699e7
        0x32e1e1b8df32126a
        0xdc6516204440fb8c066153938e760396
        0xc7d4db95b94f8569e3ad0c9142bf2b16
    }
    { 2
        0x58c8812
        0xe17ed5dd7ffe44a4
        0xc3b39db6b6bf8ab8
        0xf40ffdc66c0236d531307fbb8f456342
        0x1091ede7039cc765b4b2298ba1e2e13
    }
    { 3
        0xd6359112
        0xcfe615b15acfb931
        0x35309db3a35f2cb2
        0xfc88729e8cea9c33cd5c6a8cef6e9476
        0xe8db34d07b0a4abb39be6d21e741591d
    }
    { 4
        0x8ed6c32b
        0x35a7d617fb205898
        0x2d6f718b09cc82bd
        0xc8f29b2d9fd4d329e422f5219dcdb037
        0x2cf1befd6fc52d120b6f51737d22ec28
    }
    { 5
        0xa4e9bb37
        0x49d1e79de4843803
        0x205703234646547d
        0x829c53b5b2f7e77e4a83ac75efd3d8ff
        0xf29cb441c0dee64093e82f027c13bd1f
    }
    { 6
        0xcdd1de15
        0xdabb64fa98b0a302
        0x8b13c8c2c264b9ff
        0x88391a9ed4f22f6110a9b205fb55e795
        0x1b262eab06c25ca37d02b7dd04b0f5a3
    }
    { 7
        0xd1688d38
        0x98a02fe30ad4d1ac
        0xe71ce53bbf8af7c8
        0x569b6c65b05bf80c09d50c119363f8bc
        0xe6e30fb716221905d7230590b9191631
    }
    { 8
        0xe2b765e2
        0x36600c68395e109f
        0x76a5adcca2fb2674
        0xee94719fb41566c4a872a71184b27cd3
        0x2d63132606a5294fdb2d69623df4f4d5
    }
    { 9
        0x40e6035f
        0xa7957d2654a23de
        0x236fee06e21b4a50
        0xa3a09ff52259cf35ac1a5fa658ccd1b4
        0x988d956083ff549d7d966b1c0d796846
    }
    { 10
        0xca2b9a3c
        0x923a86868efd6f05
        0x4f4b0e85939c4b8b
        0x21692d4c3bad39d5054ec2604ac4b53a
        0xb57fa2577eea6fd0b093a6cd2ec64bd4
    }
    { 11
        0x1b7dcf73
        0xc800bad1aba226b7
        0x10426a44e602714e
        0xc234289437a3939def4ef4ee17be2254
        0x1aea4a517ac63a40bae94b217f5fe4e1
    }
    { 12
        0x8e8d9ef6
        0xf5af0d91d295ba05
        0xbe50c2d99dc36c28
        0x8750ab323ae152701ef32f7adfac9184
        0x7c258ac2364bd267bf44762608847db8
    }
    { 13
        0x3380c406
        0x3691770b1b22f767
        0xf83d4bc0dae3b54c
        0xf3c5bb5b2ae6fe06ed553e64fcb6c1e8
        0x124f83505662ed2754a66042b8c26502
    }
    { 14
        0xb79de118
        0x3e79b650a4f5a827
        0x513a1ad1f65df682
        0x5f6b1bbbf42619be632b2f8bc4174bd7
        0x14b2d07c6147d39a94d8791ccce0de84
    }
    { 15
        0xb22331bc
        0x9a2abeffe78901cc
        0x7196d904b857c5e5
        0x228ff94df8933b76001366204ed168f8
        0xb3afa4a65ba3d00c9469373a129ab197
    }
    { 16
        0x5b19af60
        0x906313cf923a25c
        0xb13e5e805cfdc32c
        0xa115eb55b1044499f8b1abe3e6947414
        0x802368f26eb7fbb6f0d10ff4176d6944
    }
    { 17
        0x2c463f0a
        0x5cb2fac06876fb7e
        0x98e7d63996c3e350
        0xaa39eee23f64ccf9079349e8841aa6cc
        0xbd7abf2e802e48c729314ab78f586fa9
    }
    { 18
        0x2f820540
        0x822e18fa5ef6a2e3
        0x1cb7346f0df65246
        0x6ed2cea4147b6f90cd3bc143ab4589d0
        0xf23e620a9c2780c2fb7ac94f31b320ce
    }
    { 19
        0x59468908
        0x1d02eb7646d72ac4
        0x76dae85c0ad0cbfc
        0x87dbfb223ec226653a61741b9dec0245
        0x654d1afdcd7c143529d56bba6a9c6958
    }
    { 20
        0x6f8691dd
        0x1caec2be9bcfb751
        0xebe0bbd80dd491ba
        0xecdb1470f791082a49a1d5db35f0ba55
        0xcc384ce0784d14e05478f31e7e7baca7
    }
    { 21
        0x6a319465
        0xeafe29154a5ecd73
        0x9765eb43be2c13c8
        0x39d7706abace74e51073a46570147796
        0xf31e6e5b371b0950b9543a6bf5afd1f8
    }
    { 22
        0x1876dd7d
        0xef5546789861ff7b
        0x1ac183193b3bc083
        0x3d45b8c6d1f254e37b947177a9828ad8
        0xf42071ed116e5a203e83fb60d25c4330
    }
    { 23
        0xf460182f
        0x21f051375cead921
        0x69526202ffa3f158
        0xbe6958881322ac68744da41977f242ef
        0xbd51b6f299b612d7d9e9487204e2263c
    }
    { 24
        0x35bfb0b1
        0x3d821697cdf966ea
        0x83dce5c35c85fc3
        0xd94db1b330ad01771e91f58ce39cb1e4
        0xc26f1842af3ec8a1641c311fe9cb4002
    }
    { 25
        0x47244524
        0xb5231c5a74ebb07c
        0x6f83bc84416473de
        0x8437b4568b998c067b66513bdfdff3ba
        0x1be08de11e48c76f048e7b52be46ec7d
    }
    { 26
        0xbfe53321
        0x8b3659c46f4a2fd0
        0xea8af5094ac3abae
        0xb6d48b7431144e9a34a05eb6b69509cb
        0xf3b5b51e5ca97406080c89fb5eb034e9
    }
    { 27
        0x90e05f66
        0x5be993d65b97c020
        0x9d4c406064916bf6
        0x57da3f01d845d1161b7b390c74f8f387
        0xcbbee05a1d164c3cfdeaa3000d0d8119
    }
    { 28
        0x29ccd655
        0x653e10b7d68a6dd7
        0x7ec6c23bb9b8ddad
        0xc10a0fcca06510569c90d0ba616df60e
        0x3faa3152cb5344f1efc0f971ce88739e
    }
    { 29
        0x9c68feb0
        0xd91bec9214808928
        0x7a2020d7f658dc77
        0x9ef58c375da933d49bca5666d69be4dc
        0xdcd68089bb0c19c9947c7df61d9331a2
    }
    { 30
        0x38945652
        0x47d77ae6b94d0c4
        0xac0f246fbfeaa58c
        0xf94b674a57e44734977e1fc9cb0b1a59
        0x64709aadd9794f87d454f31335719dbe
    }
    { 31
        0xc40b9b08
        0x571b87c9aed4875
        0xe930905b73e080be
        0x6c9f358e004ae27b07ff1fea14e112e1
        0xfd0636b920d4ed722def202b8bc73d0e
    }
    { 32
        0x1d4ffbdc
        0x7665d923b0991d67
        0x8e287229c1e30e40
        0x849e40d53cc2b9ab6ef0f728d0d7fc27
        0x86d2dd68bdbde342f9c56bb896f7deab
    }
    { 33
        0xec299354
        0xc254a862d43c9856
        0x18da02672ce742e9
        0x479c5cbd1de333bc221deb99bb1b26dc
        0xa4b74f9417ed53045f257bad2fe879ed
    }
    { 39
        0xe0b801d6
        0xcbc2169d65b4920a
        0x275298cb73131f1d
        0x60c002be50ac4ae2b999fe5961df9ae8
        0x9a374a01776fda6e835396992a9661b2
    }
    { 40
        0x3b24573
        0xd78c275802bc1c28
        0x42204b4bd9c37e99
        0xb46b1e49d427ca650395342d992b7698
        0xc6662fe32a65dd96ff36e5810d21a641
    }
    { 41
        0xde335ea2
        0xbd2d9e779b82653
        0x50c3aeba5810fa9
        0x97fbb4dfd230a977c4e28bc368b21a2d
        0x464b8599aa4a8a08fbad7c1033aae80
    }
    { 63
        0x6e559b40
        0xa16990db9a12879
        0x570ccaeba4f03aad
        0x45cca3e31b87e18110919d27d244e22f
        0x2653fc6799a994806087815c35c746ed
    }
    { 64
        0x4520a0ed
        0xa451b51f72a342a4
        0x168809876903f5c8
        0xc846e30596e63654bfaa156c96fd6214
        0xdc2b017c85d70919e020f12d5cf24de8
    }
    { 65
        0xfffaa36a
        0xc1cf420d526d7d26
        0xb0c2b2b67094ff47
        0x2229ef6c4ba3dc24b5ddfb81c2c72598
        0x273ce942b40809927cee94ce74c2ce04
    }
    { 95
        0xd9baa547
        0x7c6a6da6af1a87b2
        0x1c9f35681ee8a766
        0xfafad5899c149e992dae32ef6bfae1cc
        0x252ace25f8fac75ce079992e9813b04c
    }
    { 96
        0x210a8050
        0x5acc9adbaf6ebc99
        0x5fdd5153396bcecf
        0xf63b371956241d7c16b65a3b059a6862
        0x6f5215fd29a1cda708103700a1627528
    }
    { 97
        0x76739d23
        0xfc328559ffca3fc8
        0x1241795271b284ca
        0x155f5797f670fc9a418efe36d2f005d8
        0xc3a3c3e12dff5d1f4ab9f490488282b2
    }
    { 127
        0x94f8f8bd
        0x66e5fd0f81d5811e
        0x6267eb3acc50f758
        0x418e07026dd3a11865cb14f7432f4bf7
        0xd7edd4d96edc70422db20468054e862c
    }
    { 128
        0x442d6348
        0x80e4ad817ab868dc
        0x4045f4cf74c5c0a6
        0x7743d8192a3acf7032b07514dc02a1e
        0x4249f7b4ed17eb52495ef38806a00ad8
    }
    { 129
        0xcac1c7ce
        0xc2e795661f6edcd
        0xb7fa72668cb31960
        0x30fbde151ad2dda4eae16f9d995ed77c
        0x11f34ac2c50b206a86e9cad7c1d32725
    }
    { 143
        0x76ee56f2
        0x2bb95d6f5b03ae63
        0xfc32690930e1d7a
        0xedf4208a91797eedc0835299e8fab00c
        0x7b9559bf2354009a04448fd34cd5b19c
    }
    { 144
        0xe2865f33
        0xfdfd43fc614a4196
        0xdc2a762f9fdad7c3
        0x364d03c9e65ec170a5b8cc0519999faf
        0x3c6ed35fe6a33adb4a2babeee7bafdbd
    }
    { 145
        0xcd6ed870
        0x560b5b97a6bdb661
        0xe405c736edd4763
        0x6405b292226e895070e7c5dc18f8c8df
        0xf1c5bf297d85a9f3656937023ac5dc3b
    }
    { 159
        0x29853b87
        0xd8ad4934273d72a7
        0x7d93df410ec49896
        0x5df112b5ec9be954313914ed9d37dcf6
        0x3fbb744111ccf059db3db805f4a53775
    }
    { 160
        0xd3335eb6
        0xf57eb5acf73b6fc7
        0x701a894eb0a82ec
        0xcd3eeb2e261e2c4608e83a01ecbd575c
        0x753ff1fb43a63bfc3ef6d629d30e0b6e
    }
    { 161
        0x904c6e08
        0x55ea8fe252cc2f9d
        0x1ded8cb379025af0
        0x8dacebb1d4e1f1a4b525be6d33daefce
        0xe12f742ceee351f9c079df65d166a745
    }
    { 255
        0xee13fb65
        0x36299176b0435b97
        0xe6873c9c51e83eee
        0xbc2ad8bdaa61cabe3a30089e480a5f46
        0xd48abc361eed90857ab03e72be499519
    }
    { 256
        0x8f619720
        0xa58451d85620fe22
        0xc011fafae63596a1
        0x2750741a64a8df72cdf66b8a46c2c9ab
        0xdde690848f80c0f1b54cbd10e9983370
    }
    { 257
        0xd8e388dd
        0x7e3d6941c0a020b9
        0x3a28bccd47ffad2e
        0x7105c9029c57990681a1a90dbedbd86
        0xa684e911144cc364858488eac9743ac8
    }
    { 511
        0xb6b16d9e
        0x3fed83da3652a898
        0x65cee6911009eaba
        0x16feed36d9d86b745218ab033ca6d8db
        0x43589a968217e48c514a20117d34d4c3
    }
    { 512
        0xed601dce
        0x2ba6d9005cbcbf4f
        0x35cc621c4ec30eec
        0xc49bd73e92106bd0aac3e1fe80465259
        0xa39e12dc7b1e13ca92377bfc7fe5bc72
    }
    { 513
        0x461693db
        0xeca0e4abb25d610f
        0x944165be43619485
        0x1fc6e8e8ba4e0eaf087b767992688edb
        0xd620c42cff199c9c8392d1a3e2240e8c
    }
    { 1023
        0x47102da
        0x1902c4ab52dc8749
        0x6988ce3e7ee74165
        0x78a51381f50ac80163f7d145b671304d
        0x4158e0b73ce0d9e4c66d03067035c76d
    }
    { 1024
        0x68da5f2
        0x29b5d74bdd5a32dd
        0x6e4ac5d550db7f25
        0xfdc047a5087accdd21f5dc6672838a16
        0x38b9a1399de2c25368cacc0ce112e791
    }
} [| row |
    row first :> len
    len <iota> [ 131 * len 17 * + 255 bitand ] map >byte-array :> bytes
    row rest 1array [
        bytes cityhash-32 checksum-bytes
        bytes f <cityhash-64> checksum-bytes
        bytes 123456789 <cityhash-64> checksum-bytes
        bytes f <cityhash-128> checksum-bytes
        bytes 987654321 64 shift 123456789 bitor <cityhash-128> checksum-bytes
        5 narray
    ] unit-test
] each

! Sequence representations, streams, and incremental checksum state agree.
{
    [ cityhash-32 ]
    [ f <cityhash-64> ]
    [ 123456789 <cityhash-64> ]
    [ f <cityhash-128> ]
    [ 987654321 64 shift 123456789 bitor <cityhash-128> ]
} [| constructor |
    { t } [
        constructor call( -- checksum ) :> checksum
        513 <iota> [ 255 bitand ] map >byte-array :> bytes
        bytes checksum checksum-bytes :> expected
        bytes >array checksum checksum-bytes expected =
        bytes binary <byte-reader> checksum checksum-stream expected = and
        checksum [| state |
            state bytes 127 head-slice add-checksum-bytes
            bytes 127 tail-slice add-checksum-bytes get-checksum
        ] with-checksum-state expected = and
    ] unit-test
] each

! Native reference results for zero and maximum-width seeds.
{
    { 0 0 0
        0x0 0xb2369acfccf83dbffcf7cc0ecf416467
    }
    { 3 0 0
        0xfb99bc127336cf7d 0xb48cc6c02cf8209278b51ef5d1ccf272
    }
    { 25 0 0
        0x4241ebe0c070e58a 0x4714ef0456f0712f746bc9499f8055b8
    }
    { 65 0 0
        0x33bb755f92f5cbfd 0xf15f3e897727f1c3e387dbd3111eb411
    }
    { 129 0 0
        0x28946de16a139f08 0x7fe470876c2424796b85174d146a2c5d
    }
    { 4096 0 0
        0x46227c2ccbf9cf37 0x9498897754fe319254569f6d5e65d4fc
    }
    { 0 18446744073709551615 340282366920938463463374607431768211455
        0x946727a843cc3cea 0xf3b1bec2efe040e9f70b898f3efd49a7
    }
    { 3 18446744073709551615 340282366920938463463374607431768211455
        0xd6897c580aa986a0 0x74ec91453834dbda7882db80013be24f
    }
    { 25 18446744073709551615 340282366920938463463374607431768211455
        0x784f216443e3c732 0xa8a3ace4a1c4f96107205b3538eafa2c
    }
    { 65 18446744073709551615 340282366920938463463374607431768211455
        0x66e163c4860e3a1e 0xbd67c079689b32da5035f1aaf69d0d39
    }
    { 129 18446744073709551615 340282366920938463463374607431768211455
        0xc18b712e05533d83 0xf422c6b90a6c6387dc05a07570c4e820
    }
    { 4096 18446744073709551615 340282366920938463463374607431768211455
        0xc5f2d1d73db1cb9d 0x4d28381293d14d417473cdf22b94ac2f
    }
} [| row |
    row first :> len
    row second :> seed64
    row third :> seed128
    len <iota> [ 131 * len 17 * + 255 bitand ] map >byte-array :> bytes
    row 3 tail 1array [
        bytes seed64 <cityhash-64> checksum-bytes
        bytes seed128 <cityhash-128> checksum-bytes
        2array
    ] unit-test
] each

! Integer seeds are reduced to their declared width.
{ t } [
    B{ 0 128 255 } -1 <cityhash-64> checksum-bytes
    B{ 0 128 255 } 18446744073709551615 <cityhash-64> checksum-bytes =
    B{ 0 128 255 } 18446744073709551616 <cityhash-64> checksum-bytes
    B{ 0 128 255 } 0 <cityhash-64> checksum-bytes = and
] unit-test

{ t } [
    B{ 0 128 255 } -1 <cityhash-128> checksum-bytes
    B{ 0 128 255 } 340282366920938463463374607431768211455 <cityhash-128> checksum-bytes =
    B{ 0 128 255 } 340282366920938463463374607431768211456 <cityhash-128> checksum-bytes
    B{ 0 128 255 } 0 <cityhash-128> checksum-bytes = and
] unit-test

