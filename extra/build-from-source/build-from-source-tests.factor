! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test build-from-source ;
IN: build-from-source.tests

{ "v3.11.0" } [
    {
        "v3.10.10"
        "v3.11.0"
        "v3.11.0a1"
        "v3.11.0a2"
        "v3.11.0a7"
        "v3.11.0b1"
        "v3.11.0b5"
    } tags>latest-python3
] unit-test

{ "v3.10.10" } [
    {
        "v3.10.10"
        "v3.11.0a1"
        "v3.11.0a2"
    } tags>latest-python3
] unit-test

{ "v3.11.0b5" } [
    {
        "v3.10.10"
        "v3.11.0a1"
        "v3.11.0a2"
        "v3.11.0a7"
        "v3.11.0b1"
        "v3.11.0b5"
    } tags>latest-python3
] unit-test

{ "v3.11.0rc5" } [
    {
        "v3.10.10"
        "v3.11.0a1"
        "v3.11.0a2"
        "v3.11.0a7"
        "v3.11.0b1"
        "v3.11.0b5"
        "v3.11.0rc5"
        "v3.11.0rc1"
    } tags>latest-python3
] unit-test

{ "v3.11.0" } [
    {
        "v3.10.10"
        "v3.11.0"
        "v3.11.0a1"
        "v3.11.0a2"
        "v3.11.0a7"
        "v3.11.0b1"
        "v3.11.0b5"
        "v3.11.0rc5"
        "v3.11.0rc1"
    } tags>latest-python3
] unit-test
