!"Reboot test." print
!
!"reboot-test" get [
!    t "reboot-test" set
!
!    <namespace> [
!        1024 <string-output-stream> "stdio" set
!
!        words [ worddef primitive? not ] subset [ see ] each
!
!        "stdio" get stream>str dup parse
!    ] bind
!
!    call
!
!    "compile" get [ compile-all ] when
!
!    all-tests
!
!    f "reboot-test" set
!] unless
!
!"Reboot test done." print
