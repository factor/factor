! Copyright (C) 2010 Erik Charlebois.
! See http:// factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct kernel literals math unix.types ;
IN: macho

TYPEDEF: int       integer_t
TYPEDEF: int       vm_prot_t
TYPEDEF: integer_t cpu_type_t
TYPEDEF: integer_t cpu_subtype_t
TYPEDEF: integer_t cpu_threadtype_t

CONSTANT: VM_PROT_NONE        HEX: 00
CONSTANT: VM_PROT_READ        HEX: 01
CONSTANT: VM_PROT_WRITE       HEX: 02
CONSTANT: VM_PROT_EXECUTE     HEX: 04
CONSTANT: VM_PROT_DEFAULT     HEX: 03
CONSTANT: VM_PROT_ALL         HEX: 07
CONSTANT: VM_PROT_NO_CHANGE   HEX: 08
CONSTANT: VM_PROT_COPY        HEX: 10
CONSTANT: VM_PROT_WANTS_COPY  HEX: 10

! loader.h
STRUCT: mach_header
    { magic         uint32_t      }
    { cputype       cpu_type_t    }
    { cpusubtype    cpu_subtype_t }
    { filetype      uint32_t      }
    { ncmds         uint32_t      }
    { sizeofcmds    uint32_t      }
    { flags         uint32_t      } ;

CONSTANT: MH_MAGIC    HEX: feedface
CONSTANT: MH_CIGAM    HEX: cefaedfe

STRUCT: mach_header_64
    { magic         uint32_t      }
    { cputype       cpu_type_t    }
    { cpusubtype    cpu_subtype_t }
    { filetype      uint32_t      }
    { ncmds         uint32_t      }
    { sizeofcmds    uint32_t      }
    { flags         uint32_t      }
    { reserved      uint32_t      } ;

CONSTANT: MH_MAGIC_64 HEX: feedfacf
CONSTANT: MH_CIGAM_64 HEX: cffaedfe

CONSTANT: MH_OBJECT       HEX: 1
CONSTANT: MH_EXECUTE      HEX: 2
CONSTANT: MH_FVMLIB       HEX: 3
CONSTANT: MH_CORE         HEX: 4
CONSTANT: MH_PRELOAD      HEX: 5
CONSTANT: MH_DYLIB        HEX: 6
CONSTANT: MH_DYLINKER     HEX: 7
CONSTANT: MH_BUNDLE       HEX: 8
CONSTANT: MH_DYLIB_STUB   HEX: 9
CONSTANT: MH_DSYM         HEX: a
CONSTANT: MH_KEXT_BUNDLE  HEX: b

CONSTANT: MH_NOUNDEFS                HEX: 1
CONSTANT: MH_INCRLINK                HEX: 2
CONSTANT: MH_DYLDLINK                HEX: 4
CONSTANT: MH_BINDATLOAD              HEX: 8
CONSTANT: MH_PREBOUND                HEX: 10
CONSTANT: MH_SPLIT_SEGS              HEX: 20
CONSTANT: MH_LAZY_INIT               HEX: 40
CONSTANT: MH_TWOLEVEL                HEX: 80
CONSTANT: MH_FORCE_FLAT              HEX: 100
CONSTANT: MH_NOMULTIDEFS             HEX: 200
CONSTANT: MH_NOFIXPREBINDING         HEX: 400
CONSTANT: MH_PREBINDABLE             HEX: 800
CONSTANT: MH_ALLMODSBOUND            HEX: 1000
CONSTANT: MH_SUBSECTIONS_VIA_SYMBOLS HEX: 2000
CONSTANT: MH_CANONICAL               HEX: 4000
CONSTANT: MH_WEAK_DEFINES            HEX: 8000
CONSTANT: MH_BINDS_TO_WEAK           HEX: 10000
CONSTANT: MH_ALLOW_STACK_EXECUTION   HEX: 20000
CONSTANT: MH_DEAD_STRIPPABLE_DYLIB   HEX: 400000
CONSTANT: MH_ROOT_SAFE               HEX: 40000
CONSTANT: MH_SETUID_SAFE             HEX: 80000
CONSTANT: MH_NO_REEXPORTED_DYLIBS    HEX: 100000
CONSTANT: MH_PIE                     HEX: 200000

STRUCT: load_command
    { cmd     uint32_t }
    { cmdsize uint32_t } ;

CONSTANT: LC_REQ_DYLD HEX: 80000000

