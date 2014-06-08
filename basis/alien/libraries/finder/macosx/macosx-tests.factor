
USING: alien.libraries.finder
alien.libraries.finder.macosx.private sequences tools.test ;

IN: alien.libraries.finder.macosx

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

{ t } [ "libm.dylib" "m" find-library subseq? ] unit-test
{ t } [ "libc.dylib" "c" find-library subseq? ] unit-test
{ t } [ "libbz2.dylib" "bz2" find-library subseq? ] unit-test
{ t } [ "AGL.framework" "AGL" find-library subseq? ] unit-test
