/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003 Slava Pestov.
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

import factor.compiler.*;
import factor.*;
import java.util.*;

/**
 * An object that persists to a name/value list.
 */
public class SimplePersistentObject implements FactorObject,
	PersistentObject
{
	protected Workspace workspace;
	protected long id;
	protected Table table;

	//{{{ SimplePersistentObject constructor
	public SimplePersistentObject()
	{
		try
		{
			table = new Table(this);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ SimplePersistentObject constructor
	public SimplePersistentObject(Workspace workspace, long id)
		throws Exception
	{
		this.workspace = workspace;
		this.id = id;
		table = new Table(this,workspace,0L);
	} //}}}

	//{{{ SimplePersistentObject constructor
	public SimplePersistentObject(Workspace workspace) throws Exception
	{
		this(workspace,workspace == null ? 0L : workspace.nextID());
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
		throws PersistenceException
	{
		return table.pickle();
	} //}}}

	//{{{ unpickle() method
	/**
	 * Each persistent object can set its state to that in a byte array.
	 */
	public void unpickle(byte[] bytes, int offset)
		throws PersistenceException
	{
		table.unpickle(bytes,offset);
	} //}}}

	//{{{ getNamespace() method
	public FactorNamespace getNamespace()
		throws Exception
	{
		return table;
	} //}}}

	//{{{ getReferences() method
	public Cons getReferences()
	{
		return table.getReferences();
	} //}}}
}
