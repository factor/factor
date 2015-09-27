USING: byte-arrays.hex io.encodings.binary io.streams.byte-array
midi.private sequences tools.test ;
IN: midi

! variable-width numbers
{
    {
        0x00
        0x40
        0x7f
        0x80
        0x2000
        0x3fff
        0x4000
        0x100000
        0x1fffff
        0x200000
        0x08000000
        0x0fffffff
    }
} [
    {
        HEX{ 00 }
        HEX{ 40 }
        HEX{ 7f }
        HEX{ 81 00 }
        HEX{ C0 00 }
        HEX{ ff 7f }
        HEX{ 81 80 00 }
        HEX{ C0 80 00 }
        HEX{ ff ff 7f }
        HEX{ 81 80 80 00 }
        HEX{ C0 80 80 00 }
        HEX{ ff ff ff 7f }
    } [ binary [ read-number ] with-byte-reader ] map
] unit-test

{
    {
        HEX{ 00 }
        HEX{ 40 }
        HEX{ 7f }
        HEX{ 81 00 }
        HEX{ C0 00 }
        HEX{ ff 7f }
        HEX{ 81 80 00 }
        HEX{ C0 80 00 }
        HEX{ ff ff 7f }
        HEX{ 81 80 80 00 }
        HEX{ C0 80 80 00 }
        HEX{ ff ff ff 7f }
    }
} [
    {
        0x00
        0x40
        0x7f
        0x80
        0x2000
        0x3fff
        0x4000
        0x100000
        0x1fffff
        0x200000
        0x08000000
        0x0fffffff
    } [ binary [ write-number ] with-byte-writer ] map
] unit-test

! format: 0
{
    T{ midi
        { header
            T{ midi-header
                { format 0 }
                { #chunks 1 }
                { division 96 }
            }
        }
        { chunks
            {
                T{ midi-track
                    { events
                        {
                            T{ meta-event
                                { delta 0 }
                                { name "time-signature" }
                                { value
                                    H{
                                        { "clocks-per-tick" 24 }
                                        { "denominator" 4 }
                                        { "numerator" 4 }
                                        {
                                            "notated-32nd-notes-per-beat"
                                            8
                                        }
                                    }
                                }
                            }
                            T{ meta-event
                                { delta 0 }
                                { name "set-tempo" }
                                { value 500000 }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "program-change" }
                                { value
                                    H{
                                        { "program" 5 }
                                        { "channel" 0 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "program-change" }
                                { value
                                    H{
                                        { "program" 46 }
                                        { "channel" 1 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "program-change" }
                                { value
                                    H{
                                        { "program" 70 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 48 }
                                        { "velocity" 96 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 60 }
                                        { "velocity" 96 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 96 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 67 }
                                        { "velocity" 64 }
                                        { "channel" 1 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 96 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 76 }
                                        { "velocity" 32 }
                                        { "channel" 0 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 192 }
                                { name "note-off" }
                                { value
                                    H{
                                        { "note" 48 }
                                        { "velocity" 64 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-off" }
                                { value
                                    H{
                                        { "note" 60 }
                                        { "velocity" 64 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-off" }
                                { value
                                    H{
                                        { "note" 67 }
                                        { "velocity" 64 }
                                        { "channel" 1 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-off" }
                                { value
                                    H{
                                        { "note" 76 }
                                        { "velocity" 64 }
                                        { "channel" 0 }
                                    }
                                }
                            }
                            T{ meta-event
                                { delta 0 }
                                { name "end-of-track" }
                                { value t }
                            }
                        }
                    }
                }
            }
        }
    }
} [
    HEX{
        4D 54 68 64
            00 00 00 06
            00 00
            00 01
            00 60

        4D 54 72 6B
            00 00 00 3B
            00 FF 58 04 04 02 18 08
            00 FF 51 03 07 A1 20
            00 C0 05
            00 C1 2E
            00 C2 46
            00 92 30 60
            00 3C 60
            60 91 43 40
            60 90 4C 20
            81 40 82 30 40
            00 3C 40
            00 81 43 40
            00 80 4C 40
            00 FF 2F 00
    } >midi
] unit-test

! format: 1
{
    T{ midi
        { header
            T{ midi-header
                { format 1 }
                { #chunks 4 }
                { division 96 }
            }
        }
        { chunks
            {
                T{ midi-track
                    { events
                        {
                            T{ meta-event
                                { delta 0 }
                                { name "time-signature" }
                                { value
                                    H{
                                        { "clocks-per-tick" 24 }
                                        { "denominator" 4 }
                                        { "numerator" 4 }
                                        {
                                            "notated-32nd-notes-per-beat"
                                            8
                                        }
                                    }
                                }
                            }
                            T{ meta-event
                                { delta 0 }
                                { name "set-tempo" }
                                { value 500000 }
                            }
                            T{ meta-event
                                { delta 384 }
                                { name "end-of-track" }
                                { value t }
                            }
                        }
                    }
                }
                T{ midi-track
                    { events
                        {
                            T{ midi-event
                                { delta 0 }
                                { name "program-change" }
                                { value
                                    H{
                                        { "program" 5 }
                                        { "channel" 0 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 192 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 76 }
                                        { "velocity" 32 }
                                        { "channel" 0 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 192 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 76 }
                                        { "velocity" 0 }
                                        { "channel" 0 }
                                    }
                                }
                            }
                            T{ meta-event
                                { delta 0 }
                                { name "end-of-track" }
                                { value t }
                            }
                        }
                    }
                }
                T{ midi-track
                    { events
                        {
                            T{ midi-event
                                { delta 0 }
                                { name "program-change" }
                                { value
                                    H{
                                        { "program" 46 }
                                        { "channel" 1 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 96 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 67 }
                                        { "velocity" 64 }
                                        { "channel" 1 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 288 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 67 }
                                        { "velocity" 0 }
                                        { "channel" 1 }
                                    }
                                }
                            }
                            T{ meta-event
                                { delta 0 }
                                { name "end-of-track" }
                                { value t }
                            }
                        }
                    }
                }
                T{ midi-track
                    { events
                        {
                            T{ midi-event
                                { delta 0 }
                                { name "program-change" }
                                { value
                                    H{
                                        { "program" 70 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 48 }
                                        { "velocity" 96 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 60 }
                                        { "velocity" 96 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 384 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 48 }
                                        { "velocity" 0 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ midi-event
                                { delta 0 }
                                { name "note-on" }
                                { value
                                    H{
                                        { "note" 60 }
                                        { "velocity" 0 }
                                        { "channel" 2 }
                                    }
                                }
                            }
                            T{ meta-event
                                { delta 0 }
                                { name "end-of-track" }
                                { value t }
                            }
                        }
                    }
                }
            }
        }
    }
} [
    HEX{
        4D 54 68 64
            00 00 00 06
            00 01
            00 04
            00 60

        4D 54 72 6B
            00 00 00 14
            00 FF 58 04 04 02 18 08
            00 FF 51 03 07 A1 20
            83 00 FF 2F 00

        4D 54 72 6B
            00 00 00 10
            00 C0 05
            81 40 90 4C 20
            81 40 4C 00
            00 FF 2F 00

        4D 54 72 6B
            00 00 00 0F
            00 C1 2E
            60 91 43 40
            82 20 43 00
            00 FF 2F 00

        4D 54 72 6B
            00 00 00 15
            00 C2 46
            00 92 30 60
            00 3C 60
            83 00 30 00
            00 3C 00
            00 FF 2F 00
    } >midi
] unit-test
