USING: calendar formatting kernel tools.test tzinfo ;

{
    "Sun Oct 27 01:00:00 2002"
    "Sun Oct 27 01:50:00 2002"
} [
    2002 10 27 1 0 0 -8 hours <timestamp> ! PST
    [ "%c" strftime ]
    [
        10 minutes time- ! to PDT
        "vocab:tzinfo/tests/US-Pacific" file>tzinfo normalize
        "%c" strftime
    ] bi
] unit-test
