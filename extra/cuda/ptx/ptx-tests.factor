USING: cuda.ptx io.streams.string tools.test ;
IN: cuda.ptx.tests

{ "	.version 2.0
	.target sm_20
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20, .texmode_independent
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } { texmode .texmode_independent } } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_11, map_f64_to_f32
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target
            { arch sm_11 }
            { map_f64_to_f32? t }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_11, map_f64_to_f32, .texmode_independent
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target
            { arch sm_11 }
            { map_f64_to_f32? t }
            { texmode .texmode_independent }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	.global .f32 foo[9000];
	.extern .align 16 .shared .v4.f32 bar[];
	.func (.reg .f32 sum) zap (.reg .f32 a, .reg .f32 b)
	{
	add.rn.f32 sum, a, b;
	ret;
	}
	.func frob (.align 8 .param .u64 in, .align 8 .param .u64 out, .align 8 .param .u64 len)
	{
	ret;
	}
	.func twib
	{
	ret;
	}
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ ptx-variable
                { storage-space .global }
                { type .f32 }
                { name "foo" }
                { dim 9000 }
            }
            T{ ptx-variable
                { extern? t }
                { align 16 }
                { storage-space .shared }
                { type T{ .v4 f .f32 } }
                { name "bar" }
                { dim 0 }
            }
            T{ ptx-func
                { return T{ ptx-variable { storage-space .reg } { type .f32 } { name "sum" } } }
                { name "zap" }
                { params {
                    T{ ptx-variable { storage-space .reg } { type .f32 } { name "a" } }
                    T{ ptx-variable { storage-space .reg } { type .f32 } { name "b" } }
                } }
                { body {
                    T{ add { round .rn } { type .f32 } { dest "sum" } { a "a" } { b "b" } }
                    T{ ret }
                } }
            }
            T{ ptx-func
                { name "frob" }
                { params {
                    T{ ptx-variable { align 8 } { storage-space .param } { type .u64 } { name "in" } }
                    T{ ptx-variable { align 8 } { storage-space .param } { type .u64 } { name "out" } }
                    T{ ptx-variable { align 8 } { storage-space .param } { type .u64 } { name "len" } }
                } }
                { body {
                    T{ ret }
                } }
            }
            T{ ptx-func
                { name "twib" }
                { body {
                    T{ ret }
                } }
            }
        } }
    } ptx>string
] unit-test

{ "a" } [ [ "a" write-ptx-operand ] with-string-writer ] unit-test
{ "2" } [ [ 2 write-ptx-operand ] with-string-writer ] unit-test
{ "0d4000000000000000" } [ [ 2.0 write-ptx-operand ] with-string-writer ] unit-test
{ "!a" } [ [ T{ ptx-negation f "a" } write-ptx-operand ] with-string-writer ] unit-test
{ "{a, b, c, d}" } [ [ T{ ptx-vector f { "a" "b" "c" "d" } } write-ptx-operand ] with-string-writer ] unit-test
{ "[a]" } [ [ T{ ptx-indirect f "a" 0 } write-ptx-operand ] with-string-writer ] unit-test
{ "[a+1]" } [ [ T{ ptx-indirect f "a" 1 } write-ptx-operand ] with-string-writer ] unit-test
{ "[a-1]" } [ [ T{ ptx-indirect f "a" -1 } write-ptx-operand ] with-string-writer ] unit-test
{ "a[1]" } [ [ T{ ptx-element f "a" 1 } write-ptx-operand ] with-string-writer ] unit-test
{ "{a, b[2], 3, 0d4000000000000000}" } [ [ T{ ptx-vector f { "a" T{ ptx-element f "b" 2 } 3 2.0 } } write-ptx-operand ] with-string-writer ] unit-test

