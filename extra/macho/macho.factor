! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
alien.syntax classes classes.struct combinators
combinators.short-circuit io.encodings.ascii io.encodings.string
kernel literals make math sequences specialized-arrays typed
io.mmap formatting splitting endian ;
IN: macho

! FFI data
TYPEDEF: int       integer_t
TYPEDEF: int       vm_prot_t
TYPEDEF: integer_t cpu_type_t
TYPEDEF: integer_t cpu_subtype_t
TYPEDEF: integer_t cpu_threadtype_t

CONSTANT: VM_PROT_NONE        0x00
CONSTANT: VM_PROT_READ        0x01
CONSTANT: VM_PROT_WRITE       0x02
CONSTANT: VM_PROT_EXECUTE     0x04
CONSTANT: VM_PROT_DEFAULT     0x03
CONSTANT: VM_PROT_ALL         0x07
CONSTANT: VM_PROT_NO_CHANGE   0x08
CONSTANT: VM_PROT_COPY        0x10
CONSTANT: VM_PROT_WANTS_COPY  0x10

! loader.h
STRUCT: mach_header
    { magic         uint          }
    { cputype       cpu_type_t    }
    { cpusubtype    cpu_subtype_t }
    { filetype      uint          }
    { ncmds         uint          }
    { sizeofcmds    uint          }
    { flags         uint          } ;

CONSTANT: MH_MAGIC    0xfeedface
CONSTANT: MH_CIGAM    0xcefaedfe

STRUCT: mach_header_64
    { magic         uint          }
    { cputype       cpu_type_t    }
    { cpusubtype    cpu_subtype_t }
    { filetype      uint          }
    { ncmds         uint          }
    { sizeofcmds    uint          }
    { flags         uint          }
    { reserved      uint          } ;

CONSTANT: MH_MAGIC_64 0xfeedfacf
CONSTANT: MH_CIGAM_64 0xcffaedfe

CONSTANT: MH_OBJECT       0x1
CONSTANT: MH_EXECUTE      0x2
CONSTANT: MH_FVMLIB       0x3
CONSTANT: MH_CORE         0x4
CONSTANT: MH_PRELOAD      0x5
CONSTANT: MH_DYLIB        0x6
CONSTANT: MH_DYLINKER     0x7
CONSTANT: MH_BUNDLE       0x8
CONSTANT: MH_DYLIB_STUB   0x9
CONSTANT: MH_DSYM         0xa
CONSTANT: MH_KEXT_BUNDLE  0xb
CONSTANT: MH_FILESET      0xc
CONSTANT: MH_GPU_EXECUTE  0xd
CONSTANT: MH_GPU_DYLIB    0xe

CONSTANT: MH_NOUNDEFS                0x1
CONSTANT: MH_INCRLINK                0x2
CONSTANT: MH_DYLDLINK                0x4
CONSTANT: MH_BINDATLOAD              0x8
CONSTANT: MH_PREBOUND                0x10
CONSTANT: MH_SPLIT_SEGS              0x20
CONSTANT: MH_LAZY_INIT               0x40
CONSTANT: MH_TWOLEVEL                0x80
CONSTANT: MH_FORCE_FLAT              0x100
CONSTANT: MH_NOMULTIDEFS             0x200
CONSTANT: MH_NOFIXPREBINDING         0x400
CONSTANT: MH_PREBINDABLE             0x800
CONSTANT: MH_ALLMODSBOUND            0x1000
CONSTANT: MH_SUBSECTIONS_VIA_SYMBOLS 0x2000
CONSTANT: MH_CANONICAL               0x4000
CONSTANT: MH_WEAK_DEFINES            0x8000
CONSTANT: MH_BINDS_TO_WEAK           0x10000
CONSTANT: MH_ALLOW_STACK_EXECUTION   0x20000
CONSTANT: MH_ROOT_SAFE               0x40000
CONSTANT: MH_SETUID_SAFE             0x80000
CONSTANT: MH_NO_REEXPORTED_DYLIBS    0x100000
CONSTANT: MH_PIE                     0x200000
CONSTANT: MH_DEAD_STRIPPABLE_DYLIB   0x400000
CONSTANT: MH_HAS_TLV_DESCRIPTORS     0x800000
CONSTANT: MH_NO_HEAP_EXECUTION       0x1000000
CONSTANT: MH_APP_EXTENSION_SAFE      0x2000000
CONSTANT: MH_NLIST_OUTOFSYNC_WITH_DYLDINFO 0x4000000
CONSTANT: MH_SIM_SUPPORT             0x8000000
CONSTANT: MH_DYLIB_IN_CACHE          0x80000000

STRUCT: load_command
    { cmd     uint }
    { cmdsize uint } ;

CONSTANT: LC_REQ_DYLD 0x80000000

