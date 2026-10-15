! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.backend io.monitors io.monitors.bsd system ;
IN: io.monitors.netbsd

M: netbsd init-monitors init-bsd-monitors ;
M: netbsd dispose-monitors dispose-bsd-monitors ;
M: netbsd (monitor) <bsd-monitor> ;

netbsd set-io-backend
