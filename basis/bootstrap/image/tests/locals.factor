USING: accessors arrays assocs bootstrap.image.private compiler.units kernel
locals locals.types namespaces sequences tools.test vectors words ;
IN: bootstrap.image.tests.locals

:: serialized-lexicals? ( seed expected -- ? )
    [
        seed 1vector bootstrapping-image set
        H{ } clone objects set
        H{ } clone sub-primitives set
        emit-uninterned-words
        expected [ lookup-object >boolean ] all?
    ] with-scope ;

{ t } [
    [ "value" <local> dup 1array serialized-lexicals? ] with-compilation-unit
] unit-test

! Either half can be the only initial reference; the other's word is
! discovered while serializing properties. The reader/writer link cycles.
:: serialized-mutable? ( writer? -- ? )
    "value" <local-reader> dup <local-writer> :> ( reader writer )
    writer? writer reader ? reader writer 2array serialized-lexicals? ;

{ t } [ [ f serialized-mutable? ] with-compilation-unit ] unit-test
{ t } [ [ t serialized-mutable? ] with-compilation-unit ] unit-test