CONSTANT: LC_SEGMENT             0x1
CONSTANT: LC_SYMTAB              0x2
CONSTANT: LC_SYMSEG              0x3
CONSTANT: LC_THREAD              0x4
CONSTANT: LC_UNIXTHREAD          0x5
CONSTANT: LC_LOADFVMLIB          0x6
CONSTANT: LC_IDFVMLIB            0x7
CONSTANT: LC_IDENT               0x8
CONSTANT: LC_FVMFILE             0x9
CONSTANT: LC_PREPAGE             0xa
CONSTANT: LC_DYSYMTAB            0xb
CONSTANT: LC_LOAD_DYLIB          0xc
CONSTANT: LC_ID_DYLIB            0xd
CONSTANT: LC_LOAD_DYLINKER       0xe
CONSTANT: LC_ID_DYLINKER         0xf
CONSTANT: LC_PREBOUND_DYLIB      0x10
CONSTANT: LC_ROUTINES            0x11
CONSTANT: LC_SUB_FRAMEWORK       0x12
CONSTANT: LC_SUB_UMBRELLA        0x13
CONSTANT: LC_SUB_CLIENT          0x14
CONSTANT: LC_SUB_LIBRARY         0x15
CONSTANT: LC_TWOLEVEL_HINTS      0x16
CONSTANT: LC_PREBIND_CKSUM       0x17
CONSTANT: LC_LOAD_WEAK_DYLIB     0x80000018
CONSTANT: LC_SEGMENT_64          0x19
CONSTANT: LC_ROUTINES_64         0x1a
CONSTANT: LC_UUID                0x1b
CONSTANT: LC_RPATH               0x8000001c
CONSTANT: LC_CODE_SIGNATURE      0x1d
CONSTANT: LC_SEGMENT_SPLIT_INFO  0x1e
CONSTANT: LC_REEXPORT_DYLIB      0x8000001f
CONSTANT: LC_LAZY_LOAD_DYLIB     0x20
CONSTANT: LC_ENCRYPTION_INFO     0x21
CONSTANT: LC_DYLD_INFO           0x22
CONSTANT: LC_DYLD_INFO_ONLY      0x80000022
CONSTANT: LC_LOAD_UPWARD_DYLIB   0x80000023
CONSTANT: LC_VERSION_MIN_MACOSX  0x24
CONSTANT: LC_VERSION_MIN_IPHONEOS 0x25
CONSTANT: LC_FUNCTION_STARTS     0x26
CONSTANT: LC_DYLD_ENVIRONMENT    0x27
CONSTANT: LC_MAIN                0x80000028
CONSTANT: LC_DATA_IN_CODE        0x29
CONSTANT: LC_SOURCE_VERSION      0x2A
CONSTANT: LC_DYLIB_CODE_SIGN_DRS 0x2B
CONSTANT: LC_ENCRYPTION_INFO_64  0x2C
CONSTANT: LC_LINKER_OPTION       0x2D
CONSTANT: LC_LINKER_OPTIMIZATION_HINT 0x2E
CONSTANT: LC_VERSION_MIN_TVOS    0x2F
CONSTANT: LC_VERSION_MIN_WATCHOS 0x30
CONSTANT: LC_NOTE                0x31
CONSTANT: LC_BUILD_VERSION       0x32
CONSTANT: LC_DYLD_EXPORTS_TRIE   0x80000033
CONSTANT: LC_DYLD_CHAINED_FIXUPS 0x80000034
CONSTANT: LC_FILESET_ENTRY       0x80000035
CONSTANT: LC_ATOM_INFO           0x36

UNION-STRUCT: lc_str
    { offset    uint     }
    { ptr       char*    } ;

STRUCT: segment_command
    { cmd            uint      }
    { cmdsize        uint      }
    { segname        char[16]  }
    { vmaddr         uint      }
    { vmsize         uint      }
    { fileoff        uint      }
    { filesize       uint      }
    { maxprot        vm_prot_t }
    { initprot       vm_prot_t }
    { nsects         uint      }
    { flags          uint      } ;

STRUCT: segment_command_64
    { cmd            uint       }
    { cmdsize        uint       }
    { segname        char[16]   }
    { vmaddr         ulonglong  }
    { vmsize         ulonglong  }
    { fileoff        ulonglong  }
    { filesize       ulonglong  }
    { maxprot        vm_prot_t  }
    { initprot       vm_prot_t  }
    { nsects         uint       }
    { flags          uint       } ;

CONSTANT: SG_HIGHVM               0x1
CONSTANT: SG_FVMLIB               0x2
CONSTANT: SG_NORELOC              0x4
CONSTANT: SG_PROTECTED_VERSION_1  0x8
CONSTANT: SG_READ_ONLY            0x10

STRUCT: section
    { sectname        char[16] }
    { segname         char[16] }
    { addr            uint     }
    { size            uint     }
    { offset          uint     }
    { align           uint     }
    { reloff          uint     }
    { nreloc          uint     }
    { flags           uint     }
    { reserved1       uint     }
    { reserved2       uint     } ;

