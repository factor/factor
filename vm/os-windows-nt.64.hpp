namespace factor
{

#define ESP Rsp
#define EIP Rip

#define X87SW(ctx) (ctx)->FloatSave.StatusWord
#define MXCSR(ctx) (ctx)->MxCsr

}
