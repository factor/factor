! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! TODO: 
!   based on number of channels in file.
! - End of decoding is indicated by an exception when reading the stream.
!   How to work around this? C player example uses feof but streams don't
!   have that in Factor.
! - Work out openal buffer method that plays nicely with streaming over
!   slow connections.
! - Have start/stop/seek methods on the player object.
!
USING: kernel alien ogg ogg.vorbis ogg.theora io byte-arrays
       sequences libc shuffle alien.c-types system openal math
       namespaces threads shuffle opengl arrays ui.gadgets.worlds
       combinators math.parser ui.gadgets ui.render opengl.gl ui
       continuations io.files hints combinators.lib ;

IN: ogg.player

: audio-buffer-size ( -- number ) 128 1024 *  ; inline

TUPLE: player stream temp-state 
       op oy og 
       vo vi vd vb vc vorbis
       to ti tc td yuv rgb theora video-ready? video-time video-granulepos
       source buffers buffer-indexes start-time
       playing? audio-full? audio-index audio-buffer audio-granulepos 
       gadget ;

: init-vorbis ( player -- )
    dup player-oy ogg_sync_init drop
    dup player-vi vorbis_info_init 
    player-vc vorbis_comment_init ;

: init-theora ( player -- )
    dup player-ti theora_info_init 
    player-tc theora_comment_init ;

: init-sound ( player -- )
    init-openal check-error
    1 gen-buffers check-error over set-player-buffers
    2 "uint" <c-array> over set-player-buffer-indexes
    1 gen-sources check-error first swap set-player-source ;

: <player> ( stream -- player )
    { set-player-stream } player construct
    0 over set-player-vorbis 
    0 over set-player-theora 
    0 over set-player-video-time 
    0 over set-player-video-granulepos 
    f over set-player-video-ready?
    f over set-player-audio-full?
    0 over set-player-audio-index    
    0 over set-player-start-time    
    audio-buffer-size "short" <c-array> over set-player-audio-buffer
    0 over set-player-audio-granulepos
    f over set-player-playing?
    "ogg_packet" malloc-object over set-player-op
    "ogg_sync_state" malloc-object over set-player-oy 
    "ogg_page" malloc-object over set-player-og
    "ogg_stream_state" malloc-object over set-player-vo
    "vorbis_info" malloc-object over set-player-vi
    "vorbis_dsp_state" malloc-object over set-player-vd
    "vorbis_block" malloc-object over set-player-vb
    "vorbis_comment" malloc-object over set-player-vc 
    "ogg_stream_state" malloc-object over set-player-to
    "theora_info" malloc-object over set-player-ti
    "theora_comment" malloc-object over set-player-tc
    "theora_state" malloc-object over set-player-td 
    "yuv_buffer" <c-object> over set-player-yuv
    "ogg_stream_state" <c-object> over set-player-temp-state
    dup init-sound
    dup init-vorbis 
    dup init-theora ;

: num-channels ( player -- channels )
    player-vi vorbis_info-channels ;
    
: al-channel-format ( player -- format )
    num-channels 1 = [ AL_FORMAT_MONO16 ] [ AL_FORMAT_STEREO16 ] if ;

: get-time ( player -- time )
    dup player-start-time zero? [
        millis over set-player-start-time
    ] when 
    player-start-time millis swap - 1000.0 /f ;

: clamp ( n -- n )
    255 min 0 max ; inline

: stride ( line yuv  -- uvy yy )
    [ yuv_buffer-uv_stride >fixnum swap 2/ * ] 2keep
    yuv_buffer-y_stride >fixnum * >fixnum ; inline

: each-with4 ( obj obj obj obj seq quot -- )
    4 each-withn ; inline

: compute-y ( yuv uvy yy x -- y )
    + >fixnum nip swap yuv_buffer-y uchar-nth 16 - ; inline

: compute-v ( yuv uvy yy x -- v )
    nip 2/ + >fixnum swap yuv_buffer-u uchar-nth 128 - ; inline

: compute-u ( yuv uvy yy x -- v )
    nip 2/ + >fixnum swap yuv_buffer-v uchar-nth 128 - ; inline

: compute-yuv ( yuv uvy yy x -- y u v )
    [ compute-y ] 4keep [ compute-u ] 4keep compute-v ; inline

: compute-blue ( y u v -- b )
    drop 516 * 128 + swap 298 * + -8 shift clamp ; inline

: compute-green ( y u v -- g )
    >r >r 298 * r> 100 * - r> 208 * - 128 + -8 shift clamp ;
    inline

: compute-red ( y u v -- g )
    nip 409 * swap 298 * + 128 + -8 shift clamp ; inline

