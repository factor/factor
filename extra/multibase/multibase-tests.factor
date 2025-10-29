USING: kernel multibase sequences tools.test ;

{ t } [
    {
        "F4D756C74696261736520697320617765736F6D6521205C6F2F" ! base16 F
        "BJV2WY5DJMJQXGZJANFZSAYLXMVZW63LFEEQFY3ZP"           ! base32 B
        "K3IY8QKL64VUGCX009XWUHKF6GBBTS3TVRXFRA5R"            ! base36 K
        "RTZ9:VDNEDHECDZC+ED944A4FVQEF$DK84%UB21"             ! base45 R
        "zYAjKoNbau5KiqmHPmSxYCvn66dA1vLmwbt"                 ! base58 z
        "MTXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw=="               ! base64 M
    } [
        multibase> B{
            77 117 108 116 105 98 97 115 101 32 105 115 32 97
            119 101 115 111 109 101 33 32 92 111 47
        } =
    ] all?
] unit-test

{ t } [
    B{
        77 117 108 116 105 98 97 115 101 32 105 115 32 97
        119 101 115 111 109 101 33 32 92 111 47
    } {
        "base16upper"
        "base32upper"
        "base36upper"
        "base45"
        "base58btc"
        "base64pad"
    } [ >multibase ] with map
    {
        "F4D756C74696261736520697320617765736F6D6521205C6F2F" ! base16 F
        "BJV2WY5DJMJQXGZJANFZSAYLXMVZW63LFEEQFY3ZP"           ! base32 B
        "K3IY8QKL64VUGCX009XWUHKF6GBBTS3TVRXFRA5R"            ! base36 K
        "RTZ9:VDNEDHECDZC+ED944A4FVQEF$DK84%UB21"             ! base45 R
        "zYAjKoNbau5KiqmHPmSxYCvn66dA1vLmwbt"                 ! base58 z
        "MTXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw=="               ! base64 M
    } [ sequence= ] 2all?
] unit-test
