
USING: accessors classes.struct compiler.units continuations
definitions kernel locals sequences system tools.test unix.time
vocabs vocabs.loader words ;

IN: unix.time

! Model an older image whose shared unix.types vocabulary is loaded, but
! whose platform file must define a newly added type before timeval parses.
:: check-pending-platform-types ( -- ? )
    "unix.types." os name>> append :> platform
    [
        [
            "suseconds_t" "unix.types" lookup-word [ forget ] when*
            platform loaded-child-vocab-names [
                lookup-vocab f >>source-loaded? drop
            ] each
            "unix.time" reload
            platform lookup-vocab source-loaded?>> +done+ eq?
        ] [
            platform require
            "unix.time" reload
        ] finally
    ] with-compilation-unit ;

{ t } [ check-pending-platform-types ] unit-test

{ S{ timeval f 0 0 } } [ 0 make-timeval ] unit-test
{ S{ timeval f 1 234567 } } [ 1,234,567 make-timeval ] unit-test

{ S{ timespec f 0 0 } } [ 0 make-timespec ] unit-test
{ S{ timespec f 1 234567890 } } [ 1,234,567,890 make-timespec ] unit-test