: compute-rgb ( y u v -- b g r )
    [ compute-blue ] 3keep [ compute-green ] 3keep compute-red ;
    inline

: store-rgb ( index rgb b g r -- index )
    >r
    >r pick 0 + >fixnum pick set-uchar-nth
    r> pick 1 + >fixnum pick set-uchar-nth
    r> pick 2 + >fixnum pick set-uchar-nth
    drop ; inline

: yuv>rgb-pixel ( index rgb yuv uvy yy x -- index )
    compute-yuv compute-rgb store-rgb 3 + >fixnum ; inline

: yuv>rgb-row ( index rgb yuv y -- index )
    over stride
    pick yuv_buffer-y_width >fixnum
    [ yuv>rgb-pixel ] each-with4 ; inline

: yuv>rgb ( rgb yuv  -- )
    0 -rot
    dup yuv_buffer-y_height >fixnum
    [ yuv>rgb-row ] each-with2
    drop ;

HINTS: yuv>rgb byte-array byte-array ;

: process-video ( player -- player )
    dup player-gadget [
        dup { player-td player-yuv } get-slots theora_decode_YUVout drop
        dup player-rgb over player-yuv [ yuv>rgb ] time flush
        dup player-gadget find-world dup draw-world 
    ] when ;

: num-audio-buffers-processed ( player -- player n )
    dup player-source AL_BUFFERS_PROCESSED 0 <uint> 
    [ alGetSourcei check-error ] keep *uint ;
    
: append-new-audio-buffer ( player -- player )
    dup player-buffers 1 gen-buffers append over set-player-buffers 
    [ [ player-buffers second ] keep al-channel-format ] keep
    [ player-audio-buffer dup length  ] keep
    [ player-vi vorbis_info-rate alBufferData check-error ]  keep 
    [ player-source 1 ] keep
    [ player-buffers second <uint> alSourceQueueBuffers check-error ] keep ;

: fill-processed-audio-buffer ( player n -- player )
    #! n is the number of audio buffers processed 
    over >r >r dup player-source r> pick player-buffer-indexes
    [ alSourceUnqueueBuffers check-error ] keep 
    *uint dup r> swap >r al-channel-format rot 
    [ player-audio-buffer dup length  ] keep
    [ player-vi vorbis_info-rate alBufferData check-error ]  keep 
    [ player-source 1 ] keep
    r> <uint> swap >r alSourceQueueBuffers check-error r> ;

: append-audio ( player -- player bool )
    num-audio-buffers-processed {
        { [ over player-buffers length 1 = over zero? and ] [ drop append-new-audio-buffer t ] }
        { [ over player-buffers length 2 = over zero? and ] [ 0 sleep drop f ] }
        { [ t ] [ fill-processed-audio-buffer t ] }
    } cond ;    

: start-audio ( player -- player bool )
    [ [ player-buffers first ] keep al-channel-format ] keep
    [ player-audio-buffer dup length ] keep
    [ player-vi vorbis_info-rate alBufferData check-error ]  keep 
    [ player-source 1 ] keep
    [ player-buffers first <uint> alSourceQueueBuffers check-error ] keep
    [ player-source alSourcePlay check-error ] keep
    t over set-player-playing? t ;

: process-audio ( player -- player bool )
    dup player-playing? [ append-audio ] [ start-audio ] if ;

: read-bytes-into ( dest size stream -- len )
    #! Read the given number of bytes from a stream
    #! and store them in the destination byte array.
    stream-read >byte-array dup length [ memcpy ] keep  ;

: check-not-negative ( int -- )
    0 < [ "Word result was a negative number." throw ] when ;

: buffer-size ( -- number ) 
    4096 ; inline

: sync-buffer ( player -- buffer size player )
    [ player-oy buffer-size ogg_sync_buffer buffer-size ] keep ;
 
: stream-into-buffer ( buffer size player -- len player )
    [ player-stream read-bytes-into ] keep ;

: confirm-buffer ( len player -- player eof? )
  [ player-oy swap ogg_sync_wrote check-not-negative ] 2keep swap zero? ;

: buffer-data ( player -- player eof? )
    #! Take some compressed bitstream data and sync it for
    #! page extraction.
    sync-buffer stream-into-buffer confirm-buffer ;
     
: queue-page ( player -- player )
    #! Push a page into the stream for packetization
    [ { player-vo player-og } get-slots ogg_stream_pagein drop ] keep 
    [ { player-to player-og } get-slots ogg_stream_pagein drop ] keep ;

: retrieve-page ( player -- player bool )
    #! Sync the streams and get a page. Return true if a page was
    #! successfully retrieved.
    dup { player-oy player-og } get-slots ogg_sync_pageout 0 > ;   