CONSTANT: LC_SEGMENT            HEX: 1
CONSTANT: LC_SYMTAB             HEX: 2
CONSTANT: LC_SYMSEG             HEX: 3
CONSTANT: LC_THREAD             HEX: 4
CONSTANT: LC_UNIXTHREAD         HEX: 5
CONSTANT: LC_LOADFVMLIB         HEX: 6
CONSTANT: LC_IDFVMLIB           HEX: 7
CONSTANT: LC_IDENT              HEX: 8
CONSTANT: LC_FVMFILE            HEX: 9
CONSTANT: LC_PREPAGE            HEX: a
CONSTANT: LC_DYSYMTAB           HEX: b
CONSTANT: LC_LOAD_DYLIB         HEX: c
CONSTANT: LC_ID_DYLIB           HEX: d
CONSTANT: LC_LOAD_DYLINKER      HEX: e
CONSTANT: LC_ID_DYLINKER        HEX: f
CONSTANT: LC_PREBOUND_DYLIB     HEX: 10
CONSTANT: LC_ROUTINES           HEX: 11
CONSTANT: LC_SUB_FRAMEWORK      HEX: 12
CONSTANT: LC_SUB_UMBRELLA       HEX: 13
CONSTANT: LC_SUB_CLIENT         HEX: 14
CONSTANT: LC_SUB_LIBRARY        HEX: 15
CONSTANT: LC_TWOLEVEL_HINTS     HEX: 16
CONSTANT: LC_PREBIND_CKSUM      HEX: 17
CONSTANT: LC_LOAD_WEAK_DYLIB    HEX: 80000018
CONSTANT: LC_SEGMENT_64         HEX: 19
CONSTANT: LC_ROUTINES_64        HEX: 1a
CONSTANT: LC_UUID               HEX: 1b
CONSTANT: LC_RPATH              HEX: 8000001c
CONSTANT: LC_CODE_SIGNATURE     HEX: 1d
CONSTANT: LC_SEGMENT_SPLIT_INFO HEX: 1e
CONSTANT: LC_REEXPORT_DYLIB     HEX: 8000001f
CONSTANT: LC_LAZY_LOAD_DYLIB    HEX: 20
CONSTANT: LC_ENCRYPTION_INFO    HEX: 21
CONSTANT: LC_DYLD_INFO          HEX: 22
CONSTANT: LC_DYLD_INFO_ONLY     HEX: 80000022

UNION-STRUCT: lc_str
    { offset    uint32_t }
    { ptr       char*    } ;

STRUCT: segment_command
    { cmd            uint32_t  }
    { cmdsize        uint32_t  }
    { segname        char[16]  }
    { vmaddr         uint32_t  }
    { vmsize         uint32_t  }
    { fileoff        uint32_t  }
    { filesize       uint32_t  }
    { maxprot        vm_prot_t }
    { initprot       vm_prot_t }
    { nsects         uint32_t  }
    { flags          uint32_t  } ;

STRUCT: segment_command_64
    { cmd            uint32_t  }
    { cmdsize        uint32_t  }
    { segname        char[16]  }
    { vmaddr         uint64_t  }
    { vmsize         uint64_t  }
    { fileoff        uint64_t  }
    { filesize       uint64_t  }
    { maxprot        vm_prot_t }
    { initprot       vm_prot_t }
    { nsects         uint32_t  }
    { flags          uint32_t  } ;

CONSTANT: SG_HIGHVM               HEX: 1
CONSTANT: SG_FVMLIB               HEX: 2
CONSTANT: SG_NORELOC              HEX: 4
CONSTANT: SG_PROTECTED_VERSION_1  HEX: 8

STRUCT: section
    { sectname        char[16] }
    { segname         char[16] }
    { addr            uint32_t }
    { size            uint32_t }
    { offset          uint32_t }
    { align           uint32_t }
    { reloff          uint32_t }
    { nreloc          uint32_t }
    { flags           uint32_t }
    { reserved1       uint32_t }
    { reserved2       uint32_t } ;

STRUCT: section_64
    { sectname        char[16] }
    { segname         char[16] }
    { addr            uint64_t }
    { size            uint64_t }
    { offset          uint32_t }
    { align           uint32_t }
    { reloff          uint32_t }
    { nreloc          uint32_t }
    { flags           uint32_t }
    { reserved1       uint32_t }
    { reserved2       uint32_t }
    { reserved3       uint32_t } ;

CONSTANT: SECTION_TYPE         HEX: 000000ff
CONSTANT: SECTION_ATTRIBUTES   HEX: ffffff00

CONSTANT: S_REGULAR                       HEX: 0
CONSTANT: S_ZEROFILL                      HEX: 1
CONSTANT: S_CSTRING_LITERALS              HEX: 2
CONSTANT: S_4BYTE_LITERALS                HEX: 3
CONSTANT: S_8BYTE_LITERALS                HEX: 4
CONSTANT: S_LITERAL_POINTERS              HEX: 5
CONSTANT: S_NON_LAZY_SYMBOL_POINTERS      HEX: 6
CONSTANT: S_LAZY_SYMBOL_POINTERS          HEX: 7
CONSTANT: S_SYMBOL_STUBS                  HEX: 8
CONSTANT: S_MOD_INIT_FUNC_POINTERS        HEX: 9
CONSTANT: S_MOD_TERM_FUNC_POINTERS        HEX: a
CONSTANT: S_COALESCED                     HEX: b
CONSTANT: S_GB_ZEROFILL                   HEX: c
CONSTANT: S_INTERPOSING                   HEX: d
CONSTANT: S_16BYTE_LITERALS               HEX: e
CONSTANT: S_DTRACE_DOF                    HEX: f
CONSTANT: S_LAZY_DYLIB_SYMBOL_POINTERS    HEX: 10

