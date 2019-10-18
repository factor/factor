: words-not-primitives ( -- list )
    words [ worddef primitive? not ] subset ;

: dump-image ( -- )
    compile-all
    words-not-primitives [
        dup worddef dup compiled? [
            swap >str .
            class-of .
            "define" print
        ] [
            drop see
        ] ifte
    ] each ;

: dump-image-file ( file -- )
    <namespace> [
        <filecw> @stdio
        dump-image
        $stdio fclose
    ] bind ;

: dump-boot-image ( -- )
    "factor/boot.fasl" dump-image-file ;
