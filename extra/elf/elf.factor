! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
alien.syntax arrays assocs classes.struct fry io.encodings.ascii
io.mmap kernel locals math math.intervals sequences
specialized-arrays strings typed ;
IN: elf

! FFI data
CONSTANT: EI_NIDENT 16
CONSTANT: EI_MAG0       0
CONSTANT: EI_MAG1       1
CONSTANT: EI_MAG2       2
CONSTANT: EI_MAG3       3
CONSTANT: EI_CLASS      4
CONSTANT: EI_DATA       5
CONSTANT: EI_VERSION    6
CONSTANT: EI_OSABI      7
CONSTANT: EI_ABIVERSION 8
CONSTANT: EI_PAD        9

CONSTANT: ELFMAG0       0x7f
CONSTANT: ELFMAG1       0x45
CONSTANT: ELFMAG2       0x4c
CONSTANT: ELFMAG3       0x46

CONSTANT: ELFCLASS32 1
CONSTANT: ELFCLASS64 2

CONSTANT: ELFDATA2LSB 1
CONSTANT: ELFDATA2MSB 2

CONSTANT: ELFOSABI_SYSV       0
CONSTANT: ELFOSABI_HPUX       1
CONSTANT: ELFOSABI_NETBSD     2
CONSTANT: ELFOSABI_LINUX      3
CONSTANT: ELFOSABI_SOLARIS    6
CONSTANT: ELFOSABI_AIX        7
CONSTANT: ELFOSABI_IRIX       8
CONSTANT: ELFOSABI_FREEBSD    9
CONSTANT: ELFOSABI_TRU64      10
CONSTANT: ELFOSABI_MODESTO    11
CONSTANT: ELFOSABI_OPENBSD    12
CONSTANT: ELFOSABI_OPENVMS    13
CONSTANT: ELFOSABI_NSK        14
CONSTANT: ELFOSABI_AROS       15
CONSTANT: ELFOSABI_ARM_AEABI  64
CONSTANT: ELFOSABI_ARM        97
CONSTANT: ELFOSABI_STANDALONE 255

CONSTANT: ET_NONE   0
CONSTANT: ET_REL    1
CONSTANT: ET_EXEC   2
CONSTANT: ET_DYN    3
CONSTANT: ET_CORE   4
CONSTANT: ET_LOOS   0xFE00
CONSTANT: ET_HIOS   0xFEFF
CONSTANT: ET_LOPROC 0xFF00
CONSTANT: ET_HIPROC 0xFFFF

