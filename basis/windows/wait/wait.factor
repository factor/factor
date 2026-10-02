! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax windows.types ;
IN: windows.wait

! Native callbacks post IOCP packets; they never enter the Factor VM.
LIBRARY: factor
FUNCTION-ALIAS: register-handle-wait void* factor_register_process_wait
    ( HANDLE handle, HANDLE port, ULONG_PTR key )
FUNCTION-ALIAS: unregister-handle-wait BOOL factor_unregister_process_wait
    ( void* wait )
