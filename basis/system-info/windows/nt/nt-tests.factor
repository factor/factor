USING: math.order strings system-info.backend
system-info.windows system-info.windows.nt
tools.test ;
IN: system-info.windows.nt.tests

[ t ] [ cpus 0 1024 between? ] unit-test
[ t ] [ username string? ] unit-test
