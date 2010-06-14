namespace factor
{

template<typename T>
struct identity {
	T operator()(T t)
	{
		return t;
	}
};

struct no_fixup {
	object *fixup_data(object *obj)
	{
		return obj;
	}

	code_block *fixup_code(code_block *compiled)
	{
		return compiled;
	}

	object *translate_data(const object *obj)
	{
		return fixup_data((object *)obj);
	}

	code_block *translate_code(const code_block *compiled)
	{
		return fixup_code((code_block *)compiled);
	}

	cell size(object *obj)
	{
		return obj->size();
	}

	cell size(code_block *compiled)
	{
		return compiled->size();
	}
};

}
