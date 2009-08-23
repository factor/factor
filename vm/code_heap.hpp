namespace factor
{
struct factorvm;
typedef void (*code_heap_iterator)(code_block *compiled,factorvm *myvm);

PRIMITIVE(modify_code_heap);
PRIMITIVE(code_room);

}
