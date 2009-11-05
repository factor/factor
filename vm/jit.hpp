namespace factor
{

struct jit {
	code_block_type type;
	data_root<object> owner;
	growable_byte_array code;
	growable_byte_array relocation;
	growable_array literals;
	bool computing_offset_p;
	fixnum position;
	cell offset;
	factor_vm *parent;

	explicit jit(code_block_type type, cell owner, factor_vm *parent);
	void compute_position(cell offset);

	void emit_relocation(cell code_template);
	void emit(cell code_template);

	void literal(cell literal) { literals.add(literal); }
	void emit_with(cell code_template_, cell literal_);

	void push(cell literal)
	{
		emit_with(parent->special_objects[JIT_PUSH_IMMEDIATE],literal);
	}

	void word_jump(cell word_)
	{
		data_root<word> word(word_,parent);
		literal(tag_fixnum(xt_tail_pic_offset));
		literal(word.value());
		emit(parent->special_objects[JIT_WORD_JUMP]);
	}

	void word_call(cell word)
	{
		emit_with(parent->special_objects[JIT_WORD_CALL],word);
	}

	void word_special(cell word)
	{
		emit_with(parent->special_objects[JIT_WORD_SPECIAL],word);
	}

	void emit_subprimitive(cell word_)
	{
		data_root<word> word(word_,parent);
		data_root<array> code_pair(word->subprimitive,parent);
		literals.append(untag<array>(array_nth(code_pair.untagged(),0)));
		emit(array_nth(code_pair.untagged(),1));
	}

	void emit_class_lookup(fixnum index, cell type);

	fixnum get_position()
	{
		if(computing_offset_p)
		{
			/* If this is still on, emit() didn't clear it,
			   so the offset was out of bounds */
			return -1;
		}
		else
			return position;
	}

        void set_position(fixnum position_)
	{
		if(computing_offset_p)
			position = position_;
	}

	
	code_block *to_code_block();
};

}