STRUCT: section_64
    { sectname        char[16]  }
    { segname         char[16]  }
    { addr            ulonglong }
    { size            ulonglong }
    { offset          uint      }
    { align           uint      }
    { reloff          uint      }
    { nreloc          uint      }
    { flags           uint      }
    { reserved1       uint      }
    { reserved2       uint      }
    { reserved3       uint      } ;

CONSTANT: SECTION_TYPE         0x000000ff
CONSTANT: SECTION_ATTRIBUTES   0xffffff00

CONSTANT: S_REGULAR                       0x0
CONSTANT: S_ZEROFILL                      0x1
CONSTANT: S_CSTRING_LITERALS              0x2
CONSTANT: S_4BYTE_LITERALS                0x3
CONSTANT: S_8BYTE_LITERALS                0x4
CONSTANT: S_LITERAL_POINTERS              0x5
CONSTANT: S_NON_LAZY_SYMBOL_POINTERS      0x6
CONSTANT: S_LAZY_SYMBOL_POINTERS          0x7
CONSTANT: S_SYMBOL_STUBS                  0x8
CONSTANT: S_MOD_INIT_FUNC_POINTERS        0x9
CONSTANT: S_MOD_TERM_FUNC_POINTERS        0xa
CONSTANT: S_COALESCED                     0xb
CONSTANT: S_GB_ZEROFILL                   0xc
CONSTANT: S_INTERPOSING                   0xd
CONSTANT: S_16BYTE_LITERALS               0xe
CONSTANT: S_DTRACE_DOF                    0xf
CONSTANT: S_LAZY_DYLIB_SYMBOL_POINTERS    0x10
CONSTANT: S_THREAD_LOCAL_REGULAR          0x11
CONSTANT: S_THREAD_LOCAL_ZEROFILL         0x12
CONSTANT: S_THREAD_LOCAL_VARIABLES        0x13
CONSTANT: S_THREAD_LOCAL_VARIABLE_POINTERS 0x14
CONSTANT: S_THREAD_LOCAL_INIT_FUNCTION_POINTERS 0x15
CONSTANT: S_INIT_FUNC_OFFSETS             0x16

CONSTANT: SECTION_ATTRIBUTES_USR     0xff000000
CONSTANT: S_ATTR_PURE_INSTRUCTIONS   0x80000000
CONSTANT: S_ATTR_NO_TOC              0x40000000
CONSTANT: S_ATTR_STRIP_STATIC_SYMS   0x20000000
CONSTANT: S_ATTR_NO_DEAD_STRIP       0x10000000
CONSTANT: S_ATTR_LIVE_SUPPORT        0x08000000
CONSTANT: S_ATTR_SELF_MODIFYING_CODE 0x04000000
CONSTANT: S_ATTR_DEBUG               0x02000000
CONSTANT: SECTION_ATTRIBUTES_SYS     0x00ffff00
CONSTANT: S_ATTR_SOME_INSTRUCTIONS   0x00000400
CONSTANT: S_ATTR_EXT_RELOC           0x00000200
CONSTANT: S_ATTR_LOC_RELOC           0x00000100

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
    { minor_version    uint     }
    { header_addr      uint     } ;

STRUCT: fvmlib_command
    { cmd        uint     }
    { cmdsize    uint     }
    { fvmlib     fvmlib   } ;

STRUCT: dylib
    { name                  lc_str   }
    { timestamp             uint     }
    { current_version       uint     }
    { compatibility_version uint     } ;

STRUCT: dylib_command
    { cmd        uint     }
    { cmdsize    uint     }
    { dylib      dylib    } ;

STRUCT: sub_framework_command
    { cmd         uint     }
    { cmdsize     uint     }
    { umbrella    lc_str   } ;

STRUCT: sub_client_command
    { cmd        uint     }
    { cmdsize    uint     }
    { client     lc_str   } ;

STRUCT: sub_umbrella_command
    { cmd             uint     }
    { cmdsize         uint     }
    { sub_umbrella    lc_str   } ;

STRUCT: sub_library_command
    { cmd            uint     }
    { cmdsize        uint     }
    { sub_library    lc_str   } ;

STRUCT: prebound_dylib_command
    { cmd               uint     }
    { cmdsize           uint     }
    { name              lc_str   }
    { nmodules          uint     }
    { linked_modules    lc_str   } ;

STRUCT: dylinker_command
    { cmd        uint     }
    { cmdsize    uint     }
    { name       lc_str   } ;

STRUCT: thread_command
    { cmd        uint }
    { cmdsize    uint } ;

STRUCT: routines_command
    { cmd             uint }
    { cmdsize         uint }
    { init_address    uint }
    { init_module     uint }
    { reserved1       uint }
    { reserved2       uint }
    { reserved3       uint }
    { reserved4       uint }
    { reserved5       uint }
    { reserved6       uint } ;

STRUCT: routines_command_64
    { cmd             uint      }
    { cmdsize         uint      }
    { init_address    ulonglong }
    { init_module     ulonglong }
    { reserved1       ulonglong }
    { reserved2       ulonglong }
    { reserved3       ulonglong }
    { reserved4       ulonglong }
    { reserved5       ulonglong }
    { reserved6       ulonglong } ;

