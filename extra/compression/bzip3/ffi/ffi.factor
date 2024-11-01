! Copyright (C) 2022 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.

! Makes use of Kamila Szewczyk's bzip3 library.
! See https://github.com/kspalaiologos/bzip3/blob/master/include/libbz3.h for the API specifics.
USING: alien alien.libraries alien.c-types alien.syntax
       classes.struct combinators system words ;
IN: compression.bzip3.ffi

C-LIBRARY: bzip3 cdecl {
    { windows "bzip3.dll" }
    { macos "libbzip3.dylib" }
    { unix "libbzip3.so" }
}

LIBRARY: bzip3

! typedef struct {
!     /* Input/output. */
!     u8 *in_queue, *out_queue;
!     s32 input_ptr, output_ptr, input_max;

!     /* C0, C1 - used for making the initial prediction, C2 used for an APM with a slightly low
!        learning rate (6) and 512 contexts. kanzi merges C0 and C1, uses slightly different
!        counter initialisation code and prediction code which from my tests tends to be suboptimal. */
!     u16 C0[256], C1[256][256], C2[512][17];
! } state;
STRUCT: state
  { in_queue u8* } { out_queue u8* }
  { input_ptr s32 } { output_ptr s32 } { input_max s32 }
  { C0 u16[256] } { C1 u16[256][256] } { C2 u16[512][17] }
;

! struct bz3_state {
!     u8 * swap_buffer;
!     s32 block_size;
!     s32 *sais_array, *lzp_lut;
!     state * cm_state;
!     s8 last_error;
! };
STRUCT: bz3_state 
  { swap_buffer u8* }
  { block_size s32 }
  { sais_array s32* } { lzp_lut s32* }
  { cm_state state* }
  { last_error s8 }
;

FUNCTION: c-string bz3_version ( )
FUNCTION: int8_t bz3_last_error ( bz3_state* state )
FUNCTION: c-string bz3_strerror ( bz3_state* state )
FUNCTION: bz3_state* bz3_new ( int32_t block_size )
FUNCTION: void bz3_free ( bz3_state* state )
FUNCTION: size_t bz3_bound ( size_t input_size )

! HIGH LEVEL APIs
FUNCTION: int bz3_compress ( uint32_t block_size, uint8_t* in, uint8_t* out, size_t in_size, size_t* out_size )
FUNCTION: int bz3_decompress ( uint8_t* in, uint8_t* out, size_t in_size, size_t* out_size )

! LOW LEVEL APIs
FUNCTION: int32_t bz3_encode_block ( bz3_state* state, uint8_t* buffer, int32_t size )
FUNCTION: int32_t bz3_decode_block ( bz3_state* state, uint8_t* buffer, int32_t size, int32_t orig_size )
FUNCTION: void bz3_encode_blocks ( bz3_state* states[], uint8_t* buffers[], int32_t sizes[], int32_t n )
FUNCTION: void bz3_decode_blocks ( bz3_state* states[], uint8_t* buffers[], int32_t sizes[], int32_t orig_sizes[], int32_t n )

