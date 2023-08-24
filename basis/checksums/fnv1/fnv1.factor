! Copyright (C) 2009 Alaric Snell-Pym
! See https://factorcode.org/license.txt for BSD license.
USING: checksums kernel math sequences ;
IN: checksums.fnv1

SINGLETON: fnv1-32
SINGLETON: fnv1a-32
SINGLETON: fnv1-64
SINGLETON: fnv1a-64
SINGLETON: fnv1-128
SINGLETON: fnv1a-128
SINGLETON: fnv1-256
SINGLETON: fnv1a-256
SINGLETON: fnv1-512
SINGLETON: fnv1a-512
SINGLETON: fnv1-1024
SINGLETON: fnv1a-1024

CONSTANT: fnv1-32-prime 16777619
CONSTANT: fnv1-64-prime 1099511628211
CONSTANT: fnv1-128-prime 309485009821345068724781371
CONSTANT: fnv1-256-prime 374144419156711147060143317175368453031918731002211
CONSTANT: fnv1-512-prime 35835915874844867368919076489095108449946327955754392558399825615420669938882575126094039892345713852759
CONSTANT: fnv1-1024-prime 5016456510113118655434598811035278955030765345404790744303017523831112055108147451509157692220295382716162651878526895249385292291816524375083746691371804094271873160484737966720260389217684476157468082573

CONSTANT: fnv1-32-mod 0xffffffff
CONSTANT: fnv1-64-mod 0xffffffffffffffff
CONSTANT: fnv1-128-mod 0xffffffffffffffffffffffffffffffff
CONSTANT: fnv1-256-mod 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
CONSTANT: fnv1-512-mod 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
CONSTANT: fnv1-1024-mod 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

CONSTANT: fnv1-32-basis 0x811c9dc5
CONSTANT: fnv1-64-basis 0xcbf29ce484222325
CONSTANT: fnv1-128-basis 0x6c62272e07bb014262b821756295c58d
CONSTANT: fnv1-256-basis 0xdd268dbcaac550362d98c384c4e576ccc8b1536847b6bbb31023b4c8caee0535
CONSTANT: fnv1-512-basis 0xb86db0b1171f4416dca1e50f309990acac87d059c90000000000000000000d21e948f68a34c192f62ea79bc942dbe7ce182036415f56e34bac982aac4afe9fd9
CONSTANT: fnv1-1024-basis 0x5f7a76758ecc4d32e56d5a591028b74b29fc4223fdada16c3bf34eda3674da9a21d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c6d7eb6e73802734510a555f256cc005ae556bde8cc9c6a93b21aff4b16c71ee90b3

M: fnv1-32 checksum-bytes
    drop
    fnv1-32-basis swap
    [ swap fnv1-32-prime * bitxor fnv1-32-mod bitand ] each ;

M: fnv1a-32 checksum-bytes
    drop
    fnv1-32-basis swap
    [ bitxor fnv1-32-prime * fnv1-32-mod bitand ] each ;


M: fnv1-64 checksum-bytes
    drop
    fnv1-64-basis swap
    [ swap fnv1-64-prime * bitxor fnv1-64-mod bitand ] each ;

M: fnv1a-64 checksum-bytes
    drop
    fnv1-64-basis swap
    [ bitxor fnv1-64-prime * fnv1-64-mod bitand ] each ;


M: fnv1-128 checksum-bytes
    drop
    fnv1-128-basis swap
    [ swap fnv1-128-prime * bitxor fnv1-128-mod bitand ] each ;

M: fnv1a-128 checksum-bytes
    drop
    fnv1-128-basis swap
    [ bitxor fnv1-128-prime * fnv1-128-mod bitand ] each ;


M: fnv1-256 checksum-bytes
    drop
    fnv1-256-basis swap
    [ swap fnv1-256-prime * bitxor fnv1-256-mod bitand ] each ;

M: fnv1a-256 checksum-bytes
    drop
    fnv1-256-basis swap
    [ bitxor fnv1-256-prime * fnv1-256-mod bitand ] each ;


M: fnv1-512 checksum-bytes
    drop
    fnv1-512-basis swap
    [ swap fnv1-512-prime * bitxor fnv1-512-mod bitand ] each ;

M: fnv1a-512 checksum-bytes
    drop
    fnv1-512-basis swap
    [ bitxor fnv1-512-prime * fnv1-512-mod bitand ] each ;


M: fnv1-1024 checksum-bytes
    drop
    fnv1-1024-basis swap
    [ swap fnv1-1024-prime * bitxor fnv1-1024-mod bitand ] each ;

M: fnv1a-1024 checksum-bytes
    drop
    fnv1-1024-basis swap
    [ bitxor fnv1-1024-prime * fnv1-1024-mod bitand ] each ;

INSTANCE: fnv1-32 checksum
INSTANCE: fnv1a-32 checksum
INSTANCE: fnv1-64 checksum
INSTANCE: fnv1a-64 checksum
INSTANCE: fnv1-128 checksum
INSTANCE: fnv1a-128 checksum
INSTANCE: fnv1-256 checksum
INSTANCE: fnv1a-256 checksum
INSTANCE: fnv1-512 checksum
INSTANCE: fnv1a-512 checksum
INSTANCE: fnv1-1024 checksum
INSTANCE: fnv1a-1024 checksum