CONSTANT: SECTION_ATTRIBUTES_USR     HEX: ff000000
CONSTANT: S_ATTR_PURE_INSTRUCTIONS   HEX: 80000000
CONSTANT: S_ATTR_NO_TOC              HEX: 40000000
CONSTANT: S_ATTR_STRIP_STATIC_SYMS   HEX: 20000000
CONSTANT: S_ATTR_NO_DEAD_STRIP       HEX: 10000000
CONSTANT: S_ATTR_LIVE_SUPPORT        HEX: 08000000
CONSTANT: S_ATTR_SELF_MODIFYING_CODE HEX: 04000000
CONSTANT: S_ATTR_DEBUG               HEX: 02000000
CONSTANT: SECTION_ATTRIBUTES_SYS     HEX: 00ffff00
CONSTANT: S_ATTR_SOME_INSTRUCTIONS   HEX: 00000400
CONSTANT: S_ATTR_EXT_RELOC           HEX: 00000200
CONSTANT: S_ATTR_LOC_RELOC           HEX: 00000100

CONSTANT: SEG_PAGEZERO      "__PAGEZERO"
CONSTANT: SEG_TEXT          "__TEXT"
CONSTANT: SECT_TEXT         "__text"
CONSTANT: SECT_FVMLIB_INIT0 "__fvmlib_init0"
CONSTANT: SECT_FVMLIB_INIT1 "__fvmlib_init1"
CONSTANT: SEG_DATA          "__DATA"
CONSTANT: SECT_DATA         "__data"
CONSTANT: SECT_BSS          "__bss"
CONSTANT: SECT_COMMON       "__common"
CONSTANT: SEG_OBJC          "__OBJC"
CONSTANT: SECT_OBJC_SYMBOLS "__symbol_table"
CONSTANT: SECT_OBJC_MODULES "__module_info"
CONSTANT: SECT_OBJC_STRINGS "__selector_strs"
CONSTANT: SECT_OBJC_REFS    "__selector_refs"
CONSTANT: SEG_ICON          "__ICON"
CONSTANT: SECT_ICON_HEADER  "__header"
CONSTANT: SECT_ICON_TIFF    "__tiff"
CONSTANT: SEG_LINKEDIT      "__LINKEDIT"
CONSTANT: SEG_UNIXSTACK     "__UNIXSTACK"
CONSTANT: SEG_IMPORT        "__IMPORT"

STRUCT: fvmlib
    { name             lc_str   }
    { minor_version    uint32_t }
    { header_addr      uint32_t } ;

STRUCT: fvmlib_command
    { cmd        uint32_t }
    { cmdsize    uint32_t }
    { fvmlib     fvmlib   } ;

STRUCT: dylib
    { name                  lc_str   }
    { timestamp             uint32_t }
    { current_version       uint32_t }
    { compatibility_version uint32_t } ;

STRUCT: dylib_command
    { cmd        uint32_t }
    { cmdsize    uint32_t }
    { dylib      dylib    } ;

STRUCT: sub_framework_command
    { cmd         uint32_t }
    { cmdsize     uint32_t }
    { umbrella    lc_str   } ;

STRUCT: sub_client_command
    { cmd        uint32_t }
    { cmdsize    uint32_t }
    { client     lc_str   } ;

STRUCT: sub_umbrella_command
    { cmd             uint32_t }
    { cmdsize         uint32_t }
    { sub_umbrella    lc_str   } ;

STRUCT: sub_library_command
    { cmd            uint32_t }
    { cmdsize        uint32_t }
    { sub_library    lc_str   } ;

STRUCT: prebound_dylib_command
    { cmd               uint32_t }
    { cmdsize           uint32_t }
    { name              lc_str   }
    { nmodules          uint32_t }
    { linked_modules    lc_str   } ;

STRUCT: dylinker_command
    { cmd        uint32_t }
    { cmdsize    uint32_t }
    { name       lc_str   } ;

STRUCT: thread_command
    { cmd        uint32_t }
    { cmdsize    uint32_t } ;

STRUCT: routines_command
    { cmd             uint32_t }
    { cmdsize         uint32_t }
    { init_address    uint32_t }
    { init_module     uint32_t }
    { reserved1       uint32_t }
    { reserved2       uint32_t }
    { reserved3       uint32_t }
    { reserved4       uint32_t }
    { reserved5       uint32_t }
    { reserved6       uint32_t } ;