CONSTANT: EM_NONE         0
CONSTANT: EM_M32          1
CONSTANT: EM_SPARC        2
CONSTANT: EM_386          3
CONSTANT: EM_68K          4
CONSTANT: EM_88K          5
CONSTANT: EM_486          6
CONSTANT: EM_860          7
CONSTANT: EM_MIPS         8
CONSTANT: EM_S370         9
CONSTANT: EM_MIPS_RS3_LE  10
CONSTANT: EM_SPARC64      11
CONSTANT: EM_PARISC       15
CONSTANT: EM_VPP500       17
CONSTANT: EM_SPARC32PLUS  18
CONSTANT: EM_960          19
CONSTANT: EM_PPC          20
CONSTANT: EM_PPC64        21
CONSTANT: EM_S390         22
CONSTANT: EM_SPU          23
CONSTANT: EM_V800         36
CONSTANT: EM_FR20         37
CONSTANT: EM_RH32         38
CONSTANT: EM_RCE          39
CONSTANT: EM_ARM          40
CONSTANT: EM_ALPHA        41
CONSTANT: EM_SH           42
CONSTANT: EM_SPARCV9      43
CONSTANT: EM_TRICORE      44
CONSTANT: EM_ARC          45
CONSTANT: EM_H8_300       46
CONSTANT: EM_H8_300H      47
CONSTANT: EM_H8S          48
CONSTANT: EM_H8_500       49
CONSTANT: EM_IA_64        50
CONSTANT: EM_MIPS_X       51
CONSTANT: EM_COLDFIRE     52
CONSTANT: EM_68HC12       53
CONSTANT: EM_MMA          54
CONSTANT: EM_PCP          55
CONSTANT: EM_NCPU         56
CONSTANT: EM_NDR1         57
CONSTANT: EM_STARCORE     58
CONSTANT: EM_ME16         59
CONSTANT: EM_ST100        60
CONSTANT: EM_TINYJ        61
CONSTANT: EM_X86_64       62
CONSTANT: EM_PDSP         63
CONSTANT: EM_FX66         66
CONSTANT: EM_ST9PLUS      67
CONSTANT: EM_ST7          68
CONSTANT: EM_68HC16       69
CONSTANT: EM_68HC11       70
CONSTANT: EM_68HC08       71
CONSTANT: EM_68HC05       72
CONSTANT: EM_SVX          73
CONSTANT: EM_ST19         74
CONSTANT: EM_VAX          75
CONSTANT: EM_CRIS         76
CONSTANT: EM_JAVELIN      77
CONSTANT: EM_FIREPATH     78
CONSTANT: EM_ZSP          79
CONSTANT: EM_MMIX         80
CONSTANT: EM_HUANY        81
CONSTANT: EM_PRISM        82
CONSTANT: EM_AVR          83
CONSTANT: EM_FR30         84
CONSTANT: EM_D10V         85
CONSTANT: EM_D30V         86
CONSTANT: EM_V850         87
CONSTANT: EM_M32R         88
CONSTANT: EM_MN10300      89
CONSTANT: EM_MN10200      90
CONSTANT: EM_PJ           91
CONSTANT: EM_OPENRISC     92
CONSTANT: EM_ARC_A5       93
CONSTANT: EM_XTENSA       94
CONSTANT: EM_VIDEOCORE    95
CONSTANT: EM_TMM_GPP      96
CONSTANT: EM_NS32K        97
CONSTANT: EM_TPC          98
CONSTANT: EM_SNP1K        99
CONSTANT: EM_ST200        100
CONSTANT: EM_IP2K         101
CONSTANT: EM_MAX          102
CONSTANT: EM_CR           103
CONSTANT: EM_F2MC16       104
CONSTANT: EM_MSP430       105
CONSTANT: EM_BLACKFIN     106
CONSTANT: EM_SE_C33       107
CONSTANT: EM_SEP          108
CONSTANT: EM_ARCA         109
CONSTANT: EM_UNICORE      110

CONSTANT: EV_NONE    0
CONSTANT: EV_CURRENT 1

CONSTANT: EF_ARM_EABIMASK 0xff000000
CONSTANT: EF_ARM_BE8      0x00800000

CONSTANT: SHN_UNDEF  0x0000
CONSTANT: SHN_LOPROC 0xFF00
CONSTANT: SHN_HIPROC 0xFF1F
CONSTANT: SHN_LOOS   0xFF20
CONSTANT: SHN_HIOS   0xFF3F
CONSTANT: SHN_ABS    0xFFF1
CONSTANT: SHN_COMMON 0xFFF2

CONSTANT: SHT_NULL               0
CONSTANT: SHT_PROGBITS           1
CONSTANT: SHT_SYMTAB             2
CONSTANT: SHT_STRTAB             3
CONSTANT: SHT_RELA               4
CONSTANT: SHT_HASH               5
CONSTANT: SHT_DYNAMIC            6
CONSTANT: SHT_NOTE               7
CONSTANT: SHT_NOBITS             8
CONSTANT: SHT_REL                9
CONSTANT: SHT_SHLIB              10
CONSTANT: SHT_DYNSYM             11
CONSTANT: SHT_LOOS               0x60000000
CONSTANT: SHT_GNU_LIBLIST        0x6ffffff7
CONSTANT: SHT_CHECKSUM           0x6ffffff8
CONSTANT: SHT_LOSUNW             0x6ffffffa
CONSTANT: SHT_SUNW_move          0x6ffffffa
CONSTANT: SHT_SUNW_COMDAT        0x6ffffffb
CONSTANT: SHT_SUNW_syminfo       0x6ffffffc
CONSTANT: SHT_GNU_verdef         0x6ffffffd
CONSTANT: SHT_GNU_verneed        0x6ffffffe
CONSTANT: SHT_GNU_versym         0x6fffffff
CONSTANT: SHT_HISUNW             0x6fffffff
CONSTANT: SHT_HIOS               0x6fffffff
CONSTANT: SHT_LOPROC             0x70000000
CONSTANT: SHT_ARM_EXIDX          0x70000001
CONSTANT: SHT_ARM_PREEMPTMAP     0x70000002
CONSTANT: SHT_ARM_ATTRIBUTES     0x70000003
CONSTANT: SHT_ARM_DEBUGOVERLAY   0x70000004
CONSTANT: SHT_ARM_OVERLAYSECTION 0x70000005
CONSTANT: SHT_HIPROC             0x7fffffff
CONSTANT: SHT_LOUSER             0x80000000
CONSTANT: SHT_HIUSER             0x8fffffff

