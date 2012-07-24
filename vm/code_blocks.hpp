namespace factor
{

/* The compiled code heap is structured into blocks. */
struct code_block
{
	// header format (bits indexed with least significant as zero):
	// bit   0  : free?
	// bits  1-2: type (as a code_block_type)
	// if not free:
	//   bits  3-23: code size / 8
	//   bits 24-31: stack frame size / 16
	// if free:
	//   bits  3-end: code size / 8
	cell header;
	cell owner; /* tagged pointer to word, quotation or f */
	cell parameters; /* tagged pointer to array or f */
	cell relocation; /* tagged pointer to byte-array or f */

	bool free_p() const
	{
		return (header & 1) == 1;
	}

	code_block_type type() const
	{
		return (code_block_type)((header >> 1) & 0x3);
	}

	void set_type(code_block_type type)
	{
		header = ((header & ~0x7) | (type << 1));
	}

	bool pic_p() const
	{
		return type() == code_block_pic;
	}

	bool optimized_p() const
	{
		return type() == code_block_optimized;
	}

	cell size() const
	{
		cell size;
		if (free_p())
			size = header & ~7;
		else
			size = header & 0xFFFFF8;
		FACTOR_ASSERT(size > 0);
		return size;
	}

	cell stack_frame_size() const
	{
		if (free_p())
			return 0;
		else
			return (header >> 20) & 0xFF0;
	}

	cell stack_frame_size_for_address(cell addr) const
	{
		cell natural_frame_size = stack_frame_size();
		/* The first instruction in a code block is the prolog safepoint,
		and a leaf procedure code block will record a frame size of zero.
		If we're seeing a stack frame in either of these cases, it's a
		fake "leaf frame" set up by the signal handler. */
		if (natural_frame_size == 0 || (void*)addr == entry_point())
			return LEAF_FRAME_SIZE;
		else
			return natural_frame_size;
	}

	void set_stack_frame_size(cell frame_size)
	{
		FACTOR_ASSERT(size() < 0xFFFFFF);
		FACTOR_ASSERT(!free_p());
		FACTOR_ASSERT(frame_size % 16 == 0);
		FACTOR_ASSERT(frame_size <= 0xFF0);
		header = (header & 0xFFFFFF) | (frame_size << 20);
	}

	template<typename Fixup> cell size(Fixup fixup) const
	{
		return size();
	}

	void *entry_point() const
	{
		return (void *)(this + 1);
	}

	/* GC info is stored at the end of the block */
	gc_info *block_gc_info() const
	{
		return (gc_info *)((u8 *)this + size() - sizeof(gc_info));
	}

	void flush_icache()
	{
		factor::flush_icache((cell)this,size());
	}

	template<typename Iterator> void each_instruction_operand(Iterator &iter)
	{
		if(to_boolean(relocation))
		{
			byte_array *rels = (byte_array *)UNTAG(relocation);

			cell index = 0;
			cell length = (rels->capacity >> TAG_BITS) / sizeof(relocation_entry);

			for(cell i = 0; i < length; i++)
			{
				relocation_entry rel = rels->data<relocation_entry>()[i];
				iter(instruction_operand(rel,this,index));
				index += rel.number_of_parameters();
			}
		}
	}

	cell offset(void *addr) const
	{
		return (char*)addr - (char*)entry_point();
	}

	void *address_for_offset(cell offset) const
	{
		return (void*)((char*)entry_point() + offset);
	}

	cell scan(factor_vm *vm, void *addr) const;
};

VM_C_API void undefined_symbol(void);

inline code_block *word::code() const {
	FACTOR_ASSERT(entry_point != NULL);
	return (code_block*)entry_point - 1;
}

inline code_block *quotation::code() const {
	FACTOR_ASSERT(entry_point != NULL);
	return (code_block*)entry_point - 1;
}

}


