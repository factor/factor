! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays elf kernel sequences system tools.test ;

cpu ppc? [
{
    {
        ""
        ".interp"
        ".note.ABI-tag"
        ".note.gnu.build-id"
        ".hash"
        ".gnu.hash"
        ".dynsym"
        ".dynstr"
        ".gnu.version"
        ".gnu.version_r"
        ".rela.dyn"
        ".rela.plt"
        ".init"
        ".plt"
        ".text"
        ".fini"
        ".rodata"
        ".eh_frame_hdr"
        ".eh_frame"
        ".ctors"
        ".dtors"
        ".jcr"
        ".dynamic"
        ".got"
        ".got.plt"
        ".data"
        ".bss"
        ".comment"
        ".debug_aranges"
        ".debug_pubnames"
        ".debug_info"
        ".debug_abbrev"
        ".debug_line"
        ".debug_str"
        ".shstrtab"
        ".symtab"
        ".strtab"
    }
}
[
    "resource:extra/elf/a.elf" [
        sections [ name>> ] map
    ] with-mapped-elf
]
unit-test

{
    {
        ".interp"
        ".note.ABI-tag"
        ".note.gnu.build-id"
        ".hash"
        ".gnu.hash"
        ".dynsym"
        ".dynstr"
        ".gnu.version"
        ".gnu.version_r"
        ".rela.dyn"
        ".rela.plt"
        ".init"
        ".plt"
        ".text"
        ".fini"
        ".rodata"
        ".eh_frame_hdr"
        ".eh_frame"
    }
}
[
    "resource:extra/elf/a.elf" [
        segments [ program-header>> p_type>> PT_LOAD = ] find nip
        sections [ name>> ] map
    ] with-mapped-elf
]
unit-test

{
    {
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        "init.c"
        "call_gmon_start"
        "crtstuff.c"
        "__CTOR_LIST__"
        "__DTOR_LIST__"
        "__JCR_LIST__"
        "__do_global_dtors_aux"
        "completed.7342"
        "dtor_idx.7344"
        "frame_dummy"
        "crtstuff.c"
        "__CTOR_END__"
        "__FRAME_END__"
        "__JCR_END__"
        "__do_global_ctors_aux"
        "test.c"
        "_GLOBAL_OFFSET_TABLE_"
        "__init_array_end"
        "__init_array_start"
        "_DYNAMIC"
        "data_start"
        "printf@@GLIBC_2.2.5"
        "__libc_csu_fini"
        "_start"
        "__gmon_start__"
        "_Jv_RegisterClasses"
        "_fini"
        "__libc_start_main@@GLIBC_2.2.5"
        "_IO_stdin_used"
        "__data_start"
        "__dso_handle"
        "__DTOR_END__"
        "__libc_csu_init"
        "__bss_start"
        "_end"
        "_edata"
        "main"
        "_init"
    }
}
[
    "resource:extra/elf/a.elf" [
        sections ".symtab" find-section symbols
        [ name>> ] map
    ] with-mapped-elf
]
unit-test

{
    B{
        85 72 137 229 184 44 6 64 0 72 137 199 184 0 0 0 0 232 222
        254 255 255 201 195
    }
}
[
    "resource:extra/elf/a.elf" [
        sections ".symtab" "main" find-section-symbol
        symbol-data >byte-array
    ] with-mapped-elf
]
unit-test
] unless