STRUCT: routines_command_64
    { cmd             uint32_t }
    { cmdsize         uint32_t }
    { init_address    uint64_t }
    { init_module     uint64_t }
    { reserved1       uint64_t }
    { reserved2       uint64_t }
    { reserved3       uint64_t }
    { reserved4       uint64_t }
    { reserved5       uint64_t }
    { reserved6       uint64_t } ;

STRUCT: symtab_command
    { cmd        uint32_t }
    { cmdsize    uint32_t }
    { symoff     uint32_t }
    { nsyms      uint32_t }
    { stroff     uint32_t }
    { strsize    uint32_t } ;

STRUCT: dysymtab_command
    { cmd            uint32_t }
    { cmdsize        uint32_t }
    { ilocalsym      uint32_t }
    { nlocalsym      uint32_t }
    { iextdefsym     uint32_t }
    { nextdefsym     uint32_t }
    { iundefsym      uint32_t }
    { nundefsym      uint32_t }
    { tocoff         uint32_t }
    { ntoc           uint32_t }
    { modtaboff      uint32_t }
    { nmodtab        uint32_t }
    { extrefsymoff   uint32_t }
    { nextrefsyms    uint32_t }
    { indirectsymoff uint32_t }
    { nindirectsyms  uint32_t }
    { extreloff      uint32_t }
    { nextrel        uint32_t }
    { locreloff      uint32_t }
    { nlocrel        uint32_t } ;

CONSTANT: INDIRECT_SYMBOL_LOCAL HEX: 80000000
CONSTANT: INDIRECT_SYMBOL_ABS   HEX: 40000000

STRUCT: dylib_table_of_contents
    { symbol_index uint32_t }
    { module_index uint32_t } ;

STRUCT: dylib_module
    { module_name           uint32_t }
    { iextdefsym            uint32_t }
    { nextdefsym            uint32_t }
    { irefsym               uint32_t }
    { nrefsym               uint32_t }
    { ilocalsym             uint32_t }
    { nlocalsym             uint32_t }
    { iextrel               uint32_t }
    { nextrel               uint32_t }
    { iinit_iterm           uint32_t }
    { ninit_nterm           uint32_t }
    { objc_module_info_addr uint32_t }
    { objc_module_info_size uint32_t } ;

STRUCT: dylib_module_64
    { module_name           uint32_t }
    { iextdefsym            uint32_t }
    { nextdefsym            uint32_t }
    { irefsym               uint32_t }
    { nrefsym               uint32_t }
    { ilocalsym             uint32_t }
    { nlocalsym             uint32_t }
    { iextrel               uint32_t }
    { nextrel               uint32_t }
    { iinit_iterm           uint32_t }
    { ninit_nterm           uint32_t }
    { objc_module_info_size uint32_t }
    { objc_module_info_addr uint64_t } ;

STRUCT: dylib_reference
    { isym_flags uint32_t } ;

STRUCT: twolevel_hints_command
    { cmd     uint32_t }
    { cmdsize uint32_t }
    { offset  uint32_t }
    { nhints  uint32_t } ;

STRUCT: twolevel_hint
    { isub_image_itoc uint32_t } ;

STRUCT: prebind_cksum_command
    { cmd     uint32_t }
    { cmdsize uint32_t }
    { cksum   uint32_t } ;

STRUCT: uuid_command
    { cmd        uint32_t    }
    { cmdsize    uint32_t    }
    { uuid       uint8_t[16] } ;

STRUCT: rpath_command
    { cmd         uint32_t }
    { cmdsize     uint32_t }
    { path        lc_str   } ;

STRUCT: linkedit_data_command
    { cmd         uint32_t }
    { cmdsize     uint32_t }
    { dataoff     uint32_t }
    { datasize    uint32_t } ;

STRUCT: encryption_info_command
    { cmd       uint32_t }
    { cmdsize   uint32_t }
    { cryptoff  uint32_t }
    { cryptsize uint32_t }
    { cryptid   uint32_t } ;

STRUCT: dyld_info_command
    { cmd              uint32_t }
    { cmdsize          uint32_t }
    { rebase_off       uint32_t }
    { rebase_size      uint32_t }
    { bind_off         uint32_t }
    { bind_size        uint32_t }
    { weak_bind_off    uint32_t }
    { weak_bind_size   uint32_t }
    { lazy_bind_off    uint32_t }
    { lazy_bind_size   uint32_t }
    { export_off       uint32_t }
    { export_size      uint32_t } ;

CONSTANT: REBASE_TYPE_POINTER                     1
CONSTANT: REBASE_TYPE_TEXT_ABSOLUTE32             2
CONSTANT: REBASE_TYPE_TEXT_PCREL32                3

