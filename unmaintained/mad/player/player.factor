! Copyright (C) 2007 Adam Wendt.
! See http://factorcode.org/license.txt for BSD license.
!
USING: alien.c-types io kernel libc mad mad.api math namespaces openal prettyprint sequences tools.interpreter vars ;
IN: mad.player

VARS: openal-buffer ;

: get-format ( pcm -- format )
  mad_pcm-channels 2 =
  [ AL_FORMAT_STEREO16 ] [ AL_FORMAT_MONO16 ] if ;

: no-error? ( -- ? )
  alGetError dup . flush AL_NO_ERROR = ;

: round ( sample -- rounded )
  1 MAD_F_FRACBITS 16 - shift + ;

: clip ( sample -- clipped ) MAD_F_ONE 1- min MAD_F_ONE neg max ;

: quantize ( sample -- quantized )
  MAD_F_FRACBITS 1+ 16 - neg shift ;

: scale-sample ( sample -- scaled )
  round clip quantize ;

: get-needed-size ( pcm -- size )
  [ mad_pcm-channels ] keep mad_pcm-length 2 * * ;

: make-data ( pcm -- )
  [ mad_pcm-channels ] keep     ! channels pcm
  [ mad_pcm-length ] keep swap  ! channels pcm length
  [                             ! channels pcm counter
    [ mad_pcm-sample-right ] 2keep ! channels right pcm counter
    [ mad_pcm-sample-left ] 2keep  ! channels right left pcm counter
    drop -rot scale-sample , pick  ! channels pcm right channels
    2 = [ scale-sample , ] [ drop ] if ! channels pcm right
  ] each 2drop ;

: array>alien ( alien array -- ) dup length [ pick set-int-nth ] 2each drop ;
  
: fill-data ( pcm alien -- )
  swap [ make-data ] { } make array>alien ;

: get-data ( pcm -- size alien )
  [ get-needed-size ] keep over
  malloc [ fill-data ] keep ;

: output-openal ( pcm -- ? )
  openal-buffer> swap     ! buffer pcm
  [ get-format ] keep     ! buffer format pcm
  [ get-data ] keep       ! buffer format size alien pcm
  mad_pcm-samplerate      ! buffer format size alien samplerate
  swapd alBufferData no-error?
  ;

: play-mp3 ( filename -- )
  gen-buffer >openal-buffer [ output-openal ] >output-callback-var decode-mp3 ;
