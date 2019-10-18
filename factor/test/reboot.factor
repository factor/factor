"Reboot test." print

$reboot-test [
    t @reboot-test

    <namespace> [
        <string-output-stream> @stdio

        words [ worddef primitive? not ] subset [ see ] each

        $stdio stream>str dup parse
    ] bind

    call

    $compile [ compile-all ] when

    all-tests

    f @reboot-test
] unless

"Reboot test done." print
