struct jit {
	CELL type;
	gc_root<F_OBJECT> owner;
	growable_byte_array code;
	growable_byte_array relocation;
	growable_array literals;
	bool computing_offset_p;
	F_FIXNUM position;
	CELL offset;

	jit(CELL jit_type, CELL owner);
	void compute_position(CELL offset);

	F_REL rel_to_emit(CELL code_template, bool *rel_p);
	void emit(CELL code_template);

	void literal(CELL literal) { literals.add(literal); }
	void emit_with(CELL code_template_, CELL literal_);

	void push(CELL literal) {
		emit_with(userenv[JIT_PUSH_IMMEDIATE],literal);
	}

	void word_jump(CELL word) {
		emit_with(userenv[JIT_WORD_JUMP],word);
	}

	void word_call(CELL word) {
		emit_with(userenv[JIT_WORD_CALL],word);
	}

	void emit_subprimitive(CELL word_) {
		gc_root<F_WORD> word(word_);
		gc_root<F_ARRAY> code_template(word->subprimitive);
		if(array_nth(code_template.untagged(),1) != F) literal(T);
		emit(code_template.value());
	}

	void emit_class_lookup(F_FIXNUM index, CELL type);

	F_FIXNUM get_position() {
		if(computing_offset_p)
		{
			/* If this is still on, emit() didn't clear it,
			   so the offset was out of bounds */
			return -1;
		}
		else
			return position;
	}

        void set_position(F_FIXNUM position_) {
		if(computing_offset_p)
			position = position_;
	}

	
	F_CODE_BLOCK *code_block();
};
