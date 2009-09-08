! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax unix.time classes.struct ;
IN: unix

STRUCT: sockaddr_storage
    { ss_len __uint8_t }
    { ss_family sa_family_t }
    { __ss_pad1 { "char" _SS_PAD1SIZE } }
    { __ss_align __int64_t }
    { __ss_pad2 { "char" _SS_PAD2SIZE } } ;

STRUCT: exit_struct
    { e_termination uint16_t }
    { e_exit uint16_t } ;

C-STRUCT: utmpx
    { { "char" _UTX_USERSIZE } "ut_user" }
    { { "char" _UTX_IDSIZE } "ut_id" }
    { { "char" _UTX_LINESIZE } "ut_line" }
    { { "char" _UTX_HOSTSIZE } "ut_host" }
    { "uint16_t" "ut_session" }
    { "uint16_t" "ut_type" }
    { "pid_t" "ut_pid" }
    { "exit_struct" "ut_exit" }
    { "sockaddr_storage" "ut_ss" }
    { "timeval" "ut_tv" }
    { { "uint32_t" 10 } "ut_pad" } ;

