! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: arrays byte-arrays checksums checksums.farmhash
io.encodings.binary io.streams.byte-array kernel locals math
math.bitwise sequences sequences.generalizations tools.test ;
IN: checksums.farmhash.tests

! Generated with Google's C++ reference implementation:
! https://github.com/google/farmhash/blob/master/src/farmhash.cc
! Byte i is (i * 131 + length * 17) modulo 256.
! Columns: length, 32, 64, seeded 32, seeded 64, 128, seeded 128.
! Seeds: 123456789, or (987654321 << 64) | 123456789 for 128 bits.
{
    { 0
        0xdc56d17a
        0x9ae16a3b2f90404f
        0x5f87fcc2
        0x402d0934a4b5476
        0x3cb540c392e51e293df09dfc64c09a2b
        0x4ffafc027b3ce56bdacf08065f811ace
    }
    { 1
        0x93c5b9ec
        0xc1e85b3b818699e7
        0x6646f023
        0x32e1e1b8df32126a
        0xdc6516204440fb8c066153938e760396
        0xc7d4db95b94f8569e3ad0c9142bf2b16
    }
    { 2
        0x58c8812
        0xe17ed5dd7ffe44a4
        0xf84f2201
        0xc3b39db6b6bf8ab8
        0xf40ffdc66c0236d531307fbb8f456342
        0x1091ede7039cc765b4b2298ba1e2e13
    }
    { 3
        0xd6359112
        0xcfe615b15acfb931
        0x616f8a14
        0x35309db3a35f2cb2
        0xfc88729e8cea9c33cd5c6a8cef6e9476
        0xe8db34d07b0a4abb39be6d21e741591d
    }
    { 4
        0x8ed6c32b
        0x35a7d617fb205898
        0x12a61f42
        0x2d6f718b09cc82bd
        0xc8f29b2d9fd4d329e422f5219dcdb037
        0x2cf1befd6fc52d120b6f51737d22ec28
    }
    { 5
        0xa4e9bb37
        0x49d1e79de4843803
        0x965ae0b9
        0x205703234646547d
        0x829c53b5b2f7e77e4a83ac75efd3d8ff
        0xf29cb441c0dee64093e82f027c13bd1f
    }
    { 6
        0xcdd1de15
        0xdabb64fa98b0a302
        0xfb5edfbe
        0x8b13c8c2c264b9ff
        0x88391a9ed4f22f6110a9b205fb55e795
        0x1b262eab06c25ca37d02b7dd04b0f5a3
    }
    { 7
        0xd1688d38
        0x98a02fe30ad4d1ac
        0xe343e6dd
        0xe71ce53bbf8af7c8
        0x569b6c65b05bf80c09d50c119363f8bc
        0xe6e30fb716221905d7230590b9191631
    }
    { 8
        0xe2b765e2
        0x36600c68395e109f
        0x8dda3259
        0x76a5adcca2fb2674
        0xee94719fb41566c4a872a71184b27cd3
        0x2d63132606a5294fdb2d69623df4f4d5
    }
    { 9
        0x40e6035f
        0xa7957d2654a23de
        0xf9d74361
        0x236fee06e21b4a50
        0xa3a09ff52259cf35ac1a5fa658ccd1b4
        0x988d956083ff549d7d966b1c0d796846
    }
    { 10
        0xca2b9a3c
        0x923a86868efd6f05
        0x8686f211
        0x4f4b0e85939c4b8b
        0x21692d4c3bad39d5054ec2604ac4b53a
        0xb57fa2577eea6fd0b093a6cd2ec64bd4
    }
    { 11
        0x1b7dcf73
        0xc800bad1aba226b7
        0x212e1990
        0x10426a44e602714e
        0xc234289437a3939def4ef4ee17be2254
        0x1aea4a517ac63a40bae94b217f5fe4e1
    }
    { 12
        0x8e8d9ef6
        0xf5af0d91d295ba05
        0x7c685b9f
        0xbe50c2d99dc36c28
        0x8750ab323ae152701ef32f7adfac9184
        0x7c258ac2364bd267bf44762608847db8
    }
    { 13
        0xbbaaa276
        0x3691770b1b22f767
        0xe4e8eb8d
        0xf83d4bc0dae3b54c
        0xf3c5bb5b2ae6fe06ed553e64fcb6c1e8
        0x124f83505662ed2754a66042b8c26502
    }
    { 14
        0x1406d01f
        0x3e79b650a4f5a827
        0xe8b23034
        0x513a1ad1f65df682
        0x5f6b1bbbf42619be632b2f8bc4174bd7
        0x14b2d07c6147d39a94d8791ccce0de84
    }
    { 15
        0x5af957b3
        0x9a2abeffe78901cc
        0x33f4a87b
        0x7196d904b857c5e5
        0x228ff94df8933b76001366204ed168f8
        0xb3afa4a65ba3d00c9469373a129ab197
    }
    { 16
        0x6aec073b
        0x906313cf923a25c
        0x55fa24f3
        0xb13e5e805cfdc32c
        0xa115eb55b1044499f8b1abe3e6947414
        0x802368f26eb7fbb6f0d10ff4176d6944
    }
    { 17
        0x9b946b19
        0x5cb2fac06876fb7e
        0x12b2cc51
        0x98e7d63996c3e350
        0xaa39eee23f64ccf9079349e8841aa6cc
        0xbd7abf2e802e48c729314ab78f586fa9
    }
    { 18
        0x21615b2d
        0x822e18fa5ef6a2e3
        0xc916ed35
        0x1cb7346f0df65246
        0x6ed2cea4147b6f90cd3bc143ab4589d0
        0xf23e620a9c2780c2fb7ac94f31b320ce
    }
    { 19
        0xd3f96843
        0x1d02eb7646d72ac4
        0x562dd43d
        0x76dae85c0ad0cbfc
        0x87dbfb223ec226653a61741b9dec0245
        0x654d1afdcd7c143529d56bba6a9c6958
    }
    { 20
        0x4a965949
        0x1caec2be9bcfb751
        0x7214eb1f
        0xebe0bbd80dd491ba
        0xecdb1470f791082a49a1d5db35f0ba55
        0xcc384ce0784d14e05478f31e7e7baca7
    }
    { 21
        0x63eb087
        0xeafe29154a5ecd73
        0xcd7dc08e
        0x9765eb43be2c13c8
        0x39d7706abace74e51073a46570147796
        0xf31e6e5b371b0950b9543a6bf5afd1f8
    }
    { 22
        0x7f5e3ed8
        0xef5546789861ff7b
        0xa0e5a3f3
        0x1ac183193b3bc083
        0x3d45b8c6d1f254e37b947177a9828ad8
        0xf42071ed116e5a203e83fb60d25c4330
    }
    { 23
        0x6128990e
        0x21f051375cead921
        0x66594c09
        0x69526202ffa3f158
        0xbe6958881322ac68744da41977f242ef
        0xbd51b6f299b612d7d9e9487204e2263c
    }
    { 24
        0x5fc21476
        0x3d821697cdf966ea
        0xb5376fe3
        0x83dce5c35c85fc3
        0xd94db1b330ad01771e91f58ce39cb1e4
        0xc26f1842af3ec8a1641c311fe9cb4002
    }
    { 25
        0xc4ca54c9
        0xb5231c5a74ebb07c
        0xe323b92
        0x6f83bc84416473de
        0x8437b4568b998c067b66513bdfdff3ba
        0x1be08de11e48c76f048e7b52be46ec7d
    }
    { 26
        0x8b75d11d
        0x8b3659c46f4a2fd0
        0xbe0479dd
        0xea8af5094ac3abae
        0xb6d48b7431144e9a34a05eb6b69509cb
        0xf3b5b51e5ca97406080c89fb5eb034e9
    }
    { 27
        0xeeb89fc3
        0x5be993d65b97c020
        0x31d3c25e
        0x9d4c406064916bf6
        0x57da3f01d845d1161b7b390c74f8f387
        0xcbbee05a1d164c3cfdeaa3000d0d8119
    }
    { 28
        0x35bf3d70
        0x653e10b7d68a6dd7
        0xf00e21e5
        0x7ec6c23bb9b8ddad
        0xc10a0fcca06510569c90d0ba616df60e
        0x3faa3152cb5344f1efc0f971ce88739e
    }
    { 29
        0xc99d285d
        0xd91bec9214808928
        0x74c00ce6
        0x7a2020d7f658dc77
        0x9ef58c375da933d49bca5666d69be4dc
        0xdcd68089bb0c19c9947c7df61d9331a2
    }
    { 30
        0x6cff7c28
        0x47d77ae6b94d0c4
        0x81c01191
        0xac0f246fbfeaa58c
        0xf94b674a57e44734977e1fc9cb0b1a59
        0x64709aadd9794f87d454f31335719dbe
    }
    { 31
        0xf22f632e
        0x571b87c9aed4875
        0xd2212b14
        0xe930905b73e080be
        0x6c9f358e004ae27b07ff1fea14e112e1
        0xfd0636b920d4ed722def202b8bc73d0e
    }
    { 32
        0xede4ccb0
        0x7665d923b0991d67
        0xe4709992
        0x8e287229c1e30e40
        0x849e40d53cc2b9ab6ef0f728d0d7fc27
        0x86d2dd68bdbde342f9c56bb896f7deab
    }
    { 33
        0x493fe69
        0x53869bd7d8ac3e11
        0x5da74c72
        0xc6082d0f5dba05a7
        0x479c5cbd1de333bc221deb99bb1b26dc
        0xa4b74f9417ed53045f257bad2fe879ed
    }
    { 39
        0x8c2519d4
        0x7e4ef8e0a543476b
        0x729aba1d
        0x6831e684fa668e2f
        0x60c002be50ac4ae2b999fe5961df9ae8
        0x9a374a01776fda6e835396992a9661b2
    }
    { 40
        0xdb4f9810
        0x33e4cba82d7dbc1d
        0x77d77139
        0x456997752dd0fc2d
        0xb46b1e49d427ca650395342d992b7698
        0xc6662fe32a65dd96ff36e5810d21a641
    }
    { 41
        0x6cfa3a1b
        0x3a11fb6180ada4aa
        0x51644186
        0xd849ff00c4d3b77a
        0x97fbb4dfd230a977c4e28bc368b21a2d
        0x464b8599aa4a8a08fbad7c1033aae80
    }
    { 63
        0x24d49331
        0x2ce6995e56f7410a
        0x9e6a46cd
        0xc7ccbc9a6a0985fb
        0x45cca3e31b87e18110919d27d244e22f
        0x2653fc6799a994806087815c35c746ed
    }
    { 64
        0xa74fe284
        0xaba3d0c251880c11
        0xe2fc3688
        0x7aea84eebfb7c953
        0xc846e30596e63654bfaa156c96fd6214
        0xdc2b017c85d70919e020f12d5cf24de8
    }
    { 65
        0x308d01f8
        0x76dc8f87845029fa
        0xf27ec2ad
        0xd7880d956d7fa352
        0x2229ef6c4ba3dc24b5ddfb81c2c72598
        0x273ce942b40809927cee94ce74c2ce04
    }
    { 95
        0xaa2df54f
        0x1578d289e69c1869
        0x3a3d310b
        0x773321500534914e
        0xfafad5899c149e992dae32ef6bfae1cc
        0x252ace25f8fac75ce079992e9813b04c
    }
    { 96
        0x864d5c14
        0x26c784c86c44cfb3
        0xf501210d
        0xd0c5b55036d3f58c
        0xf63b371956241d7c16b65a3b059a6862
        0x6f5215fd29a1cda708103700a1627528
    }
    { 97
        0x6d9a3a2
        0x7a17514bf3077e5c
        0xcebb2ad6
        0x576618f3aa0ab541
        0x155f5797f670fc9a418efe36d2f005d8
        0xc3a3c3e12dff5d1f4ab9f490488282b2
    }
    { 127
        0xf9576889
        0xdd46b4e5ad89c7c6
        0x68a4d6ef
        0x9cc80ab8b7c095c
        0x418e07026dd3a11865cb14f7432f4bf7
        0xd7edd4d96edc70422db20468054e862c
    }
    { 128
        0x561df135
        0xd83a03d8a5e02db2
        0x97dc9f70
        0x43159534167eeb76
        0x7743d8192a3acf7032b07514dc02a1e
        0x4249f7b4ed17eb52495ef38806a00ad8
    }
    { 129
        0x18bd5343
        0x25a30787b5a93dd6
        0xf248ead1
        0xefabc43bdc10efa3
        0x30fbde151ad2dda4eae16f9d995ed77c
        0x11f34ac2c50b206a86e9cad7c1d32725
    }
    { 143
        0x9db09364
        0xd443851ebeb1a822
        0x4dae6f22
        0xe365991ab0c88deb
        0xedf4208a91797eedc0835299e8fab00c
        0x7b9559bf2354009a04448fd34cd5b19c
    }
    { 144
        0x4a72dc27
        0x6a7f6926869045fe
        0xa8be28d5
        0x2e3c8636d0055857
        0x364d03c9e65ec170a5b8cc0519999faf
        0x3c6ed35fe6a33adb4a2babeee7bafdbd
    }
    { 145
        0x3b9f2a4d
        0xdd48482053878e9d
        0x463cc9ce
        0xa777606eb3df6b1c
        0x6405b292226e895070e7c5dc18f8c8df
        0xf1c5bf297d85a9f3656937023ac5dc3b
    }
    { 159
        0xd042d53f
        0x87ac9ad4eb123d40
        0x2e827558
        0xb14cf06832b51615
        0x5df112b5ec9be954313914ed9d37dcf6
        0x3fbb744111ccf059db3db805f4a53775
    }
    { 160
        0xe5f4ed10
        0xa25a23545c1f75cc
        0x2b938c71
        0x9f3014680bfea1a0
        0xcd3eeb2e261e2c4608e83a01ecbd575c
        0x753ff1fb43a63bfc3ef6d629d30e0b6e
    }
    { 161
        0xbc02492e
        0x8d55ff69381fec6a
        0x869e0a57
        0x4ad5aff7b12b4509
        0x8dacebb1d4e1f1a4b525be6d33daefce
        0xe12f742ceee351f9c079df65d166a745
    }
    { 255
        0xecec89eb
        0x82317e62e6e03cb6
        0xa9c58640
        0xc83205aedfa5ad40
        0xbc2ad8bdaa61cabe3a30089e480a5f46
        0xd48abc361eed90857ab03e72be499519
    }
    { 256
        0x3b7eea28
        0x7f59e224c7018ee6
        0x99ad7dca
        0x5f376cdb0a4908dc
        0x2750741a64a8df72cdf66b8a46c2c9ab
        0xdde690848f80c0f1b54cbd10e9983370
    }
    { 257
        0xf754f688
        0x5691125146484cec
        0xbf039c56
        0x8bae1dc9005523ab
        0x7105c9029c57990681a1a90dbedbd86
        0xa684e911144cc364858488eac9743ac8
    }
    { 511
        0x4178032c
        0x546cbb346c09e5ae
        0x11409e1c
        0x2e3747f3031ee935
        0x16feed36d9d86b745218ab033ca6d8db
        0x43589a968217e48c514a20117d34d4c3
    }
    { 512
        0x57458464
        0x4b7087e6ca0732fb
        0xf9d4733
        0x16c447db1f4b3a57
        0xc49bd73e92106bd0aac3e1fe80465259
        0xa39e12dc7b1e13ca92377bfc7fe5bc72
    }
    { 513
        0xe9413d93
        0xdc7edb3a64cb311d
        0xdaa3aa01
        0x63e4fc1f4df8c921
        0x1fc6e8e8ba4e0eaf087b767992688edb
        0xd620c42cff199c9c8392d1a3e2240e8c
    }
    { 1023
        0x7d463b75
        0x1580a054fbca0436
        0x2a7b3c38
        0x94073aabb7acbb50
        0x78a51381f50ac80163f7d145b671304d
        0x4158e0b73ce0d9e4c66d03067035c76d
    }
    { 1024
        0x2126965b
        0xd76102c5066b39b4
        0xa77316d9
        0xddefbf3bc0cca087
        0xfdc047a5087accdd21f5dc6672838a16
        0x38b9a1399de2c25368cacc0ce112e791
    }
} [| row |
    row first :> len
    len <iota> [ 131 * len 17 * + 255 bitand ] map >byte-array :> bytes
    row rest 1array [
        bytes f <farmhash-32> checksum-bytes
        bytes f <farmhash-64> checksum-bytes
        bytes 123456789 <farmhash-32> checksum-bytes
        bytes 123456789 <farmhash-64> checksum-bytes
        bytes f <farmhash-128> checksum-bytes
        bytes 987654321 64 shift 123456789 bitor <farmhash-128> checksum-bytes
        6 narray
    ] unit-test
] each

