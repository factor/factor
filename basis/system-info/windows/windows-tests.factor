USING: math.order strings system-info.backend
system-info.windows tools.test ;
IN: system-info.windows.tests

[ t ] [ cpus 0 1024 between? ] unit-test
[ t ] [ username string? ] unit-test
