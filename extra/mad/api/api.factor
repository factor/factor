! Copyright (C) 2007 Adam Wendt.
! See http://factorcode.org/license.txt for BSD license.
!
USING: alien alien.c-types byte-arrays io io.binary io.files kernel mad namespaces prettyprint sbufs sequences tools.interpreter vars ;
IN: mad.api

VARS: buffer-start buffer-length output-callback-var ;

: create-mad-callback-generic ( sequence parameters -- alien )
  swap >r >r "mad_flow" r> "cdecl" r> alien-callback ; inline

: create-input-callback ( sequence -- alien )
  { "void*" "mad_stream*" } create-mad-callback-generic ; inline

: create-header-callback ( sequence -- alien )
  { "void*" "mad_header*" } create-mad-callback-generic ; inline

: create-filter-callback ( sequence -- alien )
  { "void*" "mad_stream*" "mad_frame*" } create-mad-callback-generic ; inline 

: create-output-callback ( sequence -- alien )
  { "void*" "mad_header*" "mad_pcm*" } create-mad-callback-generic ; inline 

: create-error-callback ( sequence -- alien )
  { "void*" "mad_stream*" "mad_frame*" } create-mad-callback-generic ; inline 

: create-message-callback ( sequence -- alien )
  { "void*" "void*" "uint*" } create-mad-callback-generic ; inline 

: input ( buffer mad_stream -- mad_flow )
  "input" print flush
  nip                       ! mad_stream 
  buffer-start get          ! mad_stream start
  buffer-length get         ! mad_stream start length
  dup 0 =                   ! mad-stream start length bool
  [ 3drop MAD_FLOW_STOP ]   ! mad_flow
  [ mad_stream_buffer       !
  0 buffer-length set       !
  MAD_FLOW_CONTINUE ] if ;  ! mad_flow 

: input-callback ( -- callback )
  [ input ] create-input-callback ;

: header-callback ( -- callback )
  [ "header" print flush drop drop MAD_FLOW_CONTINUE ] create-header-callback ;

: filter-callback ( -- callback )
  [ "filter" print flush 3drop MAD_FLOW_CONTINUE ] create-filter-callback ;
 
: write-sample ( sample -- )
  4 >le write ; 

: output ( data header pcm -- mad_flow ) 
  "output" . flush
  -rot 2drop output-callback-var> call
  [ MAD_FLOW_CONTINUE ] [ MAD_FLOW_STOP ] if ;

: output-stdout ( pcm -- ? )
  [ mad_pcm-channels ] keep
  [ mad_pcm-length ] keep swap
  [
    [ mad_pcm-sample-right ] 2keep
    [ mad_pcm-sample-left ] 2keep
    drop -rot write-sample pick
    2 = [ write-sample ] [ drop ] if
  ] each drop t ;

: output-callback ( -- callback )
  [ output ] create-output-callback ;

: error-callback ( -- callback )
  [ "error" print flush drop drop drop MAD_FLOW_CONTINUE ] create-error-callback ;

: message-callback ( -- callback )
  [ "message" print flush drop drop drop MAD_FLOW_CONTINUE ] create-message-callback ;

: mad-init ( decoder -- )
  0 <alien> input-callback 0 <alien> 0 <alien> output-callback error-callback message-callback mad_decoder_init ;

: make-decoder ( -- decoder )
  "mad_decoder" malloc-object ;

: file-contents ( path -- string )
  dup <file-reader> swap file-length <sbuf> [ stream-copy ] keep >byte-array ;

: malloc-file-contents ( path -- alien )
  file-contents malloc-byte-array ;

: mad-run ( -- int )
  make-decoder [ mad-init ] keep MAD_DECODER_MODE_SYNC mad_decoder_run ;

: init-vars ( alien length -- )
  buffer-length set buffer-start set ;

: decode-mp3 ( filename -- results )
  [ malloc-file-contents ] keep file-length init-vars mad-run ;

: mad-test ( -- results )
  [ output-stdout ] >output-callback-var
  "/home/adam/download/mp3/Misc/wutbf.mp3" decode-mp3 ;

