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

import factor.Cons;
import factor.FactorInterpreter;

/**
 * A simple wrapper around a byte array stored in the object database.
 */
public class PersistentBinary implements PersistentObject
{
	private Workspace workspace;
	private long id;
	private byte[] bytes;

	//{{{ PersistentBinary constructor
	public PersistentBinary(Workspace workspace, byte[] bytes)
		throws Exception
	{
		this(workspace,workspace == null ? 0L : workspace.nextID());
		this.bytes = bytes;
	} //}}}

	//{{{ PersistentBinary constructor
	public PersistentBinary(Workspace workspace, long id) throws Exception
	{
		this.workspace = workspace;
		this.id = id;

		if(workspace != null && id != 0L)
			workspace.put(this);
	} //}}}

	//{{{ getBytes() method
	public byte[] getBytes()
	{
		return bytes;
	} //}}}

	//{{{ getWorkspace() method
	/**
	 * Each persistent object is stored in one workspace only.
	 */
	public Workspace getWorkspace()
	{
		return workspace;
	} //}}}

	//{{{ getID() method
	/**
	 * Each persistent object has an associated ID.
	 */
	public long getID()
	{
		return id;
	} //}}}

	//{{{ pickle() method
	/**
	 * Each persistent object can turn itself into a byte array.
	 */
	public byte[] pickle()
	{
		return bytes;
	} //}}}

	//{{{ unpickle() method
	/**
	 * Each persistent object can set its state to that in a byte array.
	 */
	public void unpickle(byte[] bytes, int offset)
	{
		if(offset == 0)
			this.bytes = bytes;
		else
		{
			int len = bytes.length - offset;
			this.bytes = new byte[len];
			System.arraycopy(bytes,offset,this.bytes,0,len);
		}
	} //}}}

	//{{{ getReferences() method
	public Cons getReferences()
	{
		return null;
	} //}}}
}
