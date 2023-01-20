! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct kernel math ;
FROM: alien.c-types => float ;
IN: cuda.types

STRUCT: char1
    { x char } ;
STRUCT: char2
    { x char }
    { y char } ;
STRUCT: char3
    { x char }
    { y char }
    { z char } ;
STRUCT: char4
    { x char }
    { y char }
    { z char }
    { w char } ;

STRUCT: uchar1
    { x uchar } ;
STRUCT: uchar2
    { x uchar }
    { y uchar } ;
STRUCT: uchar3
    { x uchar }
    { y uchar }
    { z uchar } ;
STRUCT: uchar4
    { x uchar }
    { y uchar }
    { z uchar }
    { w uchar } ;

STRUCT: short1
    { x short } ;
STRUCT: short2
    { x short }
    { y short } ;
STRUCT: short3
    { x short }
    { y short }
    { z short } ;
STRUCT: short4
    { x short }
    { y short }
    { z short }
    { w short } ;

STRUCT: ushort1
    { x ushort } ;
STRUCT: ushort2
    { x ushort }
    { y ushort } ;
STRUCT: ushort3
    { x ushort }
    { y ushort }
    { z ushort } ;
STRUCT: ushort4
    { x ushort }
    { y ushort }
    { z ushort }
    { w ushort } ;

STRUCT: int1
    { x int } ;
STRUCT: int2
    { x int }
    { y int } ;
STRUCT: int3
    { x int }
    { y int }
    { z int } ;
STRUCT: int4
    { x int }
    { y int }
    { z int }
    { w int } ;

STRUCT: uint1
    { x uint } ;
STRUCT: uint2
    { x uint }
    { y uint } ;
STRUCT: uint3
    { x uint }
    { y uint }
    { z uint } ;
STRUCT: uint4
    { x uint }
    { y uint }
    { z uint }
    { w uint } ;

STRUCT: long1
    { x long } ;
STRUCT: long2
    { x long }
    { y long } ;
STRUCT: long3
    { x long }
    { y long }
    { z long } ;
STRUCT: long4
    { x long }
    { y long }
    { z long }
    { w long } ;

STRUCT: ulong1
    { x ulong } ;
STRUCT: ulong2
    { x ulong }
    { y ulong } ;
STRUCT: ulong3
    { x ulong }
    { y ulong }
    { z ulong } ;
STRUCT: ulong4
    { x ulong }
    { y ulong }
    { z ulong }
    { w ulong } ;

STRUCT: longlong1
    { x longlong } ;
STRUCT: longlong2
    { x longlong }
    { y longlong } ;
STRUCT: longlong3
    { x longlong }
    { y longlong }
    { z longlong } ;
STRUCT: longlong4
    { x longlong }
    { y longlong }
    { z longlong }
    { w longlong } ;

STRUCT: ulonglong1
    { x ulonglong } ;
STRUCT: ulonglong2
    { x ulonglong }
    { y ulonglong } ;
STRUCT: ulonglong3
    { x ulonglong }
    { y ulonglong }
    { z ulonglong } ;
STRUCT: ulonglong4
    { x ulonglong }
    { y ulonglong }
    { z ulonglong }
    { w ulonglong } ;

STRUCT: float1
    { x float } ;
STRUCT: float2
    { x float }
    { y float } ;
STRUCT: float3
    { x float }
    { y float }
    { z float } ;
STRUCT: float4
    { x float }
    { y float }
    { z float }
    { w float } ;

STRUCT: double1
    { x double } ;
STRUCT: double2
    { x double }
    { y double } ;
STRUCT: double3
    { x double }
    { y double }
    { z double } ;
STRUCT: double4
    { x double }
    { y double }
    { z double }
    { w double } ;

char2 lookup-c-type
    2 >>align
    2 >>align-first
    drop
char4 lookup-c-type
    4 >>align
    4 >>align-first
    drop

uchar2 lookup-c-type
    2 >>align
    2 >>align-first
    drop
uchar4 lookup-c-type
    4 >>align
    4 >>align-first
    drop

short2 lookup-c-type
    4 >>align
    4 >>align-first
    drop
short4 lookup-c-type
    8 >>align
    8 >>align-first
    drop

ushort2 lookup-c-type
    4 >>align
    4 >>align-first
    drop
ushort4 lookup-c-type
    8 >>align
    8 >>align-first
    drop

int2 lookup-c-type
    8 >>align
    8 >>align-first
    drop
int4 lookup-c-type
    16 >>align
    16 >>align-first
    drop

uint2 lookup-c-type
    8 >>align
    8 >>align-first
    drop
uint4 lookup-c-type
    16 >>align
    16 >>align-first
    drop

long2 lookup-c-type
    long heap-size 2 * >>align
    long heap-size 2 * >>align-first
    drop
long4 lookup-c-type
    16 >>align
    16 >>align-first
    drop

ulong2 lookup-c-type
    long heap-size 2 * >>align
    long heap-size 2 * >>align-first
    drop
ulong4 lookup-c-type
    16 >>align
    16 >>align-first
    drop

longlong2 lookup-c-type
    16 >>align
    16 >>align-first
    drop
longlong4 lookup-c-type
    16 >>align
    16 >>align-first
    drop

ulonglong2 lookup-c-type
    16 >>align
    16 >>align-first
    drop
ulonglong4 lookup-c-type
    16 >>align
    16 >>align-first
    drop

float2 lookup-c-type
    8 >>align
    8 >>align-first
    drop
float4 lookup-c-type
    16 >>align
    16 >>align-first
    drop

double2 lookup-c-type
    16 >>align
    16 >>align-first
    drop
double4 lookup-c-type
    16 >>align
    16 >>align-first
    drop