CONSTANT: REBASE_OPCODE_MASK                                  HEX: F0
CONSTANT: REBASE_IMMEDIATE_MASK                               HEX: 0F
CONSTANT: REBASE_OPCODE_DONE                                  HEX: 00
CONSTANT: REBASE_OPCODE_SET_TYPE_IMM                          HEX: 10
CONSTANT: REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB           HEX: 20
CONSTANT: REBASE_OPCODE_ADD_ADDR_ULEB                         HEX: 30
CONSTANT: REBASE_OPCODE_ADD_ADDR_IMM_SCALED                   HEX: 40
CONSTANT: REBASE_OPCODE_DO_REBASE_IMM_TIMES                   HEX: 50
CONSTANT: REBASE_OPCODE_DO_REBASE_ULEB_TIMES                  HEX: 60
CONSTANT: REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB               HEX: 70
CONSTANT: REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB    HEX: 80

CONSTANT: BIND_TYPE_POINTER                       1
CONSTANT: BIND_TYPE_TEXT_ABSOLUTE32               2
CONSTANT: BIND_TYPE_TEXT_PCREL32                  3

CONSTANT: BIND_SPECIAL_DYLIB_SELF                     0
CONSTANT: BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE          -1
CONSTANT: BIND_SPECIAL_DYLIB_FLAT_LOOKUP              -2

CONSTANT: BIND_SYMBOL_FLAGS_WEAK_IMPORT                   HEX: 1
CONSTANT: BIND_SYMBOL_FLAGS_NON_WEAK_DEFINITION           HEX: 8

CONSTANT: BIND_OPCODE_MASK                                    HEX: F0
CONSTANT: BIND_IMMEDIATE_MASK                                 HEX: 0F
CONSTANT: BIND_OPCODE_DONE                                    HEX: 00
CONSTANT: BIND_OPCODE_SET_DYLIB_ORDINAL_IMM                   HEX: 10
CONSTANT: BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB                  HEX: 20
CONSTANT: BIND_OPCODE_SET_DYLIB_SPECIAL_IMM                   HEX: 30
CONSTANT: BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM           HEX: 40
CONSTANT: BIND_OPCODE_SET_TYPE_IMM                            HEX: 50
CONSTANT: BIND_OPCODE_SET_ADDEND_SLEB                         HEX: 60
CONSTANT: BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB             HEX: 70
CONSTANT: BIND_OPCODE_ADD_ADDR_ULEB                           HEX: 80
CONSTANT: BIND_OPCODE_DO_BIND                                 HEX: 90
CONSTANT: BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB                   HEX: A0
CONSTANT: BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED             HEX: B0
CONSTANT: BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB        HEX: C0

CONSTANT: EXPORT_SYMBOL_FLAGS_KIND_MASK                   HEX: 03
CONSTANT: EXPORT_SYMBOL_FLAGS_KIND_REGULAR                HEX: 00
CONSTANT: EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL           HEX: 01
CONSTANT: EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION             HEX: 04
CONSTANT: EXPORT_SYMBOL_FLAGS_INDIRECT_DEFINITION         HEX: 08
CONSTANT: EXPORT_SYMBOL_FLAGS_HAS_SPECIALIZATIONS         HEX: 10

STRUCT: symseg_command
    { cmd        uint32_t }
    { cmdsize    uint32_t }
    { offset     uint32_t }
    { size       uint32_t } ;

STRUCT: ident_command
    { cmd     uint32_t }
    { cmdsize uint32_t } ;

STRUCT: fvmfile_command
    { cmd            uint32_t }
    { cmdsize        uint32_t }
    { name           lc_str   }
    { header_addr    uint32_t } ;

! machine.h
CONSTANT: CPU_STATE_MAX       4
CONSTANT: CPU_STATE_USER      0
CONSTANT: CPU_STATE_SYSTEM    1
CONSTANT: CPU_STATE_IDLE      2
CONSTANT: CPU_STATE_NICE      3

CONSTANT: CPU_ARCH_MASK   HEX: ff000000
CONSTANT: CPU_ARCH_ABI64  HEX: 01000000

CONSTANT: CPU_TYPE_ANY            -1
CONSTANT: CPU_TYPE_VAX            1
CONSTANT: CPU_TYPE_MC680x0        6
CONSTANT: CPU_TYPE_X86            7
ALIAS: CPU_TYPE_I386              CPU_TYPE_X86
CONSTANT: CPU_TYPE_X86_64         flags{ CPU_TYPE_X86 CPU_ARCH_ABI64 }
CONSTANT: CPU_TYPE_MC98000        10
CONSTANT: CPU_TYPE_HPPA           11
CONSTANT: CPU_TYPE_ARM            12
CONSTANT: CPU_TYPE_MC88000        13
CONSTANT: CPU_TYPE_SPARC          14
CONSTANT: CPU_TYPE_I860           15
CONSTANT: CPU_TYPE_POWERPC        18
CONSTANT: CPU_TYPE_POWERPC64      flags{ CPU_TYPE_POWERPC CPU_ARCH_ABI64 }

