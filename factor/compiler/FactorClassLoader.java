/* :folding=explicit:collapseFolds=1: */

/*
* $Id$
*
* Copyright (C) 2003, 2004 Slava Pestov.
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

package factor.compiler;

import factor.Cons;
import factor.FactorInterpreter;
import factor.db.*;
import java.util.*;

/**
 * Each word class has a class loader.
 *
 * When compiling a word; add each dependent word to new class loader's
 * delegates map.
 */
public class FactorClassLoader extends ClassLoader implements PersistentObject
{
	private Workspace workspace;
	private long id;
	private Table table;

	//{{{ FactorClassLoader constructor
	public FactorClassLoader(Workspace workspace, long id)
		throws Exception
	{
		this.workspace = workspace;
		this.id = id;
		table = new Table(null,workspace,0L);
		if(workspace != null && id != 0L)
			workspace.put(this);
	} //}}}

	//{{{ FactorClassLoader constructor
	public FactorClassLoader(Workspace workspace) throws Exception
	{
		this(workspace,workspace == null ? 0L : workspace.nextID());
	} //}}}

	//{{{ addDependency() method
	public void addDependency(String name, FactorClassLoader loader)
	{
		try
		{
			table.setVariable(name,loader);
			if(workspace != null && id != 0L)
				workspace.put(this);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
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

	//{{{ addClass() method
	public Class addClass(String name, byte[] code, int off, int len)
	{
		try
		{
			table.setVariable(name,
				new PersistentBinary(workspace,code));
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}

		return defineClass(name,code,off,len);
	} //}}}

	//{{{ loadClass() method
	public synchronized Class loadClass(String name, boolean resolve)
		throws ClassNotFoundException
	{
		Class c = findLoadedClass(name);
		if(c != null)
		{
			if(resolve)
				resolveClass(c);
			return c;
		}

		// See if another known class loader has this
		try
		{
			Object obj = table.getVariable(name);
			if(obj instanceof FactorClassLoader)
			{
				return ((FactorClassLoader)obj)
					.loadClass(name,resolve);
			}
			else if(obj instanceof PersistentBinary)
			{
				byte[] bytes = ((PersistentBinary)obj)
					.getBytes();
				c = defineClass(
					name,bytes,0,bytes.length);
				if(resolve)
					resolveClass(c);
				return c;
			}
			else if(obj != null)
			{
				System.err.println("WARNING: unknown object in class loader table for " + this + ": " + obj);
			}

			return super.loadClass(name,resolve);
		}
		catch(ClassNotFoundException e)
		{
			throw e;
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ getReferences() method
	public Cons getReferences()
	{
		return table.getReferences();
	} //}}}
}
