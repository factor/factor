namespace factor {

#define FACTOR_CPU_STRING "arm"

#define FRAME_RETURN_ADDRESS(frame, vm) *(XT*)(vm->frame_successor(frame) + 1)

}
