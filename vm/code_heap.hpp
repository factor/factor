namespace factor
{

bool in_code_heap_p(cell ptr);    // Used by platform specific code

struct factorvm;
typedef void (*code_heap_iterator)(code_block *compiled,factorvm *myvm);

PRIMITIVE(modify_code_heap);
PRIMITIVE(code_room);

}
