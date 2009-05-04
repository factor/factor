namespace factor
{

struct jit {
	cell type;
	gc_root<object> owner;
	growable_byte_array code;
	growable_byte_array relocation;
	growable_array literals;
	bool computing_offset_p;
	fixnum position;
	cell offset;

	jit(cell jit_type, cell owner);
	void compute_position(cell offset);

	relocation_entry rel_to_emit(cell code_template, bool *rel_p);
	void emit(cell code_template);

	void literal(cell literal) { literals.add(literal); }
	void emit_with(cell code_template_, cell literal_);

	void push(cell literal) {
		emit_with(userenv[JIT_PUSH_IMMEDIATE],literal);
	}

	void word_jump(cell word) {
		emit_with(userenv[JIT_WORD_JUMP],word);
	}

	void word_call(cell word) {
		emit_with(userenv[JIT_WORD_CALL],word);
	}

	void emit_subprimitive(cell word_) {
		gc_root<word> word(word_);
		gc_root<array> code_template(word->subprimitive);
		if(array_nth(code_template.untagged(),1) != F) literal(T);
		emit(code_template.value());
	}

	void emit_class_lookup(fixnum index, cell type);

	fixnum get_position() {
		if(computing_offset_p)
		{
			/* If this is still on, emit() didn't clear it,
			   so the offset was out of bounds */
			return -1;
		}
		else
			return position;
	}

        void set_position(fixnum position_) {
		if(computing_offset_p)
			position = position_;
	}

	
	code_block *to_code_block();
};

}
