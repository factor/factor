namespace factor
{

inline static cell callstack_size(cell size)
{
	return sizeof(callstack) + size;
}

PRIMITIVE(callstack);
PRIMITIVE(set_callstack);
PRIMITIVE(callstack_to_array);
PRIMITIVE(innermost_stack_frame_executing);
PRIMITIVE(innermost_stack_frame_scan);
PRIMITIVE(set_innermost_stack_frame_quot);

VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom,factorvm *vm);



}
