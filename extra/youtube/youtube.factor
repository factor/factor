! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs http.client http.download kernel math.order
sequences splitting urls urls.encoding ;

IN: youtube

TUPLE: encoding extension resolution video-codec profile
video-bitrate audio-codec audio-bitrate ;

CONSTANT: encodings H{

    ! Flash Video
    { 5 T{ encoding f "flv" "240p" "Sorenson H.263" f "0.25" "MP3" 64 } }
    { 6 T{ encoding f "flv" "270p" "Sorenson H.263" f "0.8" "MP3" 64 } }
    { 34 T{ encoding f "flv" "360p" "H.264" "Main" "0.5" "AAC" 128 } }
    { 35 T{ encoding f "flv" "480p" "H.264" "Main" "0.8-1" "AAC" 128 } }

    ! 3GP
    { 36 T{ encoding f "3gp" "240p" "MPEG-4 Visual" "Simple" "0.17" "AAC" 38 } }
    { 13 T{ encoding f "3gp" f "MPEG-4 Visual" f "0.5" "AAC" f } }
    { 17 T{ encoding f "3gp" "144p" "MPEG-4 Visual" "Simple" "0.05" "AAC" 24 } }

    ! MPEG-4
    { 18 T{ encoding f "mp4" "360p" "H.264" "Baseline" "0.5" "AAC" 96 } }
    { 22 T{ encoding f "mp4" "720p" "H.264" "High" "2-2.9" "AAC" 192 } }
    { 37 T{ encoding f "mp4" "1080p" "H.264" "High" "3-4.3" "AAC" 192 } }
    { 38 T{ encoding f "mp4" "3072p" "H.264" "High" "3.5-5" "AAC" 192 } }
    { 82 T{ encoding f "mp4" "360p" "H.264" "3D" "0.5" "AAC" 96 } }
    { 83 T{ encoding f "mp4" "240p" "H.264" "3D" "0.5" "AAC" 96 } }
    { 84 T{ encoding f "mp4" "720p" "H.264" "3D" "2-2.9" "AAC" 152 } }
    { 85 T{ encoding f "mp4" "520p" "H.264" "3D" "2-2.9" "AAC" 152 } }

    ! WebM
    { 43 T{ encoding f "webm" "360p" "VP8" f "0.5" "Vorbis" 128 } }
    { 44 T{ encoding f "webm" "480p" "VP8" f "1" "Vorbis" 128 } }
    { 45 T{ encoding f "webm" "720p" "VP8" f "2" "Vorbis" 192 } }
    { 46 T{ encoding f "webm" "1080p" "VP8" f f "Vorbis" 192 } }
    { 100 T{ encoding f "webm" "360p" "VP8" "3D" f "Vorbis" 128 } }
    { 101 T{ encoding f "webm" "360p" "VP8" "3D" f "Vorbis" 192 } }
    { 102 T{ encoding f "webm" "720p" "VP8" "3D" f "Vorbis" 192 } }
}

CONSTANT: video-info-url URL" https://www.youtube.com/get_video_info"

: get-video-info ( video-id -- video-info )
    video-info-url clone
        3 "asv" set-query-param
        "en_US" "hl" set-query-param
        swap "video_id" set-query-param
    http-get nip query>assoc ;

: video-formats ( video-info -- video-formats )
    "url_encoded_fmt_stream_map" of "," split
    [ query>assoc ] map ;

: video-download-url ( video-format -- url )
    [ "url" of ] [ "sig" of ] bi "&signature=" glue ;

: sanitize ( title -- title' )
    [ 0 31 between? ] reject
    [ "\"#$%'*,./:;<>?^|~\\" member? ] reject
    200 index-or-length head ;

: downloadable? ( video-info -- ? )
    "use_cipher_signature" of "False" = ;

: download-video ( video-id -- path )
    get-video-info [
        downloadable? [ "Video is encrypted." throw ] unless
    ] [
        video-formats [ "type" of "video/mp4" head? ] find nip
        video-download-url
    ] [
        "title" of sanitize ".mp4" append download-once-to
    ] tri ;
