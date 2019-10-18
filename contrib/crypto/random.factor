USING: kernel math math-contrib sequences namespaces errors
hashtables words arrays parser compiler syntax io threads ;
IN: crypto
: make-bits ( quot numbits -- n | quot: -- 0/1 )
    0 -rot [ drop dup call rot 1 shift bitor swap ] each drop ;

DEFER: random-bits
: add-bit ( bit integer -- integer ) 1 shift bitor ;
: append-bits ( inta intb nbits -- int ) swapd shift bitor ;
: large-random-bits ( n -- int )
    #! random number with high bit and low bit enabled (odd)
    2 swap ^ [ random-int ] keep -1 shift 1 bitor bitor ;
: next-double ( -- f ) 53 random-bits 9007199254740992 /f ;


SYMBOL: last-keyboard
: crypto-random-int ( numbits -- integer )
    [ 
        millis last-keyboard set
        2 /  ! how many bits for repeat?
        0 swap
        [
            readln 2drop 100 random-int sleep 
            millis [ last-keyboard get - HEX: 3 bitand 2 append-bits ] keep
            last-keyboard set
        ] each
    ] with-scope ;

: auto-crypto-random-int ( numbits -- integer )
    [ 
        millis last-keyboard set
        0 swap
        [
            drop 10 random-int sleep 
            millis [ last-keyboard get - HEX: 1 bitand swap add-bit ] keep
            last-keyboard set
        ] each
    ] with-scope ;
    
IN: crypto

: 0count ( integer -- n ) 0 swap [ 0 = [ 1+ ] when ] each-bit ;
: 1count ( integer -- n ) 0 swap [ 1 = [ 1+ ] when ] each-bit ;

IN: crypto-internals
SYMBOL: a
SYMBOL: b
SYMBOL: c
SYMBOL: d
SYMBOL: n


IN: crypto

: bit-reverse-table
{
    HEX: 00 HEX: 80 HEX: 40 HEX: C0 HEX: 20 HEX: A0 HEX: 60 HEX: E0 HEX: 10 HEX: 90 HEX: 50 HEX: D0 HEX: 30 HEX: B0 HEX: 70 HEX: F0 
    HEX: 08 HEX: 88 HEX: 48 HEX: C8 HEX: 28 HEX: A8 HEX: 68 HEX: E8 HEX: 18 HEX: 98 HEX: 58 HEX: D8 HEX: 38 HEX: B8 HEX: 78 HEX: F8 
    HEX: 04 HEX: 84 HEX: 44 HEX: C4 HEX: 24 HEX: A4 HEX: 64 HEX: E4 HEX: 14 HEX: 94 HEX: 54 HEX: D4 HEX: 34 HEX: B4 HEX: 74 HEX: F4 
    HEX: 0C HEX: 8C HEX: 4C HEX: CC HEX: 2C HEX: AC HEX: 6C HEX: EC HEX: 1C HEX: 9C HEX: 5C HEX: DC HEX: 3C HEX: BC HEX: 7C HEX: FC 
    HEX: 02 HEX: 82 HEX: 42 HEX: C2 HEX: 22 HEX: A2 HEX: 62 HEX: E2 HEX: 12 HEX: 92 HEX: 52 HEX: D2 HEX: 32 HEX: B2 HEX: 72 HEX: F2 
    HEX: 0A HEX: 8A HEX: 4A HEX: CA HEX: 2A HEX: AA HEX: 6A HEX: EA HEX: 1A HEX: 9A HEX: 5A HEX: DA HEX: 3A HEX: BA HEX: 7A HEX: FA
    HEX: 06 HEX: 86 HEX: 46 HEX: C6 HEX: 26 HEX: A6 HEX: 66 HEX: E6 HEX: 16 HEX: 96 HEX: 56 HEX: D6 HEX: 36 HEX: B6 HEX: 76 HEX: F6 
    HEX: 0E HEX: 8E HEX: 4E HEX: CE HEX: 2E HEX: AE HEX: 6E HEX: EE HEX: 1E HEX: 9E HEX: 5E HEX: DE HEX: 3E HEX: BE HEX: 7E HEX: FE
    HEX: 01 HEX: 81 HEX: 41 HEX: C1 HEX: 21 HEX: A1 HEX: 61 HEX: E1 HEX: 11 HEX: 91 HEX: 51 HEX: D1 HEX: 31 HEX: B1 HEX: 71 HEX: F1
    HEX: 09 HEX: 89 HEX: 49 HEX: C9 HEX: 29 HEX: A9 HEX: 69 HEX: E9 HEX: 19 HEX: 99 HEX: 59 HEX: D9 HEX: 39 HEX: B9 HEX: 79 HEX: F9 
    HEX: 05 HEX: 85 HEX: 45 HEX: C5 HEX: 25 HEX: A5 HEX: 65 HEX: E5 HEX: 15 HEX: 95 HEX: 55 HEX: D5 HEX: 35 HEX: B5 HEX: 75 HEX: F5
    HEX: 0D HEX: 8D HEX: 4D HEX: CD HEX: 2D HEX: AD HEX: 6D HEX: ED HEX: 1D HEX: 9D HEX: 5D HEX: DD HEX: 3D HEX: BD HEX: 7D HEX: FD
    HEX: 03 HEX: 83 HEX: 43 HEX: C3 HEX: 23 HEX: A3 HEX: 63 HEX: E3 HEX: 13 HEX: 93 HEX: 53 HEX: D3 HEX: 33 HEX: B3 HEX: 73 HEX: F3 
    HEX: 0B HEX: 8B HEX: 4B HEX: CB HEX: 2B HEX: AB HEX: 6B HEX: EB HEX: 1B HEX: 9B HEX: 5B HEX: DB HEX: 3B HEX: BB HEX: 7B HEX: FB
    HEX: 07 HEX: 87 HEX: 47 HEX: C7 HEX: 27 HEX: A7 HEX: 67 HEX: E7 HEX: 17 HEX: 97 HEX: 57 HEX: D7 HEX: 37 HEX: B7 HEX: 77 HEX: F7 
    HEX: 0F HEX: 8F HEX: 4F HEX: CF HEX: 2F HEX: AF HEX: 6F HEX: EF HEX: 1F HEX: 9F HEX: 5F HEX: DF HEX: 3F HEX: BF HEX: 7F HEX: FF
} ; inline