STRUCT: symtab_command
    { cmd        uint }
    { cmdsize    uint }
    { symoff     uint }
    { nsyms      uint }
    { stroff     uint }
    { strsize    uint } ;

STRUCT: dysymtab_command
    { cmd            uint }
    { cmdsize        uint }
    { ilocalsym      uint }
    { nlocalsym      uint }
    { iextdefsym     uint }
    { nextdefsym     uint }
    { iundefsym      uint }
    { nundefsym      uint }
    { tocoff         uint }
    { ntoc           uint }
    { modtaboff      uint }
    { nmodtab        uint }
    { extrefsymoff   uint }
    { nextrefsyms    uint }
    { indirectsymoff uint }
    { nindirectsyms  uint }
    { extreloff      uint }
    { nextrel        uint }
    { locreloff      uint }
    { nlocrel        uint } ;

CONSTANT: INDIRECT_SYMBOL_LOCAL 0x80000000
CONSTANT: INDIRECT_SYMBOL_ABS   0x40000000

STRUCT: dylib_table_of_contents
    { symbol_index uint }
    { module_index uint } ;

STRUCT: dylib_module
    { module_name           uint }
    { iextdefsym            uint }
    { nextdefsym            uint }
    { irefsym               uint }
    { nrefsym               uint }
    { ilocalsym             uint }
    { nlocalsym             uint }
    { iextrel               uint }
    { nextrel               uint }
    { iinit_iterm           uint }
    { ninit_nterm           uint }
    { objc_module_info_addr uint }
    { objc_module_info_size uint } ;

STRUCT: dylib_module_64
    { module_name           uint      }
    { iextdefsym            uint      }
    { nextdefsym            uint      }
    { irefsym               uint      }
    { nrefsym               uint      }
    { ilocalsym             uint      }
    { nlocalsym             uint      }
    { iextrel               uint      }
    { nextrel               uint      }
    { iinit_iterm           uint      }
    { ninit_nterm           uint      }
    { objc_module_info_size uint      }
    { objc_module_info_addr ulonglong } ;

STRUCT: dylib_reference
    { isym_flags uint } ;

STRUCT: twolevel_hints_command
    { cmd     uint }
    { cmdsize uint }
    { offset  uint }
    { nhints  uint } ;

STRUCT: twolevel_hint
    { isub_image_itoc uint } ;

STRUCT: prebind_cksum_command
    { cmd     uint }
    { cmdsize uint }
    { cksum   uint } ;

STRUCT: uuid_command
    { cmd        uint        }
    { cmdsize    uint        }
    { uuid       uchar[16]   } ;

STRUCT: rpath_command
    { cmd         uint     }
    { cmdsize     uint     }
    { path        lc_str   } ;

STRUCT: linkedit_data_command
    { cmd         uint }
    { cmdsize     uint }
    { dataoff     uint }
    { datasize    uint } ;

STRUCT: encryption_info_command
    { cmd       uint }
    { cmdsize   uint }
    { cryptoff  uint }
    { cryptsize uint }
    { cryptid   uint } ;

STRUCT: dyld_info_command
    { cmd              uint }
    { cmdsize          uint }
    { rebase_off       uint }
    { rebase_size      uint }
    { bind_off         uint }
    { bind_size        uint }
    { weak_bind_off    uint }
    { weak_bind_size   uint }
    { lazy_bind_off    uint }
    { lazy_bind_size   uint }
    { export_off       uint }
    { export_size      uint } ;

STRUCT: version_min_command
    { cmd uint32_t }
    { cmdsize uint32_t }
    { version uint32_t }
    { sdk uint32_t } ;

STRUCT: build_version_command
    { cmd uint32_t }
    { cmdsize uint32_t }
    { platform uint32_t }
    { minos uint32_t }
    { sdk uint32_t }
    { ntools uint32_t } ;

STRUCT: build_tool_version
    { tool uint32_t }
    { version uint32_t } ;

CONSTANT: PLATFORM_UNKNOWN                        0
CONSTANT: PLATFORM_ANY                            0xFFFFFFFF
CONSTANT: PLATFORM_MACOS                          1
CONSTANT: PLATFORM_IOS                            2
CONSTANT: PLATFORM_TVOS                           3
CONSTANT: PLATFORM_WATCHOS                        4
CONSTANT: PLATFORM_BRIDGEOS                       5
CONSTANT: PLATFORM_MACCATALYST                    6
CONSTANT: PLATFORM_IOSSIMULATOR                   7
CONSTANT: PLATFORM_TVOSSIMULATOR                  8
CONSTANT: PLATFORM_WATCHOSSIMULATOR               9
CONSTANT: PLATFORM_DRIVERKIT                      10
CONSTANT: PLATFORM_VISIONOS                       11
CONSTANT: PLATFORM_VISIONOSSIMULATOR              12
CONSTANT: PLATFORM_FIRMWARE                       13
CONSTANT: PLATFORM_SEPOS                          14

