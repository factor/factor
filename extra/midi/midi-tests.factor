USING: io.encodings.binary io.streams.byte-array midi
midi.private sequences tools.test ;

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
        B{ 0x00 }
        B{ 0x40 }
        B{ 0x7f }
        B{ 0x81 0x00 }
        B{ 0xC0 0x00 }
        B{ 0xff 0x7f }
        B{ 0x81 0x80 0x00 }
        B{ 0xC0 0x80 0x00 }
        B{ 0xff 0xff 0x7f }
        B{ 0x81 0x80 0x80 0x00 }
        B{ 0xC0 0x80 0x80 0x00 }
        B{ 0xff 0xff 0xff 0x7f }
    } [ binary [ read-number ] with-byte-reader ] map
] unit-test

{
    {
        B{ 0x00 }
        B{ 0x40 }
        B{ 0x7f }
        B{ 0x81 0x00 }
        B{ 0xC0 0x00 }
        B{ 0xff 0x7f }
        B{ 0x81 0x80 0x00 }
        B{ 0xC0 0x80 0x00 }
        B{ 0xff 0xff 0x7f }
        B{ 0x81 0x80 0x80 0x00 }
        B{ 0xC0 0x80 0x80 0x00 }
        B{ 0xff 0xff 0xff 0x7f }
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
    B{
        0x4D 0x54 0x68 0x64
            0x00 0x00 0x00 0x06
            0x00 0x00
            0x00 0x01
            0x00 0x60

        0x4D 0x54 0x72 0x6B
            0x00 0x00 0x00 0x3B
            0x00 0xFF 0x58 0x04 0x04 0x02 0x18 0x08
            0x00 0xFF 0x51 0x03 0x07 0xA1 0x20
            0x00 0xC0 0x05
            0x00 0xC1 0x2E
            0x00 0xC2 0x46
            0x00 0x92 0x30 0x60
            0x00 0x3C 0x60
            0x60 0x91 0x43 0x40
            0x60 0x90 0x4C 0x20
            0x81 0x40 0x82 0x30 0x40
            0x00 0x3C 0x40
            0x00 0x81 0x43 0x40
            0x00 0x80 0x4C 0x40
            0x00 0xFF 0x2F 0x00
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
    B{
        0x4D 0x54 0x68 0x64
            0x00 0x00 0x00 0x06
            0x00 0x01
            0x00 0x04
            0x00 0x60

        0x4D 0x54 0x72 0x6B
            0x00 0x00 0x00 0x14
            0x00 0xFF 0x58 0x04 0x04 0x02 0x18 0x08
            0x00 0xFF 0x51 0x03 0x07 0xA1 0x20
            0x83 0x00 0xFF 0x2F 0x00

        0x4D 0x54 0x72 0x6B
            0x00 0x00 0x00 0x10
            0x00 0xC0 0x05
            0x81 0x40 0x90 0x4C 0x20
            0x81 0x40 0x4C 0x00
            0x00 0xFF 0x2F 0x00

        0x4D 0x54 0x72 0x6B
            0x00 0x00 0x00 0x0F
            0x00 0xC1 0x2E
            0x60 0x91 0x43 0x40
            0x82 0x20 0x43 0x00
            0x00 0xFF 0x2F 0x00

        0x4D 0x54 0x72 0x6B
            0x00 0x00 0x00 0x15
            0x00 0xC2 0x46
            0x00 0x92 0x30 0x60
            0x00 0x3C 0x60
            0x83 0x00 0x30 0x00
            0x00 0x3C 0x00
            0x00 0xFF 0x2F 0x00
    } >midi
] unit-test
