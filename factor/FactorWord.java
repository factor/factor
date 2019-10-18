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

package factor;

import factor.compiler.*;
import java.util.*;

/**
 * An internalized symbol.
 */
public class FactorWord implements FactorExternalizable, FactorObject
{
	private static int gensymCount = 0;

	private FactorNamespace namespace;

	public final String name;

	/**
	 * Always non-null.
	 */
	public FactorWordDefinition def;

	/**
	 * Contains a string if this is compiled.
	 */
	public String asm;

	/**
	 * Is this word referenced from a compiled word?
	 */
	public boolean compileRef;

	//{{{ FactorWord constructor
	/**
	 * Do not use this constructor unless you're writing a packages
	 * implementation or something. Use an FactorDictionary's
	 * intern() method instead.
	 */
	public FactorWord(String name)
	{
		this.name = name;
		def = new FactorMissingDefinition(this);
	} //}}}

	//{{{ getNamespace() method
	public FactorNamespace getNamespace(FactorInterpreter interp)
		throws Exception
	{
		if(namespace == null)
			namespace = new FactorNamespace(interp.global,this);

		return namespace;
	} //}}}

	//{{{ gensym() method
	/**
	 * Returns an un-internalized word with a unique name.
	 */
	public static FactorWord gensym()
	{
		return new FactorWord("( GENSYM:" + (gensymCount++) + " )");
	} //}}}

	//{{{ define() method
	public void define(FactorWordDefinition def)
	{
		asm = null;

		if(compileRef)
		{
			System.err.println("WARNING: " + this
				+ " is used in one or more compiled words; old definition will remain until full recompile");
		}
		else if(!(this.def instanceof FactorMissingDefinition))
			System.err.println("WARNING: redefining " + this);

		this.def = def;
	} //}}}

	//{{{ compile() method
	public void compile(FactorInterpreter interp)
	{
		RecursiveState recursiveCheck = new RecursiveState();
		recursiveCheck.add(this,null);
		compile(interp,recursiveCheck);
		recursiveCheck.remove(this);
	} //}}}

	//{{{ compile() method
	public void compile(FactorInterpreter interp, RecursiveState recursiveCheck)
	{
		//if(def.compileFailed)
		//	return;

		//System.err.println("Compiling " + this);

		try
		{
			def = def.compile(interp,recursiveCheck);
		}
		catch(Throwable t)
		{
			def.compileFailed = true;
			/*System.err.println("WARNING: cannot compile " + this
				+ ": " + t.getMessage());
			if(!(t instanceof FactorException))
				t.printStackTrace();*/
		}
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return name;
	} //}}}
}