CONSTANT: CPU_SUBTYPE_MASK    HEX: ff000000
CONSTANT: CPU_SUBTYPE_LIB64   HEX: 80000000

CONSTANT: CPU_SUBTYPE_MULTIPLE        -1
CONSTANT: CPU_SUBTYPE_LITTLE_ENDIAN   0
CONSTANT: CPU_SUBTYPE_BIG_ENDIAN      1

CONSTANT: CPU_THREADTYPE_NONE     0

CONSTANT: CPU_SUBTYPE_VAX_ALL 0
CONSTANT: CPU_SUBTYPE_VAX780  1
CONSTANT: CPU_SUBTYPE_VAX785  2
CONSTANT: CPU_SUBTYPE_VAX750  3
CONSTANT: CPU_SUBTYPE_VAX730  4
CONSTANT: CPU_SUBTYPE_UVAXI   5
CONSTANT: CPU_SUBTYPE_UVAXII  6
CONSTANT: CPU_SUBTYPE_VAX8200 7
CONSTANT: CPU_SUBTYPE_VAX8500 8
CONSTANT: CPU_SUBTYPE_VAX8600 9
CONSTANT: CPU_SUBTYPE_VAX8650 10
CONSTANT: CPU_SUBTYPE_VAX8800 11
CONSTANT: CPU_SUBTYPE_UVAXIII 12

CONSTANT: CPU_SUBTYPE_MC680x0_ALL     1
CONSTANT: CPU_SUBTYPE_MC68030     1
CONSTANT: CPU_SUBTYPE_MC68040     2
CONSTANT: CPU_SUBTYPE_MC68030_ONLY    3

: CPU_SUBTYPE_INTEL ( f m -- subtype ) 4 shift + ; inline

CONSTANT: CPU_SUBTYPE_I386_ALL              3
CONSTANT: CPU_SUBTYPE_386                   3
CONSTANT: CPU_SUBTYPE_486                   4
CONSTANT: CPU_SUBTYPE_486SX                 132
CONSTANT: CPU_SUBTYPE_586                   5
CONSTANT: CPU_SUBTYPE_PENT                  5
CONSTANT: CPU_SUBTYPE_PENTPRO               22
CONSTANT: CPU_SUBTYPE_PENTII_M3             54
CONSTANT: CPU_SUBTYPE_PENTII_M5             86
CONSTANT: CPU_SUBTYPE_CELERON               103
CONSTANT: CPU_SUBTYPE_CELERON_MOBILE        119
CONSTANT: CPU_SUBTYPE_PENTIUM_3             8
CONSTANT: CPU_SUBTYPE_PENTIUM_3_M           24
CONSTANT: CPU_SUBTYPE_PENTIUM_3_XEON        40
CONSTANT: CPU_SUBTYPE_PENTIUM_M             9
CONSTANT: CPU_SUBTYPE_PENTIUM_4             10
CONSTANT: CPU_SUBTYPE_PENTIUM_4_M           26
CONSTANT: CPU_SUBTYPE_ITANIUM               11
CONSTANT: CPU_SUBTYPE_ITANIUM_2             27
CONSTANT: CPU_SUBTYPE_XEON                  12
CONSTANT: CPU_SUBTYPE_XEON_MP               28

: CPU_SUBTYPE_INTEL_FAMILY ( x -- family ) 15 bitand ; inline

CONSTANT: CPU_SUBTYPE_INTEL_FAMILY_MAX    15

: CPU_SUBTYPE_INTEL_MODEL ( x -- model ) -4 shift ; inline

CONSTANT: CPU_SUBTYPE_INTEL_MODEL_ALL 0
CONSTANT: CPU_SUBTYPE_X86_ALL         3
CONSTANT: CPU_SUBTYPE_X86_64_ALL      3
CONSTANT: CPU_SUBTYPE_X86_ARCH1       4
CONSTANT: CPU_THREADTYPE_INTEL_HTT    1

CONSTANT: CPU_SUBTYPE_MIPS_ALL    0
CONSTANT: CPU_SUBTYPE_MIPS_R2300  1
CONSTANT: CPU_SUBTYPE_MIPS_R2600  2
CONSTANT: CPU_SUBTYPE_MIPS_R2800  3
CONSTANT: CPU_SUBTYPE_MIPS_R2000a 4
CONSTANT: CPU_SUBTYPE_MIPS_R2000  5
CONSTANT: CPU_SUBTYPE_MIPS_R3000a 6
CONSTANT: CPU_SUBTYPE_MIPS_R3000  7

