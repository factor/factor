! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.backend io.monitors io.monitors.bsd system ;
IN: io.monitors.freebsd

M: freebsd init-monitors init-bsd-monitors ;
M: freebsd dispose-monitors dispose-bsd-monitors ;
M: freebsd (monitor) <bsd-monitor> ;

freebsd set-io-backend