: standard-initial-header? ( player -- player bool )
    dup player-og ogg_page_bos zero? not ;

: ogg-stream-init ( player -- state player )
    #! Init the encode/decode logical stream state
    [ player-temp-state ] keep 
    [ player-og ogg_page_serialno ogg_stream_init check-not-negative ] 2keep ;

: ogg-stream-pagein ( state player -- state player )
    #! Add the incoming page to the stream state
    [ player-og ogg_stream_pagein drop ] 2keep ;

: ogg-stream-packetout ( state player -- state player )
    [ player-op ogg_stream_packetout drop ] 2keep ;

: decode-packet ( player -- state player )
    ogg-stream-init ogg-stream-pagein ogg-stream-packetout ;

: theora-header? ( player -- player bool )
    #! Is the current page a theora header?
    dup { player-ti player-tc player-op } get-slots theora_decode_header 0 >= ;

: is-theora-packet? ( player -- player bool )
    dup player-theora zero? [ theora-header? ] [ f ] if ;

: copy-to-theora-state ( state player -- player )
    #! Copy the state to the theora state structure in the player
    [ player-to swap dup length memcpy ] keep ;

: handle-initial-theora-header ( state player -- player )
    copy-to-theora-state 1 over set-player-theora ;

: vorbis-header? ( player -- player bool )
    #! Is the current page a vorbis header?
    dup { player-vi player-vc player-op } get-slots vorbis_synthesis_headerin 0 >= ;

: is-vorbis-packet? ( player -- player bool )
    dup player-vorbis zero? [ vorbis-header? ] [ f ] if ;
 
: copy-to-vorbis-state ( state player -- player )
    #! Copy the state to the vorbis state structure in the player
    [ player-vo swap dup length memcpy ] keep ;
 
: handle-initial-vorbis-header ( state player -- player )
    copy-to-vorbis-state 1 over set-player-vorbis ;

: handle-initial-unknown-header ( state player -- player )
    swap ogg_stream_clear drop ;

: process-initial-header ( player -- player bool )
    #! Is this a standard initial header? If not, stop parsing
    standard-initial-header? [
        decode-packet {
            { [ is-vorbis-packet? ] [ handle-initial-vorbis-header ] }
            { [ is-theora-packet? ] [ handle-initial-theora-header ] }
            { [ t ]                 [ handle-initial-unknown-header ] }
        } cond t
    ] [
        f
    ] if ;

: parse-initial-headers ( player -- player )
    #! Parse Vorbis headers, ignoring any other type stored
    #! in the Ogg container.
    retrieve-page [
        process-initial-header [ 
            parse-initial-headers
        ] [
            #! Don't leak the page, get it into the appropriate stream
            queue-page 
        ] if        
    ] [ 
        buffer-data not [ parse-initial-headers ] when
    ] if ;
  
: have-required-vorbis-headers? ( player -- player bool )
    #! Return true if we need to decode vorbis due to there being
    #! vorbis headers read from the stream but we don't have them all
    #! yet.
    dup player-vorbis 1 2 between? not ;

: have-required-theora-headers? ( player -- player bool )
    #! Return true if we need to decode theora due to there being
    #! theora headers read from the stream but we don't have them all
    #! yet.
    dup player-theora 1 2 between? not ;

: get-remaining-vorbis-header-packet ( player -- player bool )
    dup { player-vo player-op } get-slots ogg_stream_packetout {
        { [ dup 0 <   ] [ "Error parsing vorbis stream; corrupt stream?" throw ] }
        { [ dup zero? ] [ drop f ] }
        { [ t     ] [ drop t ] }
    } cond ;

: get-remaining-theora-header-packet ( player -- player bool )
    dup { player-to player-op } get-slots ogg_stream_packetout {
        { [ dup 0 <   ] [ "Error parsing theora stream; corrupt stream?" throw ] }
        { [ dup zero? ] [ drop f ] }
        { [ t     ] [ drop t ] }
    } cond ;

: decode-remaining-vorbis-header-packet ( player -- player )
    dup { player-vi player-vc player-op } get-slots vorbis_synthesis_headerin zero? [
        "Error parsing vorbis stream; corrupt stream?" throw
    ] unless ;

: decode-remaining-theora-header-packet ( player -- player )
    dup { player-ti player-tc player-op } get-slots theora_decode_header zero? [
        "Error parsing theora stream; corrupt stream?" throw
    ] unless ;

: increment-vorbis-header-count ( player -- player )
    dup player-vorbis 1+ over set-player-vorbis ;

