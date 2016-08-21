#include "atomic-cl-32.hpp"

namespace factor {

#define ESP Esp
#define EIP Eip

typedef struct DECLSPEC_ALIGN(16) _M128A {
  ULONGLONG Low;
  LONGLONG High;
} M128A, *PM128A;

// The ExtendedRegisters field of the x86.32 CONTEXT structure uses this layout;
// however, this structure is only made available from winnt.h on x86.64
typedef struct _XMM_SAVE_AREA32 {
  WORD ControlWord;        // 000
  WORD StatusWord;         // 002
  BYTE TagWord;            // 004
  BYTE Reserved1;          // 005
  WORD ErrorOpcode;        // 006
  DWORD ErrorOffset;       // 008
  WORD ErrorSelector;      // 00c
  WORD Reserved2;          // 00e
  DWORD DataOffset;        // 010
  WORD DataSelector;       // 014
  WORD Reserved3;          // 016
  DWORD MxCsr;             // 018
  DWORD MxCsr_Mask;        // 01c
  M128A FloatRegisters[8]; // 020
  M128A XmmRegisters[16];  // 0a0
  BYTE Reserved4[96];      // 1a0
} XMM_SAVE_AREA32, *PXMM_SAVE_AREA32;

#define X87SW(ctx) (ctx)->FloatSave.StatusWord
#define MXCSR(ctx) ((XMM_SAVE_AREA32*)((ctx)->ExtendedRegisters))->MxCsr

}