CONSTANT: SHF_WRITE            1
CONSTANT: SHF_ALLOC            2
CONSTANT: SHF_EXECINSTR        4
CONSTANT: SHF_MERGE            16
CONSTANT: SHF_STRINGS          32
CONSTANT: SHF_INFO_LINK        64
CONSTANT: SHF_LINK_ORDER       128
CONSTANT: SHF_OS_NONCONFORMING 256
CONSTANT: SHF_GROUP            512
CONSTANT: SHF_TLS              1024
CONSTANT: SHF_MASKOS           0x0f000000
CONSTANT: SHF_MASKPROC         0xf0000000

CONSTANT: STB_LOCAL  0
CONSTANT: STB_GLOBAL 1
CONSTANT: STB_WEAK   2
CONSTANT: STB_LOOS   10
CONSTANT: STB_HIOS   12
CONSTANT: STB_LOPROC 13
CONSTANT: STB_HIPROC 15

CONSTANT: STT_NOTYPE   0
CONSTANT: STT_OBJECT   1
CONSTANT: STT_FUNC     2
CONSTANT: STT_SECTION  3
CONSTANT: STT_FILE     4
CONSTANT: STT_COMMON   5
CONSTANT: STT_TLS      6
CONSTANT: STT_LOOS    10
CONSTANT: STT_HIOS    12
CONSTANT: STT_LOPROC  13
CONSTANT: STT_HIPROC  15

CONSTANT: STN_UNDEF 0

CONSTANT: STV_DEFAULT   0
CONSTANT: STV_INTERNAL  1
CONSTANT: STV_HIDDEN    2
CONSTANT: STV_PROTECTED 3

CONSTANT: PT_NULL        0
CONSTANT: PT_LOAD        1
CONSTANT: PT_DYNAMIC     2
CONSTANT: PT_INTERP      3
CONSTANT: PT_NOTE        4
CONSTANT: PT_SHLIB       5
CONSTANT: PT_PHDR        6
CONSTANT: PT_TLS         7
CONSTANT: PT_LOOS        0x60000000
CONSTANT: PT_HIOS        0x6fffffff
CONSTANT: PT_LOPROC      0x70000000
CONSTANT: PT_ARM_ARCHEXT 0x70000000
CONSTANT: PT_ARM_EXIDX   0x70000001
CONSTANT: PT_ARM_UNWIND  0x70000001
CONSTANT: PT_HIPROC      0x7fffffff

CONSTANT: PT_ARM_ARCHEXT_FMTMSK       0xff000000
CONSTANT: PT_ARM_ARCHEXT_PROFMSK      0x00ff0000
CONSTANT: PT_ARM_ARCHEXT_ARCHMSK      0x000000ff
CONSTANT: PT_ARM_ARCHEXT_FMT_OS       0x00000000
CONSTANT: PT_ARM_ARCHEXT_FMT_ABI      0x01000000
CONSTANT: PT_ARM_ARCHEXT_PROF_NONE    0x00000000
CONSTANT: PT_ARM_ARCHEXT_PROF_ARM     0x00410000
CONSTANT: PT_ARM_ARCHEXT_PROF_RT      0x00520000
CONSTANT: PT_ARM_ARCHEXT_PROF_MC      0x004d0000
CONSTANT: PT_ARM_ARCHEXT_PROF_CLASSIC 0x00530000

