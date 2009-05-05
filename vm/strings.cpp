#include "master.hpp"

namespace factor
{

cell string_nth(string* str, cell index)
{
	/* If high bit is set, the most significant 16 bits of the char
	come from the aux vector. The least significant bit of the
	corresponding aux vector entry is negated, so that we can
	XOR the two components together and get the original code point
	back. */
	cell lo_bits = str->data()[index];

	if((lo_bits & 0x80) == 0)
		return lo_bits;
	else
	{
		byte_array *aux = untag<byte_array>(str->aux);
		cell hi_bits = aux->data<u16>()[index];
		return (hi_bits << 7) ^ lo_bits;
	}
}

void set_string_nth_fast(string *str, cell index, cell ch)
{
	str->data()[index] = ch;
}

void set_string_nth_slow(string *str_, cell index, cell ch)
{
	gc_root<string> str(str_);

	byte_array *aux;

	str->data()[index] = ((ch & 0x7f) | 0x80);

	if(str->aux == F)
	{
		/* We don't need to pre-initialize the
		byte array with any data, since we
		only ever read from the aux vector
		if the most significant bit of a
		character is set. Initially all of
		the bits are clear. */
		aux = allot_array_internal<byte_array>(untag_fixnum(str->length) * sizeof(u16));

		write_barrier(str.untagged());
		str->aux = tag<byte_array>(aux);
	}
	else
		aux = untag<byte_array>(str->aux);

	aux->data<u16>()[index] = ((ch >> 7) ^ 1);
}

/* allocates memory */
void set_string_nth(string *str, cell index, cell ch)
{
	if(ch <= 0x7f)
		set_string_nth_fast(str,index,ch);
	else
		set_string_nth_slow(str,index,ch);
}

/* Allocates memory */
string *allot_string_internal(cell capacity)
{
	string *str = allot<string>(string_size(capacity));

	str->length = tag_fixnum(capacity);
	str->hashcode = F;
	str->aux = F;

	return str;
}

/* Allocates memory */
void fill_string(string *str_, cell start, cell capacity, cell fill)
{
	gc_root<string> str(str_);

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
string *allot_string(cell capacity, cell fill)
{
	gc_root<string> str(allot_string_internal(capacity));
	fill_string(str.untagged(),0,capacity,fill);
	return str.untagged();
}

PRIMITIVE(string)
{
	cell initial = to_cell(dpop());
	cell length = unbox_array_size();
	dpush(tag<string>(allot_string(length,initial)));
}

static bool reallot_string_in_place_p(string *str, cell capacity)
{
	return in_zone(&nursery,str)
		&& (str->aux == F || in_zone(&nursery,untag<byte_array>(str->aux)))
		&& capacity <= string_capacity(str);
}

string* reallot_string(string *str_, cell capacity)
{
	gc_root<string> str(str_);

	if(reallot_string_in_place_p(str.untagged(),capacity))
	{
		str->length = tag_fixnum(capacity);

		if(str->aux != F)
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

		gc_root<string> new_str(allot_string_internal(capacity));

		memcpy(new_str->data(),str->data(),to_copy);

		if(str->aux != F)
		{
			byte_array *new_aux = allot_byte_array(capacity * sizeof(u16));

			write_barrier(new_str.untagged());
			new_str->aux = tag<byte_array>(new_aux);

			byte_array *aux = untag<byte_array>(str->aux);
			memcpy(new_aux->data<u16>(),aux->data<u16>(),to_copy * sizeof(u16));
		}

		fill_string(new_str.untagged(),to_copy,capacity,'\0');
		return new_str.untagged();
	}
}

PRIMITIVE(resize_string)
{
	string* str = untag_check<string>(dpop());
	cell capacity = unbox_array_size();
	dpush(tag<string>(reallot_string(str,capacity)));
}

PRIMITIVE(string_nth)
{
	string *str = untag<string>(dpop());
	cell index = untag_fixnum(dpop());
	dpush(tag_fixnum(string_nth(str,index)));
}

PRIMITIVE(set_string_nth_fast)
{
	string *str = untag<string>(dpop());
	cell index = untag_fixnum(dpop());
	cell value = untag_fixnum(dpop());
	set_string_nth_fast(str,index,value);
}

PRIMITIVE(set_string_nth_slow)
{
	string *str = untag<string>(dpop());
	cell index = untag_fixnum(dpop());
	cell value = untag_fixnum(dpop());
	set_string_nth_slow(str,index,value);
}

}
