USING: alien.c-types alien.syntax continuations kernel shell system ;
IN: shell.unix

LIBRARY: factor
FUNCTION: void factor_begin_ignore_console_signals ( )
FUNCTION: void factor_end_ignore_console_signals ( )

M: unix with-foreground-interrupts
    factor_begin_ignore_console_signals
    [ call-next-method ] [ factor_end_ignore_console_signals ] finally ;
