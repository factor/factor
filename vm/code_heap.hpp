namespace factor
{
struct factor_vm;
typedef void (*code_heap_iterator)(code_block *compiled,factor_vm *myvm);

PRIMITIVE(modify_code_heap);
PRIMITIVE(code_room);

}
