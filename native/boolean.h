INLINE CELL tag_boolean(CELL untagged)
{
	return (untagged == false ? F : T);
}

INLINE bool untag_boolean(CELL tagged)
{
	return (tagged == F ? false : true);
}

void box_boolean(bool value);
bool unbox_boolean(void);
