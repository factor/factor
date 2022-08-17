USING: alien.libraries.finder alien.libraries.finder.macosx
alien.libraries.finder.macosx.private sequences tools.test ;

{
    {
        f
        f
        f
        f
        T{ framework-info f "Location" "Name.framework/Name" "Name" f f }
        T{ framework-info f "Location" "Name.framework/Name_suffix" "Name" f "suffix" }
        f
        f
        T{ framework-info f "Location" "Name.framework/Versions/A/Name" "Name" "A" f }
        T{ framework-info f "Location" "Name.framework/Versions/A/Name_suffix" "Name" "A" "suffix" }
    }
} [
    {
        "broken/path"
        "broken/path/_suffix"
        "Location/Name.framework"
        "Location/Name.framework/_suffix"
        "Location/Name.framework/Name"
        "Location/Name.framework/Name_suffix"
        "Location/Name.framework/Versions"
        "Location/Name.framework/Versions/A"
        "Location/Name.framework/Versions/A/Name"
        "Location/Name.framework/Versions/A/Name_suffix"
    } [ make-framework-info ] map
] unit-test

{
    {
        "/usr/lib/libSystem.dylib"
        "/System/Library/Frameworks/System.framework/System"
    }
} [
    {
        "libSystem.dylib"
        "System.framework/System"
    } [ dyld-find ] map
] unit-test

{ t } [ "m" find-library "libm.dylib" subseq-of? ] unit-test
{ t } [ "c" find-library "libc.dylib" subseq-of? ] unit-test
{ t } [ "bz2" find-library "libbz2.dylib" subseq-of? ] unit-test
{ t } [ "AGL" find-library "AGL.framework" subseq-of? ] unit-test
