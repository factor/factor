INLINE CELL tag_boolean(CELL untagged)
{
	return (untagged == false ? F : T);
}

DLLEXPORT void box_boolean(bool value);
DLLEXPORT bool to_boolean(CELL value);