CONSTANT: PT_ARM_ARCHEXT_ARCH_UNKN      0x00
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv4    0x01
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv4T   0x02
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv5T   0x03
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv5TE  0x04
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv5TEJ 0x05
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv6    0x06
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv6KZ  0x07
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv6T2  0x08
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv6K   0x09
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv7    0x0A
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv6M   0x0B
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv6SM  0x0C
CONSTANT: PT_ARM_ARCHEXT_ARCH_ARCHv7EM  0x0D

CONSTANT: PF_X        1
CONSTANT: PF_W        2
CONSTANT: PF_R        4
CONSTANT: PF_MASKOS   0x00ff0000
CONSTANT: PF_MASKPROC 0xff000000

CONSTANT: DT_NULL            0
CONSTANT: DT_NEEDED          1
CONSTANT: DT_PLTRELSZ        2
CONSTANT: DT_PLTGOT          3
CONSTANT: DT_HASH            4
CONSTANT: DT_STRTAB          5
CONSTANT: DT_SYMTAB          6
CONSTANT: DT_RELA            7
CONSTANT: DT_RELASZ          8
CONSTANT: DT_RELAENT         9
CONSTANT: DT_STRSZ           10
CONSTANT: DT_SYMENT          11
CONSTANT: DT_INIT            12
CONSTANT: DT_FINI            13
CONSTANT: DT_SONAME          14
CONSTANT: DT_RPATH           15
CONSTANT: DT_SYMBOLIC        16
CONSTANT: DT_REL             17
CONSTANT: DT_RELSZ           18
CONSTANT: DT_RELENT          19
CONSTANT: DT_PLTREL          20
CONSTANT: DT_DEBUG           21
CONSTANT: DT_TEXTREL         22
CONSTANT: DT_JMPREL          23
CONSTANT: DT_BIND_NOW        24
CONSTANT: DT_INIT_ARRAY      25
CONSTANT: DT_FINI_ARRAY      26
CONSTANT: DT_INIT_ARRAYSZ    27
CONSTANT: DT_FINI_ARRAYSZ    28
CONSTANT: DT_RUNPATH         29
CONSTANT: DT_FLAGS           30
CONSTANT: DT_ENCODING        32
CONSTANT: DT_PREINIT_ARRAY   32
CONSTANT: DT_PREINIT_ARRAYSZ 33
CONSTANT: DT_LOOS            0x60000000
CONSTANT: DT_HIOS            0x6fffffff
CONSTANT: DT_LOPROC          0x70000000
CONSTANT: DT_ARM_RESERVED1   0x70000000
CONSTANT: DT_ARM_SYMTABSZ    0x70000001
CONSTANT: DT_ARM_PREEMPTYMAP 0x70000002
CONSTANT: DT_ARM_RESERVED2   0x70000003
CONSTANT: DT_HIPROC          0x7fffffff

TYPEDEF: ushort    Elf32_Half
TYPEDEF: uint      Elf32_Word
TYPEDEF: int       Elf32_Sword
TYPEDEF: uint      Elf32_Off
TYPEDEF: uint      Elf32_Addr
TYPEDEF: ushort    Elf64_Half
TYPEDEF: uint      Elf64_Word
TYPEDEF: ulonglong Elf64_Xword
TYPEDEF: longlong  Elf64_Sxword
TYPEDEF: ulonglong Elf64_Off
TYPEDEF: ulonglong Elf64_Addr

STRUCT: Elf32_Ehdr
    { e_ident     uchar[16]  }
    { e_type      Elf32_Half }
    { e_machine   Elf32_Half }
    { e_version   Elf32_Word }
    { e_entry     Elf32_Addr }
    { e_phoff     Elf32_Off  }
    { e_shoff     Elf32_Off  }
    { e_flags     Elf32_Word }
    { e_ehsize    Elf32_Half }
    { e_phentsize Elf32_Half }
    { e_phnum     Elf32_Half }
    { e_shentsize Elf32_Half }
    { e_shnum     Elf32_Half }
    { e_shstrndx  Elf32_Half } ;

