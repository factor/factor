USING: math math.order strings system-info.windows tools.test
system system-info ;

{ t } [ cpus integer? ] unit-test

cpu x86.32 = [
    { t } [ username string? ] unit-test
] unless