CONSTANT: TOOL_CLANG           1
CONSTANT: TOOL_SWIFT           2
CONSTANT: TOOL_LD              3
CONSTANT: TOOL_LLD             4
CONSTANT: TOOL_METAL           1024
CONSTANT: TOOL_AIRLLD          1025
CONSTANT: TOOL_AIRNT           1026
CONSTANT: TOOL_AIRNT_PLUGIN    1027
CONSTANT: TOOL_AIRPACK         1028
CONSTANT: TOOL_GPUARCHIVER     1031
CONSTANT: TOOL_METAL_FRAMEWORK 1032

CONSTANT: REBASE_TYPE_POINTER                     1
CONSTANT: REBASE_TYPE_TEXT_ABSOLUTE32             2
CONSTANT: REBASE_TYPE_TEXT_PCREL32                3

CONSTANT: REBASE_OPCODE_MASK                                  0xF0
CONSTANT: REBASE_IMMEDIATE_MASK                               0x0F
CONSTANT: REBASE_OPCODE_DONE                                  0x00
CONSTANT: REBASE_OPCODE_SET_TYPE_IMM                          0x10
CONSTANT: REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB           0x20
CONSTANT: REBASE_OPCODE_ADD_ADDR_ULEB                         0x30
CONSTANT: REBASE_OPCODE_ADD_ADDR_IMM_SCALED                   0x40
CONSTANT: REBASE_OPCODE_DO_REBASE_IMM_TIMES                   0x50
CONSTANT: REBASE_OPCODE_DO_REBASE_ULEB_TIMES                  0x60
CONSTANT: REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB               0x70
CONSTANT: REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB    0x80

CONSTANT: BIND_TYPE_POINTER                       1
CONSTANT: BIND_TYPE_TEXT_ABSOLUTE32               2
CONSTANT: BIND_TYPE_TEXT_PCREL32                  3

CONSTANT: BIND_SPECIAL_DYLIB_SELF                     0
CONSTANT: BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE          -1
CONSTANT: BIND_SPECIAL_DYLIB_FLAT_LOOKUP              -2
CONSTANT: BIND_SPECIAL_DYLIB_WEAK_LOOKUP              -3

CONSTANT: BIND_SYMBOL_FLAGS_WEAK_IMPORT                   0x1
CONSTANT: BIND_SYMBOL_FLAGS_NON_WEAK_DEFINITION           0x8

CONSTANT: BIND_OPCODE_MASK                                    0xF0
CONSTANT: BIND_IMMEDIATE_MASK                                 0x0F
CONSTANT: BIND_OPCODE_DONE                                    0x00
CONSTANT: BIND_OPCODE_SET_DYLIB_ORDINAL_IMM                   0x10
CONSTANT: BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB                  0x20
CONSTANT: BIND_OPCODE_SET_DYLIB_SPECIAL_IMM                   0x30
CONSTANT: BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM           0x40
CONSTANT: BIND_OPCODE_SET_TYPE_IMM                            0x50
CONSTANT: BIND_OPCODE_SET_ADDEND_SLEB                         0x60
CONSTANT: BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB             0x70
CONSTANT: BIND_OPCODE_ADD_ADDR_ULEB                           0x80
CONSTANT: BIND_OPCODE_DO_BIND                                 0x90
CONSTANT: BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB                   0xA0
CONSTANT: BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED             0xB0
CONSTANT: BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB        0xC0
CONSTANT: BIND_OPCODE_THREADED                                0xD0
CONSTANT: BIND_SUBOPCODE_THREADED_SET_BIND_ORDINAL_TABLE_SIZE_ULEB 0x00
CONSTANT: BIND_SUBOPCODE_THREADED_APPLY                       0x01

CONSTANT: EXPORT_SYMBOL_FLAGS_KIND_MASK                   0x03
CONSTANT: EXPORT_SYMBOL_FLAGS_KIND_REGULAR                0x00
CONSTANT: EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL           0x01
CONSTANT: EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION             0x04
CONSTANT: EXPORT_SYMBOL_FLAGS_INDIRECT_DEFINITION         0x08
CONSTANT: EXPORT_SYMBOL_FLAGS_HAS_SPECIALIZATIONS         0x10
CONSTANT: EXPORT_SYMBOL_FLAGS_STATIC_RESOLVER             0x20

STRUCT: symseg_command
    { cmd        uint }
    { cmdsize    uint }
    { offset     uint }
    { size       uint } ;

STRUCT: ident_command
    { cmd     uint }
    { cmdsize uint } ;

STRUCT: fvmfile_command
    { cmd            uint     }
    { cmdsize        uint     }
    { name           lc_str   }
    { header_addr    uint     } ;

STRUCT: entry_point_command
    { cmd uint32_t }
    { cmdsize uint32_t }
    { entryoff uint64_t }
    { stacksize uint64_t } ;

STRUCT: source_version_command
    { cmd uint32_t }
    { cmdsize uint32_t }
    { version uint64_t } ;