STRUCT: Elf64_Ehdr
    { e_ident     uchar[16]  }
    { e_type      Elf64_Half }
    { e_machine   Elf64_Half }
    { e_version   Elf64_Word }
    { e_entry     Elf64_Addr }
    { e_phoff     Elf64_Off  }
    { e_shoff     Elf64_Off  }
    { e_flags     Elf64_Word }
    { e_ehsize    Elf64_Half }
    { e_phentsize Elf64_Half }
    { e_phnum     Elf64_Half }
    { e_shentsize Elf64_Half }
    { e_shnum     Elf64_Half }
    { e_shstrndx  Elf64_Half } ;

STRUCT: Elf32_Shdr
    { sh_name      Elf32_Word  }
    { sh_type      Elf32_Word  }
    { sh_flags     Elf32_Word  }
    { sh_addr      Elf32_Addr  }
    { sh_offset    Elf32_Off   }
    { sh_size      Elf32_Word  }
    { sh_link      Elf32_Word  }
    { sh_info      Elf32_Word  }
    { sh_addralign Elf32_Word  }
    { sh_entsize   Elf32_Word  } ;

STRUCT: Elf64_Shdr
    { sh_name      Elf64_Word  }
    { sh_type      Elf64_Word  }
    { sh_flags     Elf64_Xword }
    { sh_addr      Elf64_Addr  }
    { sh_offset    Elf64_Off   }
    { sh_size      Elf64_Xword }
    { sh_link      Elf64_Word  }
    { sh_info      Elf64_Word  }
    { sh_addralign Elf64_Xword }
    { sh_entsize   Elf64_Xword } ;

STRUCT: Elf32_Sym
    { st_name  Elf32_Word }
    { st_value Elf32_Addr }
    { st_size  Elf32_Word }
    { st_info  uchar      }
    { st_other uchar      }
    { st_shndx Elf32_Half } ;

STRUCT: Elf64_Sym
    { st_name  Elf64_Word  }
    { st_info  uchar       }
    { st_other uchar       }
    { st_shndx Elf64_Half  }
    { st_value Elf64_Addr  }
    { st_size  Elf64_Xword } ;

STRUCT: Elf32_Rel
    { r_offset Elf32_Addr }
    { r_info   Elf32_Word } ;

STRUCT: Elf32_Rela
    { r_offset Elf32_Addr  }
    { r_info   Elf32_Word  }
    { r_addend Elf32_Sword } ;

STRUCT: Elf64_Rel
    { r_offset Elf64_Addr  }
    { r_info   Elf64_Xword } ;

STRUCT: Elf64_Rela
    { r_offset Elf64_Addr   }
    { r_info   Elf64_Xword  }
    { r_addend Elf64_Sxword } ;

STRUCT: Elf32_Phdr
    { p_type   Elf32_Word  }
    { p_offset Elf32_Off   }
    { p_vaddr  Elf32_Addr  }
    { p_paddr  Elf32_Addr  }
    { p_filesz Elf32_Word  }
    { p_memsz  Elf32_Word  }
    { p_flags  Elf32_Word  }
    { p_align  Elf32_Word  } ;

STRUCT: Elf64_Phdr
    { p_type   Elf64_Word  }
    { p_flags  Elf64_Word  }
    { p_offset Elf64_Off   }
    { p_vaddr  Elf64_Addr  }
    { p_paddr  Elf64_Addr  }
    { p_filesz Elf64_Xword }
    { p_memsz  Elf64_Xword }
    { p_align  Elf64_Xword } ;

STRUCT: Elf32_Dyn
    { d_tag Elf32_Sword }
    { d_val Elf32_Word  } ;

STRUCT: Elf64_Dyn
    { d_tag Elf64_Sxword }
    { d_val Elf64_Xword  } ;

