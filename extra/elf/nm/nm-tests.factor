! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: elf.nm io io.streams.string kernel literals multiline strings
system tools.test ;
IN: elf.nm.tests

STRING: validation-output
0000000000000000 absolute         init.c
000000000040046c .text            call_gmon_start
0000000000000000 absolute         crtstuff.c
0000000000600e18 .ctors           __CTOR_LIST__
0000000000600e28 .dtors           __DTOR_LIST__
0000000000600e38 .jcr             __JCR_LIST__
0000000000400490 .text            __do_global_dtors_aux
0000000000601020 .bss             completed.7342
0000000000601028 .bss             dtor_idx.7344
0000000000400500 .text            frame_dummy
0000000000000000 absolute         crtstuff.c
0000000000600e20 .ctors           __CTOR_END__
00000000004006d8 .eh_frame        __FRAME_END__
0000000000600e38 .jcr             __JCR_END__
00000000004005e0 .text            __do_global_ctors_aux
0000000000000000 absolute         test.c
0000000000600fe8 .got.plt         _GLOBAL_OFFSET_TABLE_
0000000000600e14 .ctors           __init_array_end
0000000000600e14 .ctors           __init_array_start
0000000000600e40 .dynamic         _DYNAMIC
0000000000601010 .data            data_start
0000000000000000 undefined        printf@@GLIBC_2.2.5
0000000000400540 .text            __libc_csu_fini
0000000000400440 .text            _start
0000000000000000 undefined        __gmon_start__
0000000000000000 undefined        _Jv_RegisterClasses
0000000000400618 .fini            _fini
0000000000000000 undefined        __libc_start_main@@GLIBC_2.2.5
0000000000400628 .rodata          _IO_stdin_used
0000000000601010 .data            __data_start
0000000000601018 .data            __dso_handle
0000000000600e30 .dtors           __DTOR_END__
0000000000400550 .text            __libc_csu_init
0000000000601020 absolute         __bss_start
0000000000601030 absolute         _end
0000000000601020 absolute         _edata
0000000000400524 .text            main
00000000004003f0 .init            _init

;

cpu ppc? [
    { $ validation-output }
    [ [ "resource:extra/elf/a.elf" elf-nm ] with-string-writer ]
    unit-test
] unless