STRUCT: data_in_code_entry
    { offset uint32_t }
    { length uint16_t }
    { kind uint16_t } ;

! machine.h
CONSTANT: CPU_STATE_MAX       4
CONSTANT: CPU_STATE_USER      0
CONSTANT: CPU_STATE_SYSTEM    1
CONSTANT: CPU_STATE_IDLE      2
CONSTANT: CPU_STATE_NICE      3

CONSTANT: CPU_ARCH_MASK   0xff000000
CONSTANT: CPU_ARCH_ABI64  0x01000000

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

CONSTANT: CPU_SUBTYPE_MASK    0xff000000
CONSTANT: CPU_SUBTYPE_LIB64   0x80000000

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
CONSTANT: CPUFAMILY_POWERPC_G3 0xcee41549
CONSTANT: CPUFAMILY_POWERPC_G4 0x77c184ae
CONSTANT: CPUFAMILY_POWERPC_G5 0xed76d8aa
CONSTANT: CPUFAMILY_INTEL_6_13 0xaa33392b
CONSTANT: CPUFAMILY_INTEL_6_14 0x73d67300
CONSTANT: CPUFAMILY_INTEL_6_15 0x426f69ef
CONSTANT: CPUFAMILY_INTEL_6_23 0x78ea4fbc
CONSTANT: CPUFAMILY_INTEL_6_26 0x6b5a4cd2
CONSTANT: CPUFAMILY_ARM_9      0xe73283ae
CONSTANT: CPUFAMILY_ARM_11     0x8ff620d8
CONSTANT: CPUFAMILY_ARM_XSCALE 0x53b005f5
CONSTANT: CPUFAMILY_ARM_13     0x0cc90e64

ALIAS: CPUFAMILY_INTEL_YONAH   CPUFAMILY_INTEL_6_14
ALIAS: CPUFAMILY_INTEL_MEROM   CPUFAMILY_INTEL_6_15
ALIAS: CPUFAMILY_INTEL_PENRYN  CPUFAMILY_INTEL_6_23
ALIAS: CPUFAMILY_INTEL_NEHALEM CPUFAMILY_INTEL_6_26

ALIAS: CPUFAMILY_INTEL_CORE    CPUFAMILY_INTEL_6_14
ALIAS: CPUFAMILY_INTEL_CORE2   CPUFAMILY_INTEL_6_15

! fat.h
CONSTANT: FAT_MAGIC 0xcafebabe
CONSTANT: FAT_CIGAM 0xbebafeca

STRUCT: fat_header
    { magic        uint }
    { nfat_arch    uint } ;

STRUCT: fat_arch
    { cputype      cpu_type_t    }
    { cpusubtype   cpu_subtype_t }
    { offset       uint          }
    { size         uint          }
    { align        uint          } ;

! nlist.h
STRUCT: nlist
    { n_strx  int      }
    { n_type  uchar    }
    { n_sect  uchar    }
    { n_desc  short    }
    { n_value uint     } ;

STRUCT: nlist_64
    { n_strx  uint      }
    { n_type  uchar     }
    { n_sect  uchar     }
    { n_desc  ushort    }
    { n_value ulonglong } ;

CONSTANT: N_STAB  0xe0
CONSTANT: N_PEXT  0x10
CONSTANT: N_TYPE  0x0e
CONSTANT: N_EXT   0x01

CONSTANT: N_UNDF  0x0
CONSTANT: N_ABS   0x2
CONSTANT: N_SECT  0xe
CONSTANT: N_PBUD  0xc
CONSTANT: N_INDR  0xa

CONSTANT: NO_SECT     0
CONSTANT: MAX_SECT    255

: GET_COMM_ALIGN ( n_desc -- align )
    -8 shift 0x0f bitand ; inline

: SET_COMM_ALIGN ( n_desc align -- n_desc )
    [ 0xf0ff bitand ]
    [ 0x000f bitand 8 shift ] bi* bitor ; inline

CONSTANT: REFERENCE_TYPE                              7
CONSTANT: REFERENCE_FLAG_UNDEFINED_NON_LAZY           0
CONSTANT: REFERENCE_FLAG_UNDEFINED_LAZY               1
CONSTANT: REFERENCE_FLAG_DEFINED                      2
CONSTANT: REFERENCE_FLAG_PRIVATE_DEFINED              3
CONSTANT: REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY   4
CONSTANT: REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY       5

CONSTANT: REFERENCED_DYNAMICALLY  0x0010

: GET_LIBRARY_ORDINAL ( n_desc -- ordinal )
    -8 shift 0xff bitand ; inline

: SET_LIBRARY_ORDINAL ( n_desc ordinal -- n_desc )
    [ 0x00ff bitand ]
    [ 0x00ff bitand 8 shift ] bi* bitor ; inline