! Low-level interface
SPECIALIZED-ARRAYS: Elf32_Shdr Elf64_Shdr Elf32_Sym Elf64_Sym Elf32_Phdr Elf64_Phdr uchar ;
UNION: Elf32/64_Ehdr Elf32_Ehdr Elf64_Ehdr ;
UNION: Elf32/64_Shdr Elf32_Shdr Elf64_Shdr ;
UNION: Elf32/64_Shdr-array Elf32_Shdr-array Elf64_Shdr-array ;
UNION: Elf32/64_Sym Elf32_Sym Elf64_Sym ;
UNION: Elf32/64_Sym-array Elf32_Sym-array Elf64_Sym-array ;
UNION: Elf32/64_Phdr Elf32_Phdr Elf64_Phdr ;
UNION: Elf32/64_Phdr-array Elf32_Phdr-array Elf64_Phdr-array ;

TYPED: 64-bit? ( elf: Elf32/64_Ehdr -- ? )
    e_ident>> EI_CLASS swap nth ELFCLASS64 = ;

TYPED: elf-header ( c-ptr -- elf: Elf32/64_Ehdr )
    dup Elf64_Ehdr memory>struct dup 64-bit?
    [ nip ] [ drop Elf32_Ehdr memory>struct ] if ;

TYPED:: elf-section-headers ( elf: Elf32/64_Ehdr -- headers: Elf32/64_Shdr-array )
    elf [ e_shoff>> ] [ e_shnum>> ] bi :> ( off num )
    off elf >c-ptr <displaced-alien> num
    elf 64-bit? Elf64_Shdr Elf32_Shdr ? <c-direct-array> ;

TYPED:: elf-program-headers ( elf: Elf32/64_Ehdr -- headers: Elf32/64_Phdr-array )
    elf [ e_phoff>> ] [ e_phnum>> ] bi :> ( off num )
    off elf >c-ptr <displaced-alien> num
    elf 64-bit? Elf64_Phdr Elf32_Phdr ? <c-direct-array> ;

TYPED: elf-loadable-segments ( headers: Elf32/64_Phdr-array -- headers: Elf32/64_Phdr-array )
    [ p_type>> PT_LOAD = ] filter ;

TYPED:: elf-segment-sections ( segment: Elf32/64_Phdr sections: Elf32/64_Shdr-array -- sections )
    segment [ p_offset>> dup ] [ p_filesz>> + ] bi [a,b)                            :> segment-interval
    sections [ dup [ sh_offset>> dup ] [ sh_size>> + ] bi [a,b) 2array ] { } map-as :> section-intervals
    section-intervals [ second segment-interval interval-intersect empty-interval = not ]
    filter keys ;

TYPED:: virtual-address-segment ( elf: Elf32/64_Ehdr address -- program-header/f )
    elf elf-program-headers elf-loadable-segments [
        [ p_vaddr>> dup ] [ p_memsz>> + ] bi [a,b)
        address swap interval-contains?
    ] find nip ;

TYPED:: virtual-address-section ( elf: Elf32/64_Ehdr address -- section-header/f )
    elf address virtual-address-segment :> segment
    segment elf elf-section-headers elf-segment-sections :> sections
    address segment p_vaddr>> - segment p_offset>> + :> faddress
    sections [
        [ sh_offset>> dup ] [ sh_size>> + ] bi [a,b)
        faddress swap interval-contains?
    ] find nip ;

TYPED:: elf-segment-data ( elf: Elf32/64_Ehdr header: Elf32/64_Phdr -- uchar-array/f )
    header p_offset>> elf >c-ptr <displaced-alien>
    header p_filesz>> uchar <c-direct-array> ;

TYPED:: elf-section-data ( elf: Elf32/64_Ehdr header: Elf32/64_Shdr -- uchar-array/f )
    header sh_offset>> elf >c-ptr <displaced-alien>
    header sh_size>> uchar <c-direct-array> ;