CONSTANT: CPU_SUBTYPE_MC98000_ALL 0
CONSTANT: CPU_SUBTYPE_MC98601     1

CONSTANT: CPU_SUBTYPE_HPPA_ALL        0
CONSTANT: CPU_SUBTYPE_HPPA_7100       0
CONSTANT: CPU_SUBTYPE_HPPA_7100LC     1

CONSTANT: CPU_SUBTYPE_MC88000_ALL 0
CONSTANT: CPU_SUBTYPE_MC88100     1
CONSTANT: CPU_SUBTYPE_MC88110     2

CONSTANT: CPU_SUBTYPE_SPARC_ALL       0

CONSTANT: CPU_SUBTYPE_I860_ALL    0
CONSTANT: CPU_SUBTYPE_I860_860    1

CONSTANT: CPU_SUBTYPE_POWERPC_ALL     0
CONSTANT: CPU_SUBTYPE_POWERPC_601     1
CONSTANT: CPU_SUBTYPE_POWERPC_602     2
CONSTANT: CPU_SUBTYPE_POWERPC_603     3
CONSTANT: CPU_SUBTYPE_POWERPC_603e    4
CONSTANT: CPU_SUBTYPE_POWERPC_603ev   5
CONSTANT: CPU_SUBTYPE_POWERPC_604     6
CONSTANT: CPU_SUBTYPE_POWERPC_604e    7
CONSTANT: CPU_SUBTYPE_POWERPC_620     8
CONSTANT: CPU_SUBTYPE_POWERPC_750     9
CONSTANT: CPU_SUBTYPE_POWERPC_7400    10
CONSTANT: CPU_SUBTYPE_POWERPC_7450    11
CONSTANT: CPU_SUBTYPE_POWERPC_970     100

CONSTANT: CPU_SUBTYPE_ARM_ALL             0
CONSTANT: CPU_SUBTYPE_ARM_V4T             5
CONSTANT: CPU_SUBTYPE_ARM_V6              6
CONSTANT: CPU_SUBTYPE_ARM_V5TEJ           7
CONSTANT: CPU_SUBTYPE_ARM_XSCALE          8
CONSTANT: CPU_SUBTYPE_ARM_V7              9

CONSTANT: CPUFAMILY_UNKNOWN    0
CONSTANT: CPUFAMILY_POWERPC_G3 HEX: cee41549
CONSTANT: CPUFAMILY_POWERPC_G4 HEX: 77c184ae
CONSTANT: CPUFAMILY_POWERPC_G5 HEX: ed76d8aa
CONSTANT: CPUFAMILY_INTEL_6_13 HEX: aa33392b
CONSTANT: CPUFAMILY_INTEL_6_14 HEX: 73d67300
CONSTANT: CPUFAMILY_INTEL_6_15 HEX: 426f69ef
CONSTANT: CPUFAMILY_INTEL_6_23 HEX: 78ea4fbc
CONSTANT: CPUFAMILY_INTEL_6_26 HEX: 6b5a4cd2
CONSTANT: CPUFAMILY_ARM_9      HEX: e73283ae
CONSTANT: CPUFAMILY_ARM_11     HEX: 8ff620d8
CONSTANT: CPUFAMILY_ARM_XSCALE HEX: 53b005f5
CONSTANT: CPUFAMILY_ARM_13     HEX: 0cc90e64

ALIAS: CPUFAMILY_INTEL_YONAH   CPUFAMILY_INTEL_6_14
ALIAS: CPUFAMILY_INTEL_MEROM   CPUFAMILY_INTEL_6_15
ALIAS: CPUFAMILY_INTEL_PENRYN  CPUFAMILY_INTEL_6_23
ALIAS: CPUFAMILY_INTEL_NEHALEM CPUFAMILY_INTEL_6_26

ALIAS: CPUFAMILY_INTEL_CORE    CPUFAMILY_INTEL_6_14
ALIAS: CPUFAMILY_INTEL_CORE2   CPUFAMILY_INTEL_6_15

! fat.h
CONSTANT: FAT_MAGIC HEX: cafebabe
CONSTANT: FAT_CIGAM HEX: bebafeca

STRUCT: fat_header
    { magic        uint32_t }
    { nfat_arch    uint32_t } ;

STRUCT: fat_arch
    { cputype      cpu_type_t    }
    { cpusubtype   cpu_subtype_t }
    { offset       uint32_t      }
    { size         uint32_t      }
    { align        uint32_t      } ;

! nlist.h
STRUCT: nlist
    { n_strx  int32_t  }
    { n_type  uint8_t  }
    { n_sect  uint8_t  }
    { n_desc  int16_t  }
    { n_value uint32_t } ;

STRUCT: nlist_64
    { n_strx  uint32_t }
    { n_type  uint8_t  }
    { n_sect  uint8_t  }
    { n_desc  uint16_t }
    { n_value uint64_t } ;

