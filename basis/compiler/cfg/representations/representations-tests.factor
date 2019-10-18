USING: accessors compiler.cfg compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.representations.conversion
compiler.cfg.representations.preferred compiler.cfg.utilities
compiler.constants compiler.test cpu.architecture kernel layouts
literals make math namespaces sequences system tools.test ;
FROM: alien.c-types => char ;
IN: compiler.cfg.representations

{ { double-rep double-rep } } [
    T{ ##add-float
       { dst 5 }
       { src1 3 }
       { src2 4 }
    } uses-vreg-reps
] unit-test

{ { double-rep } } [
    T{ ##load-memory-imm
       { dst 5 }
       { base 3 }
       { offset 0 }
       { rep double-rep }
    } defs-vreg-reps
] unit-test

H{ } clone representations set

3 vreg-counter set-global

{
    {
        T{ ##allot f 2 16 float 4 }
        T{ ##store-memory-imm f 1 2 $[ float-offset ] double-rep f }
    }
} [
    [
        2 1 tagged-rep double-rep emit-conversion
    ] { } make
] unit-test

{
    {
        T{ ##load-memory-imm f 2 1 $[ float-offset ] double-rep f }
    }
} [
    [
        2 1 double-rep tagged-rep emit-conversion
    ] { } make
] unit-test

: test-representations ( -- )
    0 get block>cfg dup cfg set select-representations ;

! Make sure cost calculation isn't completely wrong
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D: 0 }
    T{ ##peek f 2 D: 1 }
    T{ ##add-float f 3 1 2 }
    T{ ##replace f 3 D: 0 }
    T{ ##replace f 3 D: 1 }
    T{ ##replace f 3 D: 2 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

{ } [ test-representations ] unit-test

{ 1 } [ 1 get instructions>> [ ##allot? ] count ] unit-test

! Don't dereference the result of a peek
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D: 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##add-float f 2 1 1 }
    T{ ##replace f 2 D: 0 }
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

V{
    T{ ##add-float f 3 1 1 }
    T{ ##replace f 3 D: 0 }
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

0 1 edge
1 { 2 3 } edges

{ } [ test-representations ] unit-test

{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##branch }
    }
} [ 1 get instructions>> ] unit-test

! We cannot untag-fixnum the result of a peek if there are usages
! of it as a tagged-rep
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D: 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##replace f 1 R: 0 }
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

V{
    T{ ##mul f 2 1 1 }
    T{ ##replace f 2 D: 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

0 1 edge
1 { 2 3 } edges
3 { 3 4 } edges
2 4 edge

{ } [ test-representations ] unit-test

{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##branch }
    }
} [ 1 get instructions>> ] unit-test

! But its ok to untag-fixnum the result of a peek if all usages use
! it as int-rep
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D: 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

V{
    T{ ##add f 2 1 1 }
    T{ ##mul f 3 1 1 }
    T{ ##replace f 2 D: 0 }
    T{ ##replace f 3 D: 1 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

0 1 edge
1 { 2 3 } edges
3 { 3 4 } edges
2 4 edge

3 vreg-counter set-global

{ } [ test-representations ] unit-test

{
    V{
        T{ ##peek f 4 D: 0 }
        T{ ##sar-imm f 1 4 $[ tag-bits get ] }
        T{ ##branch }
    }
} [ 1 get instructions>> ] unit-test

! scalar-rep => int-rep conversion
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D: 0 }
    T{ ##peek f 2 D: 0 }
    T{ ##vector>scalar f 3 2 int-4-rep }
    T{ ##replace f 3 D: 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

{ } [ test-representations ] unit-test

{ t } [ 1 get instructions>> 4 swap nth ##scalar>integer? ] unit-test

! Test phi node behavior
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##load-integer f 1 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 2 2 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f 3 H{ { 1 1 } { 2 2 } } }
    T{ ##replace f 3 D: 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge
3 4 edge

{ } [ test-representations ] unit-test

{ T{ ##load-tagged f 1 $[ 1 tag-fixnum ] } }
[ 1 get instructions>> first ]
unit-test

{ T{ ##load-tagged f 2 $[ 2 tag-fixnum ] } }
[ 2 get instructions>> first ]
unit-test

! ##load-reference corner case
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 0 D: 0 }
    T{ ##peek f 1 D: 1 }
    T{ ##add f 2 0 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-reference f 3 f }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f 4 H{ { 1 2 } { 2 3 } } }
    T{ ##replace f 4 D: 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge
3 4 edge

{ } [ test-representations ] unit-test

! Don't untag the f!
{ 2 } [ 2 get instructions>> length ] unit-test

cpu x86.32? [

    ! Make sure load-constant is converted into load-double
    V{
        T{ ##prologue }
        T{ ##branch }
    } 0 test-bb

    V{
        T{ ##peek f 1 D: 0 }
        T{ ##load-reference f 2 0.5 }
        T{ ##add-float f 3 1 2 }
        T{ ##replace f 3 D: 0 }
        T{ ##branch }
    } 1 test-bb

    V{
        T{ ##epilogue }
        T{ ##return }
    } 2 test-bb

    0 1 edge
    1 2 edge

    [ ] [ test-representations ] unit-test

    [ t ] [ 1 get instructions>> second ##load-double? ] unit-test

    ! Make sure phi nodes are handled in a sane way
    V{
        T{ ##prologue }
        T{ ##branch }
    } 0 test-bb

    V{
        T{ ##peek f 1 D: 0 }
        T{ ##compare-imm-branch f 1 2 cc= }
    } 1 test-bb

    V{
        T{ ##load-reference f 2 1.5 }
        T{ ##branch }
    } 2 test-bb

    V{
        T{ ##load-reference f 3 2.5 }
        T{ ##branch }
    } 3 test-bb

    V{
        T{ ##phi f 4 H{ { 2 2 } { 3 3 } } }
        T{ ##peek f 5 D: 0 }
        T{ ##add-float f 6 4 5 }
        T{ ##replace f 6 D: 0 }
    } 4 test-bb

    V{
        T{ ##epilogue }
        T{ ##return }
    } 5 test-bb

    test-diamond
    4 5 edge

    [ ] [ test-representations ] unit-test

    [ t ] [ 2 get instructions>> first ##load-double? ] unit-test

    [ t ] [ 3 get instructions>> first ##load-double? ] unit-test

    [ t ] [ 4 get instructions>> first ##phi? ] unit-test
] when

: test-peephole ( insns -- insns )
    0 test-bb
    test-representations
    0 get instructions>> ;

! Don't convert the def site into anything but tagged-rep since
! we might lose precision
5 vreg-counter set-global

{ f } [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 1 }
        T{ ##add-float f 3 0 0 }
        T{ ##store-memory-imm f 3 2 0 float-rep f }
        T{ ##store-memory-imm f 3 2 4 float-rep f }
        T{ ##mul-float f 4 0 0 }
        T{ ##replace f 4 D: 0 }
    } test-peephole
    [ ##single>double-float? ] any?
] unit-test

! Converting a ##load-integer into a ##load-tagged
{
    V{
        T{ ##load-tagged f 1 $[ 100 tag-fixnum ] }
        T{ ##replace f 1 D: 0 }
    }
} [
    V{
        T{ ##load-integer f 1 100 }
        T{ ##replace f 1 D: 0 }
    } test-peephole
] unit-test

! Peephole optimization if input to ##shl-imm is tagged
3 vreg-counter set-global

{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##sar-imm f 2 1 1 }
        T{ ##add f 4 2 2 }
        T{ ##shl-imm f 3 4 $[ tag-bits get ] }
        T{ ##replace f 3 D: 0 }
    }
} [
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##shl-imm f 2 1 3 }
        T{ ##add f 3 2 2 }
        T{ ##replace f 3 D: 0 }
    } test-peephole
] unit-test

3 vreg-counter set-global

{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##shl-imm f 2 1 $[ 10 tag-bits get - ] }
        T{ ##add f 4 2 2 }
        T{ ##shl-imm f 3 4 $[ tag-bits get ] }
        T{ ##replace f 3 D: 0 }
    }
} [
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##shl-imm f 2 1 10 }
        T{ ##add f 3 2 2 }
        T{ ##replace f 3 D: 0 }
    } test-peephole
] unit-test

{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##copy f 2 1 int-rep }
        T{ ##add f 5 2 2 }
        T{ ##shl-imm f 3 5 $[ tag-bits get ] }
        T{ ##replace f 3 D: 0 }
    }
} [
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##shl-imm f 2 1 $[ tag-bits get ] }
        T{ ##add f 3 2 2 }
        T{ ##replace f 3 D: 0 }
    } test-peephole
] unit-test

! Peephole optimization if output of ##shl-imm needs to be tagged
{
    V{
        T{ ##load-integer f 1 100 }
        T{ ##shl-imm f 2 1 $[ 3 tag-bits get + ] }
        T{ ##replace f 2 D: 0 }
    }
} [
    V{
        T{ ##load-integer f 1 100 }
        T{ ##shl-imm f 2 1 3 }
        T{ ##replace f 2 D: 0 }
    } test-peephole
] unit-test

! Peephole optimization if both input and output of ##shl-imm
! need to be tagged
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##shl-imm f 1 0 3 }
        T{ ##replace f 1 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##shl-imm f 1 0 3 }
        T{ ##replace f 1 D: 0 }
    } test-peephole
] unit-test

! Peephole optimization if neither input nor output of ##shl-imm need to be tagged
{
    V{
        T{ ##load-integer f 1 100 }
        T{ ##shl-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##load-integer f 4 100 }
        T{ ##store-memory f 2 3 4 0 0 int-rep char }
    }
} [
    V{
        T{ ##load-integer f 1 100 }
        T{ ##shl-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##load-integer f 4 100 }
        T{ ##store-memory f 2 3 4 0 0 int-rep char }
    } test-peephole
] unit-test

6 vreg-counter set-global

! Peephole optimization if input to ##sar-imm is tagged
{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##sar-imm f 7 1 $[ 3 tag-bits get + ] }
        T{ ##shl-imm f 2 7 $[ tag-bits get ] }
        T{ ##replace f 2 D: 0 }
    }
} [
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##sar-imm f 2 1 3 }
        T{ ##replace f 2 D: 0 }
    } test-peephole
] unit-test

6 vreg-counter set-global

! (Lack of) peephole optimization if output of ##sar-imm needs to be tagged
{
    V{
        T{ ##load-integer f 1 100 }
        T{ ##sar-imm f 7 1 3 }
        T{ ##shl-imm f 2 7 $[ tag-bits get ] }
        T{ ##replace f 2 D: 0 }
    }
} [
    V{
        T{ ##load-integer f 1 100 }
        T{ ##sar-imm f 2 1 3 }
        T{ ##replace f 2 D: 0 }
    } test-peephole
] unit-test

! Peephole optimization if input of ##sar-imm is tagged but output is untagged
! need to be tagged
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##sar-imm f 1 0 $[ 3 tag-bits get + ] }
        T{ ##load-integer f 3 100 }
        T{ ##load-integer f 4 100 }
        T{ ##store-memory f 1 3 4 0 0 int-rep char }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##sar-imm f 1 0 3 }
        T{ ##load-integer f 3 100 }
        T{ ##load-integer f 4 100 }
        T{ ##store-memory f 1 3 4 0 0 int-rep char }
    } test-peephole
] unit-test

! Peephole optimization if neither input nor output of ##sar-imm need to be tagged
{
    V{
        T{ ##load-integer f 1 100 }
        T{ ##sar-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##load-integer f 4 100 }
        T{ ##store-memory f 2 3 4 0 0 int-rep char }
    }
} [
    V{
        T{ ##load-integer f 1 100 }
        T{ ##sar-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##load-integer f 4 100 }
        T{ ##store-memory f 2 3 4 0 0 int-rep char }
    } test-peephole
] unit-test

{
    V{
        T{ ##load-vector f 0 B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } short-8-rep }
        T{ ##select-vector f 1 0 0 short-8-rep }
        T{ ##sar-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##add f 4 2 3 }
        T{ ##load-integer f 5 100 }
        T{ ##load-integer f 6 100 }
        T{ ##store-memory f 4 5 6 0 0 int-rep char }
    }
} [
    V{
        T{ ##load-vector f 0 B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } short-8-rep }
        T{ ##select-vector f 1 0 0 short-8-rep }
        T{ ##sar-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##add f 4 2 3 }
        T{ ##load-integer f 5 100 }
        T{ ##load-integer f 6 100 }
        T{ ##store-memory f 4 5 6 0 0 int-rep char }
    } test-peephole
] unit-test

6 vreg-counter set-global

{
    V{
        T{ ##load-vector f 0 B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } int-4-rep }
        T{ ##select-vector f 1 0 0 int-4-rep }
        T{ ##sar-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##add f 7 2 3 }
        T{ ##shl-imm f 4 7 $[ tag-bits get ] }
        T{ ##replace f 4 D: 0 }
    }
} [
    V{
        T{ ##load-vector f 0 B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } int-4-rep }
        T{ ##select-vector f 1 0 0 int-4-rep }
        T{ ##sar-imm f 2 1 3 }
        T{ ##load-integer f 3 100 }
        T{ ##add f 4 2 3 }
        T{ ##replace f 4 D: 0 }
    } test-peephole
] unit-test

! Tag/untag elimination
{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##add-imm f 2 1 $[ 100 tag-fixnum ] }
        T{ ##replace f 2 D: 0 }
    }
} [
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##add-imm f 2 1 100 }
        T{ ##replace f 2 D: 0 }
    } test-peephole
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##add f 2 0 1 }
        T{ ##replace f 2 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##add f 2 0 1 }
        T{ ##replace f 2 D: 0 }
    } test-peephole
] unit-test

! Make sure we don't exceed immediate bounds
cpu x86.64? [
    4 vreg-counter set-global

    [
        V{
            T{ ##peek f 0 D: 0 }
            T{ ##sar-imm f 5 0 $[ tag-bits get ] }
            T{ ##add-imm f 6 5 $[ 30 2^ ] }
            T{ ##shl-imm f 2 6 $[ tag-bits get ] }
            T{ ##replace f 2 D: 0 }
        }
    ] [
        V{
            T{ ##peek f 0 D: 0 }
            T{ ##add-imm f 2 0 $[ 30 2^ ] }
            T{ ##replace f 2 D: 0 }
        } test-peephole
    ] unit-test

    [
        V{
            T{ ##load-integer f 0 100 }
            T{ ##mul-imm f 7 0 $[ 30 2^ ] }
            T{ ##shl-imm f 1 7 $[ tag-bits get ] }
            T{ ##replace f 1 D: 0 }
        }
    ] [
        V{
            T{ ##load-integer f 0 100 }
            T{ ##mul-imm f 1 0 $[ 30 2^ ] }
            T{ ##replace f 1 D: 0 }
        } test-peephole
    ] unit-test
] when

! Tag/untag elimination for ##mul-imm
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##mul-imm f 1 0 100 }
        T{ ##replace f 1 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##mul-imm f 1 0 100 }
        T{ ##replace f 1 D: 0 }
    } test-peephole
] unit-test

4 vreg-counter set-global

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##sar-imm f 5 1 $[ tag-bits get ] }
        T{ ##add-imm f 2 5 30 }
        T{ ##mul-imm f 3 2 $[ 100 tag-fixnum ] }
        T{ ##replace f 3 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##add-imm f 2 1 30 }
        T{ ##mul-imm f 3 2 100 }
        T{ ##replace f 3 D: 0 }
    } test-peephole
] unit-test

! Tag/untag elimination for ##compare-integer and ##test
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##test f 2 0 1 cc= }
        T{ ##replace f 2 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##test f 2 0 1 cc= }
        T{ ##replace f 2 D: 0 }
    } test-peephole
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer f 2 0 1 cc= }
        T{ ##replace f 2 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer f 2 0 1 cc= }
        T{ ##replace f 2 D: 0 }
    } test-peephole
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer-branch f 0 1 cc= }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer-branch f 0 1 cc= }
    } test-peephole
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##test-branch f 0 1 cc= }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##test-branch f 0 1 cc= }
    } test-peephole
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer-imm-branch f 0 $[ 10 tag-fixnum ] cc= }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer-imm-branch f 0 10 cc= }
    } test-peephole
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##test-imm-branch f 0 $[ 10 tag-fixnum ] cc= }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##test-imm-branch f 0 10 cc= }
    } test-peephole
] unit-test

! Tag/untag elimination for ##neg
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##neg f 1 0 }
        T{ ##replace f 1 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##neg f 1 0 }
        T{ ##replace f 1 D: 0 }
    } test-peephole
] unit-test

4 vreg-counter set-global

{
    V{
        T{ ##peek { dst 0 } { loc D: 0 } }
        T{ ##peek { dst 1 } { loc D: 1 } }
        T{ ##sar-imm { dst 5 } { src1 0 } { src2 4 } }
        T{ ##sar-imm { dst 6 } { src1 1 } { src2 4 } }
        T{ ##mul { dst 2 } { src1 5 } { src2 6 } }
        T{ ##mul-imm { dst 3 } { src1 2 } { src2 -16 } }
        T{ ##replace { src 3 } { loc D: 0 } }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##mul f 2 0 1 }
        T{ ##neg f 3 2 }
        T{ ##replace f 3 D: 0 }
    } test-peephole
] unit-test

! Tag/untag elimination for ##not
2 vreg-counter set-global

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##not f 3 0 }
        T{ ##xor-imm f 1 3 $[ tag-mask get ] }
        T{ ##replace f 1 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##not f 1 0 }
        T{ ##replace f 1 D: 0 }
    } test-peephole
] unit-test

! untag elimination for ##bit-count
2 vreg-counter set-global

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##bit-count f 3 0 }
        T{ ##shl-imm f 1 3 $[ tag-bits get ] }
        T{ ##replace f 1 D: 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##bit-count f 1 0 }
        T{ ##replace f 1 D: 0 }
    } test-peephole
] unit-test
