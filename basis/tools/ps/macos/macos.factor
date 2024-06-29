! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data alien.syntax arrays
assocs byte-arrays classes.struct continuations fry grouping
kernel libc literals math sequences splitting strings system
system-info.macos tools.ps unix unix.sysctl unix.time
unix.types ;

QUALIFIED-WITH: alien.c-types c

IN: tools.ps.macos

<PRIVATE

: system-type ( -- str ) { 1 1 } sysctl-query-string ;
: system-release ( -- str ) { 1 2 } sysctl-query-string ;
: system-revision ( -- str ) { 1 3 } sysctl-query-string ;
: system-version ( -- str ) { 1 4 } sysctl-query-string ;
: max-vnodes ( -- n ) { 1 5 } sysctl-query-uint ;
: max-processes ( -- n ) { 1 6 } sysctl-query-uint ;
: max-open-files ( -- n ) { 1 7 } sysctl-query-uint ;
: max-arguments ( -- args ) { 1 8 } sysctl-query-uint ;
: system-security-level ( -- n ) { 1 9 } sysctl-query-uint ;
: hostname ( -- str ) { 1 10 } sysctl-query-string ;

: sysctl-query-bytes ( seq -- n )
    [ int >c-array ] [ length ] bi f 0 uint <ref>
    [ f 0 sysctl io-error ] keep uint deref ;

STRUCT: _pcred
    { pc_lock char[72] }
    { pc_ucred void* }
    { p_ruid uid_t }
    { p_svuid uid_t }
    { p_rgid gid_t }
    { p_svgid gid_t }
    { p_refcnt int } ;

STRUCT: _ucred
    { cr_ref int32_t }
    { cr_uid uid_t }
    { cr_ngroups c:short }
    { cr_groups gid_t[16] } ;

STRUCT: vmspace
    { dummy int32_t }
    { dummy2 caddr_t }
    { dummy3 int32_t[5] }
    { dummy4 caddr_t[3] } ;

TYPEDEF: int32_t segsz_t
TYPEDEF: uint32_t fixpt_t
TYPEDEF: uint64_t u_quad_t
TYPEDEF: uint32_t sigset_t

STRUCT: itimerval
    { it_interval timeval }
    { it_value timeval } ;

STRUCT: extern_proc
    { __p_starttime timeval }
    { p_vmspace void* }
    { p_sigacts void* }
    { p_flag int }
    { p_stat char }
    { p_pid pid_t }
    { p_oppid pid_t }
    { p_dupfd int }
    { user_stack caddr_t }
    { exit_thread void* }
    { p_debugger int }
    { sigwait boolean_t }
    { p_estcpu uint }
    { p_cpticks int }
    { p_pctcpu fixpt_t }
    { p_wchan void* }
    { p_wmesg void* }
    { p_swtime uint }
    { p_slptime uint }
    { p_realtimer itimerval }
    { p_rtime timeval }
    { p_uticks u_quad_t }
    { p_sticks u_quad_t }
    { p_iticks u_quad_t }
    { p_traceflag int }
    { p_tracep void* }
    { p_siglist int }
    { p_textvp void* }
    { p_holdcnt int }
    { p_sigmask sigset_t }
    { p_sigignore sigset_t }
    { p_sigcatch sigset_t }
    { p_priority uchar }
    { p_usrpri uchar }
    { p_nice char }
    { p_comm char[16] }
    { p_pgrp void* }
    { p_addr void* }
    { p_xstat ushort }
    { p_acflag ushort }
    { p_ru void* } ;

STRUCT: kinfo_proc
    { kp_proc extern_proc }
    { e_paddr void* }
    { e_sess void* }
    { e_pcred _pcred }
    { e_ucred _ucred }
    { e_vm vmspace }
    { e_ppid pid_t }
    { e_pgid pid_t }
    { e_joc c:short }
    { e_tdev dev_t }
    { e_tpgid pid_t }
    { e_tsess void* }
    { e_mesg char[8] }
    { e_xsize segsz_t }
    { e_xrssize c:short }
    { e_xccount c:short }
    { e_xswrss c:short }
    { e_flag int32_t }
    { e_login char[12] }
    { e_spare int32_t[4] } ;

: head-split-skip ( seq n quot: ( elt -- ? ) -- pieces )
    [ dup 0 >= ] swap '[
        [ _ [ trim-head-slice ] [ split1-when-slice ] bi ]
        [ 1 - rot ] bi*
    ] produce 2nip ; inline

: args ( pid -- args )
    [ 1 49 ] dip 0 4array max-arguments sysctl-query
    4 cut-slice swap >byte-array uint deref
    [ zero? ] head-split-skip [ >string ] map ;

: procs ( -- seq )
    { 1 14 0 0 } dup sysctl-query-bytes sysctl-query
    kinfo_proc struct-size group
    [ kinfo_proc memory>struct ] map ;

: ps-arg ( kp_proc -- arg )
    [ p_pid>> args rest join-words ] [
        drop p_comm>> 0 over index [ head ] when* >string
    ] recover ;

PRIVATE>

M: macos ps
    procs [ kp_proc>> p_pid>> 0 > ] filter
    [ kp_proc>> [ p_pid>> ] [ ps-arg ] bi ] map>alist ;