CONSTANT: SELF_LIBRARY_ORDINAL   0x0
CONSTANT: MAX_LIBRARY_ORDINAL    0xfd
CONSTANT: DYNAMIC_LOOKUP_ORDINAL 0xfe
CONSTANT: EXECUTABLE_ORDINAL     0xff

CONSTANT: N_NO_DEAD_STRIP  0x0020
CONSTANT: N_DESC_DISCARDED 0x0020
CONSTANT: N_WEAK_REF       0x0040
CONSTANT: N_WEAK_DEF       0x0080
CONSTANT: N_REF_TO_WEAK    0x0080
CONSTANT: N_ARM_THUMB_DEF  0x0008

! ranlib.h
CONSTANT: SYMDEF        "__.SYMDEF"
CONSTANT: SYMDEF_SORTED "__.SYMDEF SORTED"

STRUCT: ranlib
    { ran_strx uint }
    { ran_off  uint } ;

! reloc.h
STRUCT: relocation_info
    { r_address                            int  }
    { r_symbolnum_pcrel_length_extern_type uint } ;

CONSTANT: R_ABS   0
CONSTANT: R_SCATTERED 0x80000000

STRUCT: scattered_relocation_info_big_endian
    { r_scattered_pcrel_length_type_address  uint }
    { r_value                                int  } ;

STRUCT: scattered_relocation_info_little_endian
    { r_address_type_length_pcrel_scattered uint }
    { r_value                               int  } ;

ENUM: reloc_type_generic
    GENERIC_RELOC_VANILLA
    GENERIC_RELOC_PAIR
    GENERIC_RELOC_SECTDIFF
    GENERIC_RELOC_PB_LA_PTR
    GENERIC_RELOC_LOCAL_SECTDIFF ;

ENUM: reloc_type_x86_64
    X86_64_RELOC_UNSIGNED
    X86_64_RELOC_SIGNED
    X86_64_RELOC_BRANCH
    X86_64_RELOC_GOT_LOAD
    X86_64_RELOC_GOT
    X86_64_RELOC_SUBTRACTOR
    X86_64_RELOC_SIGNED_1
    X86_64_RELOC_SIGNED_2
    X86_64_RELOC_SIGNED_4 ;

ENUM: reloc_type_ppc
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

! Low-level interface
SPECIALIZED-ARRAYS: section section_64 nlist nlist_64 fat_arch uchar ;
UNION: mach_header_32/64 mach_header mach_header_64 ;
UNION: segment_command_32/64 segment_command segment_command_64 ;
UNION: load-command segment_command segment_command_64
    dylib_command sub_framework_command
    sub_client_command sub_umbrella_command sub_library_command
    prebound_dylib_command dylinker_command thread_command
    routines_command routines_command_64 symtab_command
    dysymtab_command twolevel_hints_command uuid_command ;
UNION: section_32/64 section section_64 ;
UNION: section_32/64-array section-array section_64-array ;
UNION: nlist_32/64 nlist nlist_64 ;
UNION: nlist_32/64-array nlist-array nlist_64-array ;

TUPLE: fat-binary-member cpu-type cpu-subtype data ;
ERROR: not-fat-binary ;

: fat-binary-members ( >c-ptr -- fat-binary-members )
    fat_header memory>struct dup magic>> {
        { FAT_MAGIC [ ] }
        { FAT_CIGAM [ ] }
        [ 2drop not-fat-binary ]
    } case dup
    [ >c-ptr fat_header heap-size swap <displaced-alien> ]
    [ nfat_arch>> 4 >be le> ] bi
    fat_arch <c-direct-array> [
        {
            [ nip cputype>> 4 >be le> ]
            [ nip cpusubtype>> 4 >be le> ]
            [ offset>> 4 >be le> swap >c-ptr <displaced-alien> ]
            [ nip size>> 4 >be le> uchar <c-direct-array> ]
        } 2cleave fat-binary-member boa
    ] with { } map-as ;

TYPED: 64-bit? ( macho: mach_header_32/64 -- ? )
    magic>> {
        { MH_MAGIC_64 [ t ] }
        { MH_CIGAM_64 [ t ] }
        [ drop f ]
    } case ;

: macho-header ( c-ptr -- macho: mach_header_32/64 )
    dup mach_header_64 memory>struct 64-bit?
    [ mach_header_64 memory>struct ]
    [ mach_header memory>struct ] if ;

