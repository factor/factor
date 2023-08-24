USING: interpolate io io.encodings.ascii io.files io.files.temp
io.launcher io.streams.string kernel sequences system ;
IN: alien.remote-control.tests

: compile-file ( contents -- )
    "test.c" ascii set-file-contents
    { "gcc" "-I../" "-L.." "-lfactor" "test.c" }
    os macosx? cpu x86.64? and [ "-m64" suffix ] when
    try-process ;

: run-test ( -- line )
    os windows? "a.exe" "a.out" ?
    ascii [ readln ] with-process-reader ;

:: test-embedding ( code -- line )
    image-path :> image

    [
        [I
#include <vm/master.h>
#include <stdio.h>
#include <stdbool.h>

int main(int argc, char **argv)
{
    F_PARAMETERS p;
    default_parameters(&p);
    p.image_path = STRING_LITERAL("${image}");
    init_factor(&p);
    start_embedded_factor(&p);
    ${code}
    printf("Done.\n");
    return 0;
}
        I]
    ] with-string-writer
    [ compile-file ] with-temp-directory
    [ run-test ] with-temp-directory ;

! [ "Done." ] [ "" test-embedding ] unit-test

! [ "Done." ] [ "factor_yield();" test-embedding ] unit-test
