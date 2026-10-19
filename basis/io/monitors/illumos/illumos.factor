! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.backend io.monitors io.monitors.bsd system ;
IN: io.monitors.illumos

M: illumos init-monitors init-bsd-monitors ;
M: illumos dispose-monitors dispose-bsd-monitors ;
M: illumos (monitor) <bsd-monitor> ;
