! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: threads
USING: errors kernel lists namespaces sequences ;

: in-thread ( quot -- )
    #! Execute a quotation in a co-operative thread. The
    #! quotation begins executing immediately, and execution
    #! after the 'in-thread' call in the original thread
    #! resumes when the quotation yields, either due to blocking
    #! I/O or an explicit call to 'yield'.
    [
        schedule-thread
        ! Clear stacks since we never go up from this point
        [ ] set-catchstack
        { } set-callstack
        try
        stop
    ] callcc0 drop ;
