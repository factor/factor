/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor.db;

import java.io.*;

/**
 * A B-tree index node.
 *
 * Format on disk is:
 * - 1 byte: leaf flag for sanity check
 * - 1 byte: num children
 * - 8 * order bytes: keys
 * - 8 * order bytes: pointers
 */
class BTreeNode
{
	// these two are not saved to disk.
	byte order;
	long offset;

	boolean leaf;
	int children;
	long[] keys;

	/**
	 * In the nodes a the bottom of the tree, these are pointers inside
	 * the data file; otherwise they are pointers inside the index file.
	 */
	long[] pointers;

	/**
	 * Set to true if the node changed and should be saved to disk.
	 */
	boolean dirty;

	//{{{ getSize() method
	/**
	 * Returns the size in bytes of a node with the given order.
	 */
	public static int getSize(int order)
	{
		return 2 + order * 16;
	} //}}}

	//{{{ BTreeNode constructor
	BTreeNode(byte order, long offset)
	{
		this.order = order;
		this.offset = offset;
		this.keys = new long[order];
		this.pointers = new long[order];
	} //}}}

	//{{{ unpackLong() method
	private long unpackLong(byte[] data, int offset)
	{
		return (((long)data[offset + 0] << 56) +
			((long)(data[offset + 1] & 255) << 48) +
			((long)(data[offset + 2] & 255) << 40) +
			((long)(data[offset + 3] & 255) << 32) +
			((long)(data[offset + 4] & 255) << 24) +
			((data[offset + 5] & 255) << 16) +
			((data[offset + 6] & 255) <<  8) +
			((data[offset + 7] & 255) <<  0));
	} //}}}

	//{{{ read() method
	void read(RandomAccessFile in) throws IOException
	{
		in.seek(offset);

		byte[] data = new byte[getSize(order)];
		in.readFully(data);

		int pos = 0;
		leaf = (data[pos++] != 0);
		children = data[pos++];

		for(int i = 0; i < children; i++)
		{
			keys[i] = unpackLong(data,pos);
			pos += 8;
		}

		pos += 8 * (order - children);

		for(int i = 0; i < children; i++)
		{
			pointers[i] = unpackLong(data,pos);
			pos += 8;
		}
	} //}}}

	//{{{ packLong() method
	private void packLong(long num, byte[] data, int offset)
	{
		data[offset + 0] = (byte)(num >>> 56);
		data[offset + 1] = (byte)(num >>> 48);
		data[offset + 2] = (byte)(num >>> 40);
		data[offset + 3] = (byte)(num >>> 32);
		data[offset + 4] = (byte)(num >>> 24);
		data[offset + 5] = (byte)(num >>> 16);
		data[offset + 6] = (byte)(num >>>  8);
		data[offset + 7] = (byte)(num >>>  0);
	} //}}}

	//{{{ write() method
	void write(RandomAccessFile out) throws IOException
	{
		byte[] data = new byte[getSize(order)];

		int pos = 0;
		data[pos++] = (byte)(leaf ? 1 : 0);
		data[pos++] = (byte)children;

		for(int i = 0; i < children; i++)
		{
			packLong(keys[i],data,pos);
			pos += 8;
		}

		pos += 8 * (order - children);

		for(int i = 0; i < children; i++)
		{
			packLong(pointers[i],data,pos);
			pos += 8;
		}

		out.seek(offset);
		out.write(data);
	} //}}}

	//{{{ add() method
	/**
	 * @exception BTreeException on various errors that should not occur
	 */
	void add(long key, long pointer) throws BTreeException
	{
		if(BTreeStore.DEBUG)
		{
			System.err.println("add " + key + "=" + pointer + " to");
			System.err.println(this);
		}

		if(children == order)
			throw new BTreeException("Node full");

		int position = lookupInternal(key);

		if(keys[position] == key && position != children)
			throw new BTreeException("Adding twice");

		// shift the keys along
		for(int i = children - 1; i >= position; i--)
		{
			keys[i + 1] = keys[i];
			pointers[i + 1] = pointers[i];
		}

		keys[position] = key;
		pointers[position] = pointer;

		children++;
	} //}}}

	//{{{ lookupExternal() method
	int lookupExternal(long key)
	{
		for(int i = 0; i < children; i++)
		{
			if(key == keys[i])
				return i;
		}

		return -1;
	} //}}}

	//{{{ lookupInternal() method
	int lookupInternal(long key)
	{
		for(int i = 0; i < children; i++)
		{
			if(key <= keys[i])
				return i;
		}

		return children;
	} //}}}

	//{{{ updateHighest() method
	void updateHighest(long key)
	{
		keys[children - 1] = key;
	} //}}}

	//{{{ split() method
	int split(BTreeNode x, BTreeNode y, long key, boolean leaf)
	{
		x.leaf = leaf;
		y.leaf = leaf;

		int median = children / 2;

		x.children = children - median;
		y.children = median;

		if(order % 2 == 0)
			median--;

		for(int i = 0; i < x.children; i++)
		{
			x.keys[i] = keys[i];
			x.pointers[i] = pointers[i];
		}

		for(int i = 0; i < y.children; i++)
		{
			y.keys[i] = keys[x.children + i];
			y.pointers[i] = pointers[x.children + i];
		}

		return median;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		StringBuffer buf = new StringBuffer(leaf ? "#{ " : "{ ");
		for(int i = 0; i < children; i++)
		{
			buf.append(keys[i]);
			buf.append("=");
			buf.append(pointers[i]);
			buf.append(" ");
		}
		return buf.append("}").toString();
	} //}}}

	//{{{ dump() method
	public void dump(int indent)
	{
		StringBuffer buf = new StringBuffer();
		for(int i = 0; i < indent; i++)
			buf.append(' ');
		buf.append(toString());
		System.err.println(buf);
	} //}}}
}
