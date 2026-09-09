! Local handle configuration only; these tests never perform a transfer.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.strings alien.syntax byte-arrays continuations curl.ffi
io.encodings.utf8 kernel libc locals sequences tools.test words ;
IN: curl.ffi.tests

{ { 2 2 2 2 } } [
    { curl_easy_setopt_long curl_easy_setopt_string
      curl_easy_setopt_pointer curl_easy_setopt_curl_off_t }
    [ def>> 4 swap nth ] map
] unit-test

LIBRARY: curl
! Test-only inspection of the exact value kept by libcurl.
FUNCTION-ALIAS: inspect-curl-option CURLcode curl_easy_getinfo (
    CURL* curl, int info, ... void* output )

:: reject-negative-timeout ( -- result )
    curl_easy_init :> handle
    [ handle CURLOPT_CONNECTTIMEOUT -1 curl_easy_setopt_long ]
    [ handle curl_easy_cleanup ] finally ;
{ CURLE_BAD_FUNCTION_ARGUMENT } [ reject-negative-timeout ] unit-test

:: reject-negative-speed ( -- result )
    curl_easy_init :> handle
    [ handle CURLOPT_MAX_RECV_SPEED_LARGE -1 curl_easy_setopt_curl_off_t ]
    [ handle curl_easy_cleanup ] finally ;
{ CURLE_BAD_FUNCTION_ARGUMENT } [ reject-negative-speed ] unit-test

:: configured-url ( -- url )
    curl_easy_init :> handle
    [
        handle CURLOPT_URL "https://example.invalid/no-transfer" curl_easy_setopt_string CURLE_OK assert=
        f void* <ref> :> output
        ! CURLINFO_EFFECTIVE_URL = CURLINFO_STRING + 1.
        handle 0x100001 output inspect-curl-option CURLE_OK assert=
        output void* deref utf8 alien>string
    ] [ handle curl_easy_cleanup ] finally ;
{ "https://example.invalid/no-transfer" } [ configured-url ] unit-test

:: configured-pointer ( -- same? )
    curl_easy_init :> handle
    1 malloc :> value
    [
        handle CURLOPT_PRIVATE value curl_easy_setopt_pointer CURLE_OK assert=
        f void* <ref> :> output
        ! CURLINFO_PRIVATE = CURLINFO_STRING + 21.
        handle 0x100015 output inspect-curl-option CURLE_OK assert=
        output void* deref value =
    ] [ value free handle curl_easy_cleanup ] finally ;
{ t } [ configured-pointer ] unit-test
