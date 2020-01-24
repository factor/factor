USING: bittorrent io.sockets tools.test ;

{
    {
        T{ inet4 { host "127.0.0.1" } { port 80 } }
        T{ inet4 { host "1.1.1.1" } { port 443 } }
    }
} [
    B{ 127 0 0 1 0x00 0x50 1 1 1 1 0x01 0xbb } parse-peer4s
] unit-test
