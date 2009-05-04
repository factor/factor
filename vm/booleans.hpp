namespace factor
{

inline static CELL tag_boolean(CELL untagged)
{
	return (untagged ? T : F);
}

VM_C_API void box_boolean(bool value);
VM_C_API bool to_boolean(CELL value);

}