: increment-theora-header-count ( player -- player )
    dup player-theora 1+ over set-player-theora ;

: parse-remaining-vorbis-headers ( player -- player )
    have-required-vorbis-headers? not [
        get-remaining-vorbis-header-packet [
            decode-remaining-vorbis-header-packet
            increment-vorbis-header-count
            parse-remaining-vorbis-headers  
        ] when 
    ] when ;

: parse-remaining-theora-headers ( player -- player )
    have-required-theora-headers? not [
        get-remaining-theora-header-packet [
            decode-remaining-theora-header-packet 
            increment-theora-header-count
            parse-remaining-theora-headers  
        ] when 
    ] when ;

: get-more-header-data ( player -- player )
    buffer-data drop ;

: parse-remaining-headers ( player -- player )
    have-required-vorbis-headers? not swap have-required-theora-headers? not swapd or [
        parse-remaining-vorbis-headers 
        parse-remaining-theora-headers
        retrieve-page [ queue-page ] [ get-more-header-data ] if
        parse-remaining-headers
    ] when ;
   
: tear-down-vorbis ( player -- player )
    dup player-vi vorbis_info_clear
    dup player-vc vorbis_comment_clear ;

: tear-down-theora ( player -- player )
    dup player-ti theora_info_clear
    dup player-tc theora_comment_clear ;

: init-vorbis-codec ( player -- player )
    dup { player-vd player-vi } get-slots vorbis_synthesis_init drop
    dup { player-vd player-vb } get-slots vorbis_block_init drop ;

: init-theora-codec ( player -- player )
    dup { player-td player-ti } get-slots theora_decode_init drop 
    dup player-ti theora_info-frame_width over player-ti theora_info-frame_height 
    4 * * <byte-array> over set-player-rgb ;


: display-vorbis-details ( player -- player )
    [
        "Ogg logical stream " %
        dup player-vo ogg_stream_state-serialno #
        " is Vorbis " %
        dup player-vi vorbis_info-channels #
        " channel " %
        dup player-vi vorbis_info-rate #
        " Hz audio." %
    ] "" make print ;

: display-theora-details ( player -- player )
    [
        "Ogg logical stream " %
        dup player-to ogg_stream_state-serialno #
        " is Theora " %
        dup player-ti theora_info-width #
        "x" %
        dup player-ti theora_info-height #
        " " %
        dup player-ti theora_info-fps_numerator 
        over player-ti theora_info-fps_denominator /f #
        " fps video" %
    ] "" make print ;

: initialize-decoder ( player -- player )
    dup player-vorbis zero? [ tear-down-vorbis ] [ init-vorbis-codec display-vorbis-details ] if 
    dup player-theora zero? [ tear-down-theora ] [ init-theora-codec display-theora-details ] if ;
  
: sync-pages ( player -- player )
    retrieve-page [
        queue-page sync-pages 
    ] when ;

: audio-buffer-not-ready? ( player -- player bool )
    dup player-vorbis zero? not over player-audio-full? not and ;
  
: pending-decoded-audio? ( player -- player pcm len bool )
    f <void*> 2dup >r player-vd r> vorbis_synthesis_pcmout dup 0 > ;

: buffer-space-available ( player -- available )
    audio-buffer-size swap player-audio-index - ;
    
: samples-to-read ( player available len -- numread )
    >r swap num-channels / r> min ;
    
: each-with3 ( obj obj obj seq quot -- ) 3 each-withn ; inline 

: add-to-buffer ( player val -- )
    over player-audio-index pick player-audio-buffer set-short-nth 
    dup player-audio-index 1+ swap set-player-audio-index ;

: get-audio-value ( pcm sample channel -- value )
    rot *void* void*-nth float-nth ;

: process-channels ( player pcm sample channel -- )
    get-audio-value 32767.0 * >fixnum 32767 min -32768 max add-to-buffer ;

: (process-sample) ( player pcm sample -- )
    pick num-channels [ process-channels ] each-with3 ;
 
: process-samples ( player pcm numread -- )
    [ (process-sample) ] each-with2 ;