TYPED:: elf-section-data-by-index ( elf: Elf32/64_Ehdr index -- header/f uchar-array/f )
    elf elf-section-headers     :> sections
    index sections nth          :> header
    elf header elf-section-data :> data
    header data ;

TYPED:: elf-section-name ( elf: Elf32/64_Ehdr header: Elf32/64_Shdr -- name: string )
    elf elf e_shstrndx>> elf-section-data-by-index nip >c-ptr :> section-names
    header sh_name>> section-names <displaced-alien> ascii alien>string ;

TYPED:: elf-section-data-by-name ( elf: Elf32/64_Ehdr name: string -- header/f uchar-array/f )
    elf elf-section-headers                      :> sections
    elf e_shstrndx>>                             :> ndx
    elf ndx sections nth elf-section-data >c-ptr :> section-names
    1 sections [
        sh_name>> section-names <displaced-alien> ascii alien>string name =
    ] find-from nip
    [ dup elf swap elf-section-data ] [ f f ] if* ;

TYPED:: elf-sections ( elf: Elf32/64_Ehdr -- sections )
    elf elf-section-headers                                   :> sections
    elf elf e_shstrndx>> elf-section-data-by-index nip >c-ptr :> section-names
    sections [
        [
            sh_name>> section-names <displaced-alien> ascii alien>string
        ] keep
    ] { } map>assoc ;

TYPED:: elf-symbols ( elf: Elf32/64_Ehdr section-data: uchar-array -- symbols )
    elf ".strtab" elf-section-data-by-name nip >c-ptr :> strings
    section-data [ >c-ptr ] [ length ] bi
    elf 64-bit?
    [ Elf64_Sym heap-size / Elf64_Sym <c-direct-array> ]
    [ Elf32_Sym heap-size / Elf32_Sym <c-direct-array> ] if
    [
        [
            st_name>> strings <displaced-alien> ascii alien>string
        ] keep
    ] { } map>assoc ;

! High level interface
TUPLE: elf elf-header ;
TUPLE: section name elf-header section-header data ;
TUPLE: segment elf-header program-header data ;
TUPLE: symbol name elf-header sym data ;

GENERIC: sections ( obj -- sections )

: <elf> ( c-ptr -- elf )
    elf-header elf boa ;

M:: elf sections ( elf -- sections )
    elf elf-header>> :> elf-header

    elf-header elf-sections
    [| name header |
        elf-header header elf-section-data :> data
        name elf-header header data section boa
    ] { } assoc>map ;

:: segments ( elf -- segments )
    elf elf-header>> :> elf-header

    elf-header elf-program-headers
    [| header |
        elf-header header elf-segment-data :> data
        elf-header header data segment boa
    ] { } map-as ;

M:: segment sections ( segment -- sections )
    segment program-header>> :> program-header
    segment elf-header>> :> elf-header

    program-header elf-header
    elf-section-headers
    elf-segment-sections
    [| header |
        elf-header header elf-section-name :> name
        elf-header header elf-section-data :> data
        name elf-header header data section boa
    ] { } map-as ;

:: symbols ( section -- symbols )
    section elf-header>> :> elf-header
    section data>> :> data

    elf-header data elf-symbols
    [| name sym |
        name elf-header sym f symbol boa
    ] { } assoc>map ;

:: symbol-data ( symbol -- data )
    symbol [ elf-header>> ] [ sym>> st_value>> ] bi virtual-address-segment :> segment
    symbol sym>> st_value>> segment p_vaddr>> - segment p_offset>> + :> faddress
    faddress symbol elf-header>> >c-ptr <displaced-alien>
    symbol sym>> st_size>> uchar <c-direct-array> ;

: find-section ( sections name -- section/f )
    '[ name>> _ = ] find nip ; inline

: find-symbol ( symbols name -- symbol/f )
    '[ name>> _ = ] find nip ; inline

: find-section-symbol ( sections section symbol -- symbol/f )
    [ find-section ] dip over [
        [ symbols ] dip find-symbol
    ] [ 2drop f ] if ;

: with-mapped-elf ( path quot -- )
    '[ address>> <elf> @ ] with-mapped-file-reader ; inline
