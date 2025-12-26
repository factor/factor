! Copyright (C) 2025 Zoltán Kéri <z@zolk3ri.name>
! See https://factorcode.org/license.txt for BSD license.
!
! Cryptographic utility functions
!
! This vocabulary provides common utilities for cryptographic
! implementations that require careful handling to avoid
! side-channel vulnerabilities.

USING: kernel locals math math.bitwise sequences ;
IN: crypto.utils

! Constant-time byte sequence comparison
! Compares two sequences in constant time to prevent timing attacks.
! Always examines all bytes regardless of where differences occur.
:: constant-time= ( a b -- ? )
    a length b length = [
        0 a b [ bitxor bitor ] 2each 0 =
    ] [ f ] if ;

! Constant-time zero check
! Returns t if all bytes in the sequence are zero.
! Always examines all bytes regardless of where non-zero bytes occur.
: constant-time-zero? ( seq -- ? )
    0 [ bitor ] reduce 0 = ;

! Constant-time selection between two integers
! If flag is 1, returns a. If flag is 0, returns b.
! Flag MUST be 0 or 1. Other values produce undefined results.
! This avoids branching by using arithmetic masking.
:: constant-time-select ( flag a b -- a/b )
    flag neg :> mask
    a mask bitand
    b mask bitnot bitand
    bitor ;