{ "	.version 2.0
	.target sm_20
	abs.s32 a, b;
	@p abs.s32 a, b;
	@!p abs.s32 a, b;
foo:	abs.s32 a, b;
	abs.ftz.f32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ abs { type .s32 } { dest "a" } { a "b" } }
            T{ abs
                { predicate "p" }
                { type .s32 } { dest "a" } { a "b" }
            }
            T{ abs
                { predicate T{ ptx-negation f "p" } }
                { type .s32 } { dest "a" } { a "b" }
            }
            T{ abs
                { label "foo" }
                { type .s32 } { dest "a" } { a "b" }
            }
            T{ abs { type .f32 } { dest "a" } { a "b" } { ftz? t } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	add.s32 a, b, c;
	add.cc.s32 a, b, c;
	add.sat.s32 a, b, c;
	add.ftz.f32 a, b, c;
	add.ftz.sat.f32 a, b, c;
	add.rz.sat.f32 a, b, c;
	add.rz.ftz.sat.f32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ add { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ add { cc? t } { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ add { sat? t } { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ add { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ add { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ add { round .rz } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ add { round .rz } { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	addc.s32 a, b, c;
	addc.cc.s32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ addc { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ addc { cc? t } { type .s32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	and.b32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ and { type .b32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	atom.and.u32 a, [b], c;
	atom.global.or.u32 a, [b], c;
	atom.shared.cas.u32 a, [b], c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ atom { op .and } { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } { b "c" } }
            T{ atom { storage-space .global } { op .or } { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } { b "c" } }
            T{ atom { storage-space .shared } { op .cas } { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } { b "c" } { c "d" } }

        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	bar.arrive a, b;
	bar.red.popc.u32 a, b, d;
	bar.red.popc.u32 a, b, !d;
	bar.red.popc.u32 a, b, c, !d;
	bar.sync a;
	bar.sync a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ bar.arrive { a "a" } { b "b" } }
            T{ bar.red { op .popc } { type .u32 } { dest "a" } { a "b" } { c "d" } }
            T{ bar.red { op .popc } { type .u32 } { dest "a" } { a "b" } { c T{ ptx-negation f "d" } } }
            T{ bar.red { op .popc } { type .u32 } { dest "a" } { a "b" } { b "c" } { c T{ ptx-negation f "d" } } }
            T{ bar.sync { a "a" } }
            T{ bar.sync { a "a" } { b "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	bfe.u32 a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ bfe { type .u32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	bfi.u32 a, b, c, d, e;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ bfi { type .u32 } { dest "a" } { a "b" } { b "c" } { c "d" } { d "e" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	bfind.u32 a, b;
	bfind.shiftamt.u32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ bfind { type .u32 } { dest "a" } { a "b" } }
            T{ bfind { type .u32 } { shiftamt? t } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	bra foo;
	bra.uni bar;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ bra { target "foo" } }
            T{ bra { uni? t } { target "bar" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	brev.b32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ brev { type .b32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	brkpt;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ brkpt }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	call foo;
	call.uni foo;
	call (a), foo;
	call (a), foo, (b);
	call (a), foo, (b, c);
	call (a), foo, (b, c, d);
	call (a[2]), foo, (b, c, d[3]);
	call foo, (b, c, d);
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ call { target "foo" } }
            T{ call { uni? t } { target "foo" } }
            T{ call { return "a" } { target "foo" } }
            T{ call { return "a" } { target "foo" } { params { "b" } } }
            T{ call { return "a" } { target "foo" } { params { "b" "c" } } }
            T{ call { return "a" } { target "foo" } { params { "b" "c" "d" } } }
            T{ call { return T{ ptx-element f "a" 2 } } { target "foo" } { params { "b" "c" T{ ptx-element f "d" 3 } } } }
            T{ call { target "foo" } { params { "b" "c" "d" } } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	clz.b32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ clz { type .b32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	cnot.b32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ cnot { type .b32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	copysign.f64 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ copysign { type .f64 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	cos.approx.f32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ cos { round .approx } { type .f32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	cvt.f32.s32 a, b;
	cvt.s32.f32 a, b;
	cvt.rp.f32.f64 a, b;
	cvt.rpi.s32.f32 a, b;
	cvt.ftz.f32.f64 a, b;
	cvt.sat.f32.f64 a, b;
	cvt.ftz.sat.f32.f64 a, b;
	cvt.rp.ftz.sat.f32.f64 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ cvt { dest-type .f32 } { type .s32 } { dest "a" } { a "b" } }
            T{ cvt { dest-type .s32 } { type .f32 } { dest "a" } { a "b" } }
            T{ cvt { round .rp } { dest-type .f32 } { type .f64 } { dest "a" } { a "b" } }
            T{ cvt { round .rpi } { dest-type .s32 } { type .f32 } { dest "a" } { a "b" } }
            T{ cvt { ftz? t } { dest-type .f32 } { type .f64 } { dest "a" } { a "b" } }
            T{ cvt { sat? t } { dest-type .f32 } { type .f64 } { dest "a" } { a "b" } }
            T{ cvt { ftz? t } { sat? t } { dest-type .f32 } { type .f64 } { dest "a" } { a "b" } }
            T{ cvt { round .rp } { ftz? t } { sat? t } { dest-type .f32 } { type .f64 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	cvta.global.u64 a, b;
	cvta.shared.u64 a, b;
	cvta.to.shared.u64 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ cvta { storage-space .global } { type .u64 } { dest "a" } { a "b" } }
            T{ cvta { storage-space .shared } { type .u64 } { dest "a" } { a "b" } }
            T{ cvta { to? t } { storage-space .shared } { type .u64 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	div.u32 a, b, c;
	div.approx.f32 a, b, c;
	div.approx.ftz.f32 a, b, c;
	div.full.f32 a, b, c;
	div.full.ftz.f32 a, b, c;
	div.f32 a, b, c;
	div.rz.f32 a, b, c;
	div.ftz.f32 a, b, c;
	div.rz.ftz.f32 a, b, c;
	div.f64 a, b, c;
	div.rz.f64 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ div { type .u32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { round .approx } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { round .approx } { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { round .full } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { round .full } { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { round .rz } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { round .rz } { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ div { type .f64 } { dest "a" } { a "b" } { b "c" } }
            T{ div { round .rz } { type .f64 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	ex2.approx.f32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ ex2 { round .approx } { type .f32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	exit;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ exit }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	fma.f32 a, b, c, d;
	fma.sat.f32 a, b, c, d;
	fma.ftz.f32 a, b, c, d;
	fma.ftz.sat.f32 a, b, c, d;
	fma.rz.sat.f32 a, b, c, d;
	fma.rz.ftz.sat.f32 a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ fma { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ fma { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ fma { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ fma { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ fma { round .rz } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ fma { round .rz } { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	isspacep.shared a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ isspacep { storage-space .shared } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	ld.u32 a, [b];
	ld.v2.u32 a, [b];
	ld.v4.u32 a, [b];
	ld.v4.u32 {a, b, c, d}, [e];
	ld.lu.u32 a, [b];
	ld.const.lu.u32 a, [b];
	ld.volatile.const[5].u32 a, [b];
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ ld { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ld { type T{ .v2 { of .u32 } } } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ld { type T{ .v4 { of .u32 } } } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ld { type T{ .v4 { of .u32 } } } { dest T{ ptx-vector f { "a" "b" "c" "d" } } } { a "[e]" } }
            T{ ld { cache-op .lu } { type .u32 } { dest "a" } { a "[b]" } }
            T{ ld { storage-space T{ .const } } { cache-op .lu } { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ld { volatile? t } { storage-space T{ .const { bank 5 } } } { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	ldu.u32 a, [b];
	ldu.v2.u32 a, [b];
	ldu.v4.u32 a, [b];
	ldu.v4.u32 {a, b, c, d}, [e];
	ldu.lu.u32 a, [b];
	ldu.const.lu.u32 a, [b];
	ldu.volatile.const[5].u32 a, [b];
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ ldu { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ldu { type T{ .v2 { of .u32 } } } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ldu { type T{ .v4 { of .u32 } } } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ldu { type T{ .v4 { of .u32 } } } { dest T{ ptx-vector f { "a" "b" "c" "d" } } } { a "[e]" } }
            T{ ldu { cache-op .lu } { type .u32 } { dest "a" } { a "[b]" } }
            T{ ldu { storage-space T{ .const } } { cache-op .lu } { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } }
            T{ ldu { volatile? t } { storage-space T{ .const { bank 5 } } } { type .u32 } { dest "a" } { a T{ ptx-indirect f "b" } } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	lg2.approx.f32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ lg2 { round .approx } { type .f32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	mad.s32 a, b, c, d;
	mad.lo.s32 a, b, c, d;
	mad.sat.s32 a, b, c, d;
	mad.hi.sat.s32 a, b, c, d;
	mad.ftz.f32 a, b, c, d;
	mad.ftz.sat.f32 a, b, c, d;
	mad.rz.sat.f32 a, b, c, d;
	mad.rz.ftz.sat.f32 a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ mad { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad { mode .lo } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad { sat? t } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad { mode .hi } { sat? t } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad { round .rz } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad { round .rz } { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	mad24.s32 a, b, c, d;
	mad24.lo.s32 a, b, c, d;
	mad24.sat.s32 a, b, c, d;
	mad24.hi.sat.s32 a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ mad24 { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad24 { mode .lo } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad24 { sat? t } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ mad24 { mode .hi } { sat? t } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	neg.s32 a, b;
	neg.f32 a, b;
	neg.ftz.f32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ neg { type .s32 } { dest "a" } { a "b" } }
            T{ neg { type .f32 } { dest "a" } { a "b" } }
            T{ neg { ftz? t } { type .f32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	not.b32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ not { type .b32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	or.b32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ or { type .b32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	pmevent a;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ pmevent { a "a" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	popc.b64 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ popc { type .b64 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	prefetch.L1 [a];
	prefetch.local.L2 [a];
	prefetchu.L1 [a];
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ prefetch { level .L1 } { a T{ ptx-indirect f "a" } } }
            T{ prefetch { storage-space .local } { level .L2 } { a T{ ptx-indirect f "a" } } }
            T{ prefetchu { level .L1 } { a T{ ptx-indirect f "a" } } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	prmt.b32 a, b, c, d;
	prmt.b32.f4e a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ prmt { type .b32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ prmt { type .b32 } { mode .f4e } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	rcp.approx.f32 a, b;
	rcp.approx.ftz.f32 a, b;
	rcp.f32 a, b;
	rcp.rz.f32 a, b;
	rcp.ftz.f32 a, b;
	rcp.rz.ftz.f32 a, b;
	rcp.f64 a, b;
	rcp.rz.f64 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ rcp { round .approx } { type .f32 } { dest "a" } { a "b" } }
            T{ rcp { round .approx } { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ rcp { type .f32 } { dest "a" } { a "b" } }
            T{ rcp { round .rz } { type .f32 } { dest "a" } { a "b" } }
            T{ rcp { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ rcp { round .rz } { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ rcp { type .f64 } { dest "a" } { a "b" } }
            T{ rcp { round .rz } { type .f64 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	red.and.u32 [a], b;
	red.global.and.u32 [a], b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ red { op .and } { type .u32 } { dest T{ ptx-indirect f "a" } } { a "b" } }
            T{ red { storage-space .global } { op .and } { type .u32 } { dest T{ ptx-indirect f "a" } } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	rsqrt.approx.f32 a, b;
	rsqrt.approx.ftz.f32 a, b;
	rsqrt.approx.f64 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ rsqrt { round .approx } { type .f32 } { dest "a" } { a "b" } }
            T{ rsqrt { round .approx } { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ rsqrt { round .approx } { type .f64 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	rsqrt.approx.f32 a, b;
	rsqrt.approx.ftz.f32 a, b;
	rsqrt.approx.f64 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ rsqrt { round .approx } { type .f32 } { dest "a" } { a "b" } }
            T{ rsqrt { round .approx } { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ rsqrt { round .approx } { type .f64 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	sad.u32 a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ sad { type .u32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	selp.u32 a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ selp { type .u32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	set.gt.u32.s32 a, b, c;
	set.gt.ftz.u32.f32 a, b, c;
	set.gt.and.ftz.u32.f32 a, b, c, d;
	set.gt.and.ftz.u32.f32 a, b, c, !d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ set { cmp-op .gt } { dest-type .u32 } { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ set { cmp-op .gt } { ftz? t } { dest-type .u32 } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ set { cmp-op .gt } { bool-op .and } { ftz? t } { dest-type .u32 } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ set { cmp-op .gt } { bool-op .and } { ftz? t } { dest-type .u32 } { type .f32 } { dest "a" } { a "b" } { b "c" } { c T{ ptx-negation f "d" } } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	setp.gt.s32 a, b, c;
	setp.gt.s32 a|z, b, c;
	setp.gt.ftz.f32 a, b, c;
	setp.gt.and.ftz.f32 a, b, c, d;
	setp.gt.and.ftz.f32 a, b, c, !d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ setp { cmp-op .gt } { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ setp { cmp-op .gt } { type .s32 } { dest "a" } { |dest "z" } { a "b" } { b "c" } }
            T{ setp { cmp-op .gt } { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ setp { cmp-op .gt } { bool-op .and } { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ setp { cmp-op .gt } { bool-op .and } { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } { c "!d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	shl.b32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ shl { type .b32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	shr.b32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ shr { type .b32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	sin.approx.f32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ sin { round .approx } { type .f32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	slct.f32.s32 a, b, c, d;
	slct.ftz.f32.s32 a, b, c, d;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ slct { dest-type .f32 } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
            T{ slct { ftz? t } { dest-type .f32 } { type .s32 } { dest "a" } { a "b" } { b "c" } { c "d" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	sqrt.approx.f32 a, b;
	sqrt.approx.ftz.f32 a, b;
	sqrt.f32 a, b;
	sqrt.rz.f32 a, b;
	sqrt.ftz.f32 a, b;
	sqrt.rz.ftz.f32 a, b;
	sqrt.f64 a, b;
	sqrt.rz.f64 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ sqrt { round .approx } { type .f32 } { dest "a" } { a "b" } }
            T{ sqrt { round .approx } { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ sqrt { type .f32 } { dest "a" } { a "b" } }
            T{ sqrt { round .rz } { type .f32 } { dest "a" } { a "b" } }
            T{ sqrt { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ sqrt { round .rz } { ftz? t } { type .f32 } { dest "a" } { a "b" } }
            T{ sqrt { type .f64 } { dest "a" } { a "b" } }
            T{ sqrt { round .rz } { type .f64 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	st.u32 [a], b;
	st.v2.u32 [a], b;
	st.v4.u32 [a], b;
	st.v4.u32 [a], {b, c, d, e};
	st.lu.u32 [a], b;
	st.local.lu.u32 [a], b;
	st.volatile.local.u32 [a], b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ st { type .u32 } { dest T{ ptx-indirect f "a" } } { a "b" } }
            T{ st { type T{ .v2 { of .u32 } } } { dest T{ ptx-indirect f "a" } } { a "b" } }
            T{ st { type T{ .v4 { of .u32 } } } { dest T{ ptx-indirect f "a" } } { a "b" } }
            T{ st { type T{ .v4 { of .u32 } } } { dest T{ ptx-indirect f "a" } } { a T{ ptx-vector f { "b" "c" "d" "e" } } } }
            T{ st { cache-op .lu } { type .u32 } { dest T{ ptx-indirect f "a" } } { a "b" } }
            T{ st { storage-space .local } { cache-op .lu } { type .u32 } { dest T{ ptx-indirect f "a" } } { a "b" } }
            T{ st { volatile? t } { storage-space .local } { type .u32 } { dest T{ ptx-indirect f "a" } } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	sub.s32 a, b, c;
	sub.cc.s32 a, b, c;
	sub.sat.s32 a, b, c;
	sub.ftz.f32 a, b, c;
	sub.ftz.sat.f32 a, b, c;
	sub.rz.sat.f32 a, b, c;
	sub.rz.ftz.sat.f32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ sub { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ sub { cc? t } { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ sub { sat? t } { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ sub { ftz? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ sub { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ sub { round .rz } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
            T{ sub { round .rz } { ftz? t } { sat? t } { type .f32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	subc.s32 a, b, c;
	subc.cc.s32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ subc { type .s32 } { dest "a" } { a "b" } { b "c" } }
            T{ subc { cc? t } { type .s32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	testp.finite.f32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ testp { op .finite } { type .f32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	trap;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ trap }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	vote.all.pred a, b;
	vote.all.pred a, !b;
	vote.ballot.b32 a, b;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ vote { mode .all } { type .pred } { dest "a" } { a "b" } }
            T{ vote { mode .all } { type .pred } { dest "a" } { a "!b" } }
            T{ vote { mode .ballot } { type .b32 } { dest "a" } { a "b" } }
        } }
    } ptx>string
] unit-test

{ "	.version 2.0
	.target sm_20
	xor.b32 a, b, c;
" } [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
        { body {
            T{ xor { type .b32 } { dest "a" } { a "b" } { b "c" } }
        } }
    } ptx>string
] unit-test