: cmd>load-command ( cmd -- load-command )
    {
        { LC_UUID           [ uuid_command           ] }
        { LC_SEGMENT        [ segment_command        ] }
        { LC_SEGMENT_64     [ segment_command_64     ] }
        { LC_SYMTAB         [ symtab_command         ] }
        { LC_DYSYMTAB       [ dysymtab_command       ] }
        { LC_THREAD         [ thread_command         ] }
        { LC_UNIXTHREAD     [ thread_command         ] }
        { LC_LOAD_DYLIB     [ dylib_command          ] }
        { LC_ID_DYLIB       [ dylib_command          ] }
        { LC_PREBOUND_DYLIB [ prebound_dylib_command ] }
        { LC_LOAD_DYLINKER  [ dylinker_command       ] }
        { LC_ID_DYLINKER    [ dylinker_command       ] }
        { LC_ROUTINES       [ routines_command       ] }
        { LC_ROUTINES_64    [ routines_command_64    ] }
        { LC_TWOLEVEL_HINTS [ twolevel_hints_command ] }
        { LC_SUB_FRAMEWORK  [ sub_framework_command  ] }
        { LC_SUB_UMBRELLA   [ sub_umbrella_command   ] }
        { LC_SUB_LIBRARY    [ sub_library_command    ] }
        { LC_SUB_CLIENT     [ sub_client_command     ] }
        { LC_DYLD_INFO      [ dyld_info_command      ] }
        { LC_DYLD_INFO_ONLY [ dyld_info_command      ] }
        { LC_LOAD_UPWARD_DYLIB [ dylib_command ] }
        { LC_VERSION_MIN_MACOSX [ version_min_command ] }
        { LC_VERSION_MIN_IPHONEOS [ version_min_command ] }
        { LC_FUNCTION_STARTS [ linkedit_data_command ] }
        { LC_DYLD_ENVIRONMENT [ dylinker_command ] }
        { LC_MAIN [ entry_point_command ] }
        { LC_DATA_IN_CODE [ data_in_code_entry ] }
        { LC_SOURCE_VERSION [ source_version_command ] }
        { LC_CODE_SIGNATURE [ linkedit_data_command ] }
        { LC_SEGMENT_SPLIT_INFO [ linkedit_data_command ] }
        { LC_FUNCTION_STARTS [ linkedit_data_command ] }
        { LC_DATA_IN_CODE [ linkedit_data_command ] }
        { LC_DYLIB_CODE_SIGN_DRS [ linkedit_data_command ] }
        { LC_DYLD_EXPORTS_TRIE [ linkedit_data_command ] }
        { LC_DYLD_CHAINED_FIXUPS [ linkedit_data_command ] }
        { LC_BUILD_VERSION [ build_version_command ] }
    } case ;

: read-command ( cmd -- next-cmd )
    dup load_command memory>struct
    [ cmd>> cmd>load-command memory>struct , ]
    [ cmdsize>> swap <displaced-alien> ] 2bi ;

TYPED: load-commands ( macho: mach_header_32/64 -- load-commands )
    [
        [ class-of heap-size ]
        [ >c-ptr <displaced-alien> ]
        [ ncmds>> ] tri <iota> [
            drop read-command
        ] each drop
    ] { } make ;

: segment-commands ( load-commands -- segment-commands )
    [ segment_command_32/64? ] filter ; inline

: symtab-commands ( load-commands -- segment-commands )
    [ symtab_command? ] filter ; inline

: read-array-string ( uchar-array -- string )
    ascii decode 0 swap remove ;

: segment-sections ( segment-command -- sections )
    {
        [ class-of heap-size ]
        [ >c-ptr <displaced-alien> ]
        [ nsects>> ]
        [ segment_command_64? ]
    } cleave
    [ section_64 <c-direct-array> ]
    [ section <c-direct-array> ] if ;

: sections-array ( segment-commands -- sections-array )
    [
        dup first segment_command_64?
        [ section_64 ] [ section ] if new ,
        segment-commands [ segment-sections [ , ] each ] each
    ] { } make ;

: symbols ( mach-header symtab-command -- symbols string-table )
    [ symoff>> swap >c-ptr <displaced-alien> ]
    [ nsyms>> swap 64-bit?
      [ nlist_64 <c-direct-array> ]
      [ nlist <c-direct-array> ] if ]
    [ stroff>> swap >c-ptr <displaced-alien> ] 2tri ;

: symbol-name ( symbol string-table -- name )
    [ n_strx>> ] dip <displaced-alien> ascii alien>string ;

: c-symbol-name ( symbol string-table -- name )
    symbol-name "_" ?head drop ;

: with-mapped-macho ( path quot -- )
    '[
        address>> macho-header @
    ] with-mapped-file-reader ; inline

: macho-nm ( path -- )
    [| macho |
        macho load-commands segment-commands sections-array :> sections
        macho load-commands symtab-commands [| symtab |
            macho symtab symbols [
                [ drop n_value>> "%016x " printf ]
                [
                    drop n_sect>> sections nth sectname>>
                    read-array-string "%-16s" printf
                ]
                [ symbol-name "%s\n" printf ] 2tri
            ] curry each
        ] each
    ] with-mapped-macho ;

: dylib-export? ( symtab-entry -- ? )
    n_type>> {
        [ N_EXT bitand zero? not ]
        [ N_TYPE bitand N_UNDF = not ]
    } 1&& ;

: dylib-exports ( path -- symbol-names )
    [| macho |
        macho load-commands symtab-commands [| symtab |
            macho symtab symbols
            [ [ dylib-export? ] filter ]
            [ [ c-symbol-name ] curry { } map-as ] bi*
        ] { } map-as concat
    ] with-mapped-macho ;
