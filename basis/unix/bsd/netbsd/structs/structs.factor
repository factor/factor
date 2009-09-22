! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax unix.time unix.types
unix.types.netbsd classes.struct ;
IN: unix

STRUCT: sockaddr_storage
    { ss_len __uint8_t }
    { ss_family sa_family_t }
    { __ss_pad1 { char _SS_PAD1SIZE } }
    { __ss_align __int64_t }
    { __ss_pad2 { char _SS_PAD2SIZE } } ;

STRUCT: exit_struct
    { e_termination uint16_t }
    { e_exit uint16_t } ;

STRUCT: utmpx
    { ut_user { char _UTX_USERSIZE } }
    { ut_id   { char _UTX_IDSIZE   } }
    { ut_line { char _UTX_LINESIZE } }
    { ut_host { char _UTX_HOSTSIZE } }
    { ut_session uint16_t }
    { ut_type uint16_t }
    { ut_pid pid_t }
    { ut_exit exit_struct }
    { ut_ss sockaddr_storage }
    { ut_tv timeval }
    { ut_pad { uint32_t 10 } } ;

