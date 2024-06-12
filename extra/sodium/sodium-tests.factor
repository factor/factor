! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays io.encodings.string io.encodings.utf8 kernel math
sequences sodium tools.test ;
IN: sodium.tests

{ t } [
    "Encrypted message" dup utf8 encode
    crypto-box-nonce 2 [ crypto-box-keypair 2array ] times
    [ [ first ] [ second ] bi* crypto-box-easy ] 3check
    [ first ] [ second ] bi* crypto-box-open-easy utf8 decode =
] unit-test

{ t } [
    "Signature verification test" utf8 encode
    crypto-sign-keypair
    [ nip crypto-sign ]
    [ drop crypto-sign-verify ] 3bi
] unit-test

! https://github.com/sqrldev/sqrl-test-vectors/blob/master/vectors/enhash-vectors.txt
CONSTANT: base64-tests {
    ""
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    "_FHmfDKg6e6rE-hV-1dGCrtbmVUnQtByMvqkCXxdfuU"
    "AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE"
    "vhFHvj4Qdlv8VAsnTdRJ_YsdctXQpJ5Elh9aM-hI2yQ"
    "__________________________________________8"
    "yyHN-LfEkKdKNRkuUHWvpzYYJy3FhVJQusPGpvlGWsE"
    "VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVU"
    "bk7GPoNy_qWdAjZ-gF5GHmioZ0ZM04a8wQBvwxSQWnE"
    "qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqo"
    "TCDPMl3crNzjLnd94BiaVg0wV63oJ9TyKIu3gS33MA0"
    "hA3Dw5BPbcuJQYQYRAukKBYa1u9m4pV5jtEpQ1DDtHk"
    "EGisR5HKQFtLvqTcbZu7Xvl9_uySHlFaiaLxM5V5Ta0"
    "3FI8xwyoFAU1eWsnAdAUh3D-SS-XiiWdiIGw7mGY2qk"
    "chvqBddUlaePrIhevV1ap48P4cKR6B60i4oTnQ1BRuU"
    "0jtFpgpHqvzcfSdKXJ5f8hXRAi0Ytf3K7zlXWN6dies"
    "xH3LNXP0-SJnP-jtQaGXeIH3ZTK_6B-Vu_IT6wz4TjM"
    "Wf5wO411DCEe53k7lPp_dh5pp06AEUCNpEXCi5KG0ro"
    "iHNsJLKJ3InnB4a3D7nwzLGx-z4HXxXnnX6Ppp4fgRE"
    "0g9euYTG7974KIhW6en7BP6-2S7u_9qabd1V-7SDIOU"
    "-TAyGNEEkNuFceonDUF_Nz20RnlyTVpeDp92KGkCRxs"
    "d1podenEZmoVmyP7gZ8XxAKW82jSt4QiX3mC4JnM_K8"
    "rNZG4IAkyQAmKcoCQKOEyC34KAaU-wPA_2NY_5y7-Q4"
    "8QROWCEzP0Ni2MwmlVKffsUm5MlX-pzxX03Q9D0zsYw"
    "BK2JN4_78CwB3MSJjFEAwHQX-1efCOYNAvKn8-z4ALw"
    "be30E76EBlTd_DW66KBUYZqYYhSr1eHhv-UMKrVHJOA"
    "nrZb5PYuff38xgEP4dg6xpBzIk6XHauBFYqPD1KOu6g"
    "Z_H_qwKAcqOilZTHIZKHhXLlRdWfty24UWWq-28a1wc"
    "5CezCWqQX09B_MllxHQNmBE2080BADIBoMtqc5LZNfc"
}

{ t } [
    base64-tests [ dup sodium-base64>bin sodium-bin>base64 = ] all?
] unit-test
