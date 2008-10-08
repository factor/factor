! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
IN: unix

C-STRUCT: sockaddr_storage
    { "__uint8_t" "ss_len" }
    { "sa_family_t" "ss_family" }
    { { "char" _SS_PAD1SIZE } "__ss_pad1" }
    { "__int64_t" "__ss_align" }
    { { "char" _SS_PAD2SIZE } "__ss_pad2" } ;

C-STRUCT: exit_struct
    { "uint16_t" "e_termination" }
    { "uint16_t" "e_exit" } ;

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