: decode-pending-audio ( player pcm result -- player )
!     [ "ret = " % dup # ] "" make write
    pick [ buffer-space-available swap ] keep -rot samples-to-read 
    pick over >r >r process-samples r> r> swap
    ! numread player 
    dup player-audio-index audio-buffer-size = [
        t over set-player-audio-full?
    ] when
    dup player-vd vorbis_dsp_state-granulepos dup 0 >= [
        ! numtoread player granulepos
        #! This is wrong: fix
        pick - over set-player-audio-granulepos
    ] [
        ! numtoread player granulepos
        pick + over set-player-audio-granulepos
    ] if
    [ player-vd swap vorbis_synthesis_read drop ] keep ;

: no-pending-audio ( player -- player bool )
    #! No pending audio. Is there a pending packet to decode.
    dup { player-vo player-op } get-slots ogg_stream_packetout 0 > [
        dup { player-vb player-op } get-slots vorbis_synthesis 0 = [
            dup { player-vd player-vb } get-slots vorbis_synthesis_blockin drop
        ] when
        t 
    ] [
        #! Need more data. Break out to suck in another page.
        f 
    ] if ;

: decode-audio ( player -- player )
    audio-buffer-not-ready? [
        #! If there's pending decoded audio, grab it
        pending-decoded-audio? [
            decode-pending-audio decode-audio
        ] [
            2drop no-pending-audio [ decode-audio ] when
        ] if
    ] when ;

: video-buffer-not-ready? ( player -- player bool )
    dup player-theora zero? not over player-video-ready? not and ;

: decode-video ( player -- player )
    video-buffer-not-ready? [
        dup { player-to player-op } get-slots ogg_stream_packetout 0 > [
            dup { player-td player-op } get-slots theora_decode_packetin drop
            dup player-td theora_state-granulepos over set-player-video-granulepos
            dup { player-td player-video-granulepos } get-slots theora_granule_time 
            over set-player-video-time
            t over set-player-video-ready?
            decode-video        
        ] when
    ] when ;
    
: decode ( player -- player )
    get-more-header-data sync-pages
    decode-audio
    decode-video
    dup player-audio-full? [
        process-audio [
            f over set-player-audio-full?
            0 over set-player-audio-index
        ] when
    ] when 
    dup player-video-ready? [
        dup player-video-time over get-time - dup 0.0 < [
            -0.1 > [ process-video ] when
            f over set-player-video-ready?
        ] [
            drop
        ] if
    ] when
    decode ;

: free-malloced-objects ( player -- player )
    [ player-op free ] keep
    [ player-oy free ] keep
    [ player-og free ] keep
    [ player-vo free ] keep
    [ player-vi free ] keep
    [ player-vd free ] keep
    [ player-vb free ] keep
    [ player-vc free ] keep  
    [ player-to free ] keep
    [ player-ti free ] keep
    [ player-tc free ] keep
    [ player-td free ] keep ;


: unqueue-openal-buffers ( player -- player )
    [

        num-audio-buffers-processed over player-source rot player-buffer-indexes swapd
        alSourceUnqueueBuffers check-error 
    ] keep ;

: delete-openal-buffers ( player -- player )
    [ 
        player-buffers [
            1 swap <uint> alDeleteBuffers check-error
        ] each 
    ] keep ;

: delete-openal-source ( player -- player )
    [ player-source 1 swap <uint> alDeleteSources check-error ] keep ;

: cleanup ( player -- player )
    free-malloced-objects 
    unqueue-openal-buffers
    delete-openal-buffers 
    delete-openal-source ;

: wait-for-sound ( player -- player )
    #! Waits for the openal to finish playing remaining sounds
    dup player-source AL_SOURCE_STATE 0 <int> [ alGetSourcei check-error ] keep
    *int AL_PLAYING = [
        100 sleep
        wait-for-sound
    ] when ;

TUPLE: theora-gadget player ;

: <theora-gadget> ( player -- gadget )
  theora-gadget construct-gadget
  [ set-theora-gadget-player ] keep ;

M: theora-gadget pref-dim* 
    theora-gadget-player
    player-ti dup theora_info-width swap theora_info-height 2array ;

M: theora-gadget draw-gadget* ( gadget -- )
    0 0 glRasterPos2i
    1.0 -1.0 glPixelZoom
    GL_UNPACK_ALIGNMENT 1 glPixelStorei
    [ pref-dim* first2 GL_RGB GL_UNSIGNED_BYTE ] keep
    theora-gadget-player player-rgb glDrawPixels ;

: initialize-gui ( gadget -- )
    "Theora Player" open-window ;

: play-ogg ( player -- )
    parse-initial-headers 
    parse-remaining-headers 
    initialize-decoder 
    dup player-gadget [ initialize-gui ] when* 
    [ decode ] [ drop ] recover
!    decode
    wait-for-sound
    cleanup
    drop ;

: play-vorbis-stream ( stream -- )
    <player> play-ogg ;

: play-vorbis-file ( filename -- )
    <file-reader> play-vorbis-stream ;

: play-theora-stream ( stream -- )
    <player> 
    dup <theora-gadget> over set-player-gadget         
    play-ogg ;

: play-theora-file ( filename -- )
    <file-reader> play-theora-stream ;

