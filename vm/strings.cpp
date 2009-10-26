#include "master.hpp"

namespace factor
{

cell string::nth(cell index) const
{
	/* If high bit is set, the most significant 16 bits of the char
	come from the aux vector. The least significant bit of the
	corresponding aux vector entry is negated, so that we can
	XOR the two components together and get the original code point
	back. */
	cell lo_bits = data()[index];

	if((lo_bits & 0x80) == 0)
		return lo_bits;
	else
	{
		byte_array *aux = untag<byte_array>(this->aux);
		cell hi_bits = aux->data<u16>()[index];
		return (hi_bits << 7) ^ lo_bits;
	}
}

void factor_vm::set_string_nth_fast(string *str, cell index, cell ch)
{
	str->data()[index] = ch;
}

void factor_vm::set_string_nth_slow(string *str_, cell index, cell ch)
{
	gc_root<string> str(str_,this);

	byte_array *aux;

	str->data()[index] = ((ch & 0x7f) | 0x80);

	if(to_boolean(str->aux))
		aux = untag<byte_array>(str->aux);
	else
	{
		/* We don't need to pre-initialize the
		byte array with any data, since we
		only ever read from the aux vector
		if the most significant bit of a
		character is set. Initially all of
		the bits are clear. */
		aux = allot_uninitialized_array<byte_array>(untag_fixnum(str->length) * sizeof(u16));

		str->aux = tag<byte_array>(aux);
		write_barrier(&str->aux);
	}

	aux->data<u16>()[index] = ((ch >> 7) ^ 1);
}

/* allocates memory */
void factor_vm::set_string_nth(string *str, cell index, cell ch)
{
	if(ch <= 0x7f)
		set_string_nth_fast(str,index,ch);
	else
		set_string_nth_slow(str,index,ch);
}

/* Allocates memory */
string *factor_vm::allot_string_internal(cell capacity)
{
	string *str = allot<string>(string_size(capacity));

	str->length = tag_fixnum(capacity);
	str->hashcode = false_object;
	str->aux = false_object;

	return str;
}

/* Allocates memory */
void factor_vm::fill_string(string *str_, cell start, cell capacity, cell fill)
{
	gc_root<string> str(str_,this);

	if(fill <= 0x7f)
		memset(&str->data()[start],fill,capacity - start);
	else
	{
		cell i;

		for(i = start; i < capacity; i++)
			set_string_nth(str.untagged(),i,fill);
	}
}

/* Allocates memory */
string *factor_vm::allot_string(cell capacity, cell fill)
{
	gc_root<string> str(allot_string_internal(capacity),this);
	fill_string(str.untagged(),0,capacity,fill);
	return str.untagged();
}

void factor_vm::primitive_string()
{
	cell initial = to_cell(dpop());
	cell length = unbox_array_size();
	dpush(tag<string>(allot_string(length,initial)));
}

bool factor_vm::reallot_string_in_place_p(string *str, cell capacity)
{
	return nursery.contains_p(str)
		&& (!to_boolean(str->aux) || nursery.contains_p(untag<byte_array>(str->aux)))
		&& capacity <= string_capacity(str);
}

string* factor_vm::reallot_string(string *str_, cell capacity)
{
	gc_root<string> str(str_,this);

	if(reallot_string_in_place_p(str.untagged(),capacity))
	{
		str->length = tag_fixnum(capacity);

		if(to_boolean(str->aux))
		{
			byte_array *aux = untag<byte_array>(str->aux);
			aux->capacity = tag_fixnum(capacity * 2);
		}

		return str.untagged();
	}
	else
	{
		cell to_copy = string_capacity(str.untagged());
		if(capacity < to_copy)
			to_copy = capacity;

		gc_root<string> new_str(allot_string_internal(capacity),this);

		memcpy(new_str->data(),str->data(),to_copy);

		if(to_boolean(str->aux))
		{
			byte_array *new_aux = allot_byte_array(capacity * sizeof(u16));

			new_str->aux = tag<byte_array>(new_aux);
			write_barrier(&new_str->aux);

			byte_array *aux = untag<byte_array>(str->aux);
			memcpy(new_aux->data<u16>(),aux->data<u16>(),to_copy * sizeof(u16));
		}

		fill_string(new_str.untagged(),to_copy,capacity,'\0');
		return new_str.untagged();
	}
}

void factor_vm::primitive_resize_string()
{
	string* str = untag_check<string>(dpop());
	cell capacity = unbox_array_size();
	dpush(tag<string>(reallot_string(str,capacity)));
}

void factor_vm::primitive_string_nth()
{
	string *str = untag<string>(dpop());
	cell index = untag_fixnum(dpop());
	dpush(tag_fixnum(str->nth(index)));
}

void factor_vm::primitive_set_string_nth_fast()
{
	string *str = untag<string>(dpop());
	cell index = untag_fixnum(dpop());
	cell value = untag_fixnum(dpop());
	set_string_nth_fast(str,index,value);
}

void factor_vm::primitive_set_string_nth_slow()
{
	string *str = untag<string>(dpop());
	cell index = untag_fixnum(dpop());
	cell value = untag_fixnum(dpop());
	set_string_nth_slow(str,index,value);
}

}