! Sequence representations, streams, and incremental checksum state agree.
{
    [ f <farmhash-32> ]
    [ f <farmhash-64> ]
    [ 123456789 <farmhash-32> ]
    [ 123456789 <farmhash-64> ]
    [ f <farmhash-128> ]
    [ 987654321 64 shift 123456789 bitor <farmhash-128> ]
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
        0xdc56d17a 0x0 0xb2369acfccf83dbffcf7cc0ecf416467
    }
    { 3 0 0
        0xd6359112 0xfb99bc127336cf7d 0xb48cc6c02cf8209278b51ef5d1ccf272
    }
    { 25 0 0
        0x1d50e2e 0x4241ebe0c070e58a 0x4714ef0456f0712f746bc9499f8055b8
    }
    { 65 0 0
        0x7bdf0985 0x2332d1dffd0f1d6b 0xf15f3e897727f1c3e387dbd3111eb411
    }
    { 129 0 0
        0x15b06b02 0x63225dfd7b8346c2 0x7fe470876c2424796b85174d146a2c5d
    }
    { 4096 0 0
        0xe1eceb19 0x26b126d830e065d6 0x9498897754fe319254569f6d5e65d4fc
    }
    { 0 18446744073709551615 340282366920938463463374607431768211455
        0x4e36877a 0x946727a843cc3cea 0xf3b1bec2efe040e9f70b898f3efd49a7
    }
    { 3 18446744073709551615 340282366920938463463374607431768211455
        0xe56e780f 0xd6897c580aa986a0 0x74ec91453834dbda7882db80013be24f
    }
    { 25 18446744073709551615 340282366920938463463374607431768211455
        0x9158f0d 0x784f216443e3c732 0xa8a3ace4a1c4f96107205b3538eafa2c
    }
    { 65 18446744073709551615 340282366920938463463374607431768211455
        0xf4f36c73 0xa1adc22240b0560 0xbd67c079689b32da5035f1aaf69d0d39
    }
    { 129 18446744073709551615 340282366920938463463374607431768211455
        0x404e26ff 0x5ba3faf07e5cb625 0xf422c6b90a6c6387dc05a07570c4e820
    }
    { 4096 18446744073709551615 340282366920938463463374607431768211455
        0x72462a76 0x6c1e77f620df2345 0x4d28381293d14d417473cdf22b94ac2f
    }
} [| row |
    row first :> len
    row second :> seed64
    row third :> seed128
    len <iota> [ 131 * len 17 * + 255 bitand ] map >byte-array :> bytes
    row 3 tail 1array [
        bytes seed64 <farmhash-32> checksum-bytes
        bytes seed64 <farmhash-64> checksum-bytes
        bytes seed128 <farmhash-128> checksum-bytes
        3array
    ] unit-test
] each

! Integer seeds are reduced to their declared width.
{ t } [
    B{ 0 128 255 } -1 <farmhash-32> checksum-bytes
    B{ 0 128 255 } 4294967295 <farmhash-32> checksum-bytes =
    B{ 0 128 255 } 4294967296 <farmhash-32> checksum-bytes
    B{ 0 128 255 } 0 <farmhash-32> checksum-bytes = and
] unit-test

{ t } [
    B{ 0 128 255 } -1 <farmhash-64> checksum-bytes
    B{ 0 128 255 } 18446744073709551615 <farmhash-64> checksum-bytes =
    B{ 0 128 255 } 18446744073709551616 <farmhash-64> checksum-bytes
    B{ 0 128 255 } 0 <farmhash-64> checksum-bytes = and
] unit-test

{ t } [
    B{ 0 128 255 } -1 <farmhash-128> checksum-bytes
    B{ 0 128 255 } 340282366920938463463374607431768211455 <farmhash-128> checksum-bytes =
    B{ 0 128 255 } 340282366920938463463374607431768211456 <farmhash-128> checksum-bytes
    B{ 0 128 255 } 0 <farmhash-128> checksum-bytes = and
] unit-test

