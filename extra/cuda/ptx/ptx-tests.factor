USING: cuda.ptx tools.test ;
IN: cuda.ptx.tests

[ """	.version 2.0
	.target sm_20
""" ] [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } } }
    } ptx>string
] unit-test

[ """	.version 2.0
	.target sm_20, .texmode_independent
""" ] [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target { arch sm_20 } { texmode .texmode_independent } } }
    } ptx>string
] unit-test

[ """	.version 2.0
	.target sm_11, map_f64_to_f32
""" ] [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target
            { arch sm_11 }
            { map_f64_to_f32? t }
        } }
    } ptx>string
] unit-test

[ """	.version 2.0
	.target sm_11, map_f64_to_f32, .texmode_independent
""" ] [
    T{ ptx
        { version "2.0" }
        { target T{ ptx-target
            { arch sm_11 }
            { map_f64_to_f32? t }
            { texmode .texmode_independent }
        } }
    } ptx>string
] unit-test

[ """	.version 2.0
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
""" ] [
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