CONSTANT: N_STAB  HEX: e0
CONSTANT: N_PEXT  HEX: 10
CONSTANT: N_TYPE  HEX: 0e
CONSTANT: N_EXT   HEX: 01

CONSTANT: N_UNDF  HEX: 0
CONSTANT: N_ABS   HEX: 2
CONSTANT: N_SECT  HEX: e
CONSTANT: N_PBUD  HEX: c
CONSTANT: N_INDR  HEX: a

CONSTANT: NO_SECT     0
CONSTANT: MAX_SECT    255

: GET_COMM_ALIGN ( n_desc -- align )
    -8 shift HEX: 0f bitand ; inline

: SET_COMM_ALIGN ( n_desc align -- n_desc )
    [ HEX: f0ff bitand ]
    [ HEX: 000f bitand 8 shift ] bi* bitor ; inline

CONSTANT: REFERENCE_TYPE                              7
CONSTANT: REFERENCE_FLAG_UNDEFINED_NON_LAZY           0
CONSTANT: REFERENCE_FLAG_UNDEFINED_LAZY               1
CONSTANT: REFERENCE_FLAG_DEFINED                      2
CONSTANT: REFERENCE_FLAG_PRIVATE_DEFINED              3
CONSTANT: REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY   4
CONSTANT: REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY       5

CONSTANT: REFERENCED_DYNAMICALLY  HEX: 0010

: GET_LIBRARY_ORDINAL ( n_desc -- ordinal )
    -8 shift HEX: ff bitand ; inline

: SET_LIBRARY_ORDINAL ( n_desc ordinal -- n_desc )
    [ HEX: 00ff bitand ]
    [ HEX: 00ff bitand 8 shift ] bi* bitor ; inline

CONSTANT: SELF_LIBRARY_ORDINAL   HEX: 0
CONSTANT: MAX_LIBRARY_ORDINAL    HEX: fd
CONSTANT: DYNAMIC_LOOKUP_ORDINAL HEX: fe
CONSTANT: EXECUTABLE_ORDINAL     HEX: ff

CONSTANT: N_NO_DEAD_STRIP  HEX: 0020
CONSTANT: N_DESC_DISCARDED HEX: 0020
CONSTANT: N_WEAK_REF       HEX: 0040
CONSTANT: N_WEAK_DEF       HEX: 0080
CONSTANT: N_REF_TO_WEAK    HEX: 0080
CONSTANT: N_ARM_THUMB_DEF  HEX: 0008

! ranlib.h
CONSTANT: SYMDEF        "__.SYMDEF"
CONSTANT: SYMDEF_SORTED "__.SYMDEF SORTED"

STRUCT: ranlib
    { ran_strx uint32_t }
    { ran_off  uint32_t } ;

! reloc.h
STRUCT: relocation_info
    { r_address                            int32_t  }
    { r_symbolnum_pcrel_length_extern_type uint32_t } ;

CONSTANT: R_ABS   0
CONSTANT: R_SCATTERED HEX: 80000000

STRUCT: scattered_relocation_info_big_endian
    { r_scattered_pcrel_length_type_address  uint32_t }
    { r_value                                int32_t  } ;

STRUCT: scattered_relocation_info_little_endian
    { r_address_type_length_pcrel_scattered uint32_t }
    { r_value                               int32_t  } ;

C-ENUM: reloc_type_generic
    GENERIC_RELOC_VANILLA
    GENERIC_RELOC_PAIR
    GENERIC_RELOC_SECTDIFF
    GENERIC_RELOC_PB_LA_PTR
    GENERIC_RELOC_LOCAL_SECTDIFF ;

C-ENUM: reloc_type_x86_64
    X86_64_RELOC_UNSIGNED
    X86_64_RELOC_SIGNED
    X86_64_RELOC_BRANCH
    X86_64_RELOC_GOT_LOAD
    X86_64_RELOC_GOT
    X86_64_RELOC_SUBTRACTOR
    X86_64_RELOC_SIGNED_1
    X86_64_RELOC_SIGNED_2
    X86_64_RELOC_SIGNED_4 ;

C-ENUM: reloc_type_ppc
    PPC_RELOC_VANILLA
    PPC_RELOC_PAIR
    PPC_RELOC_BR14
    PPC_RELOC_BR24
    PPC_RELOC_HI16
    PPC_RELOC_LO16
    PPC_RELOC_HA16
    PPC_RELOC_LO14
    PPC_RELOC_SECTDIFF
    PPC_RELOC_PB_LA_PTR
    PPC_RELOC_HI16_SECTDIFF
    PPC_RELOC_LO16_SECTDIFF
    PPC_RELOC_HA16_SECTDIFF
    PPC_RELOC_JBSR
    PPC_RELOC_LO14_SECTDIFF
    PPC_RELOC_LOCAL_SECTDIFF ;
