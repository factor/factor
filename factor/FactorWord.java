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

package factor;

import factor.compiler.*;
import java.util.*;

/**
 * An internalized symbol.
 */
public class FactorWord implements FactorExternalizable, FactorObject
{
	private static int gensymCount = 0;

	public String vocabulary;
	public String name;

	/**
	 * Interpreted/compiled word definition.
	 */
	public FactorWordDefinition def;

	/**
	 * Parsing word definition.
	 */
	public FactorParsingDefinition parsing;

	/**
	 * Is this word referenced from a compiled word?
	 */
	public boolean compileRef;

	/**
	 * Should this word be inlined when compiling?
	 */
	public boolean inline;

	/**
	 * Raise an error if an attempt is made to compile this word?
	 */
	public boolean interpretOnly;

	/**
	 * Only compiled words have this.
	 */
	public FactorClassLoader loader;
	public String className;

	private FactorNamespace namespace;
	
	//{{{ FactorWord constructor
	/**
	 * Do not use this constructor unless you're writing a packages
	 * implementation or something. Use an FactorDictionary's
	 * intern() method instead.
	 */
	public FactorWord(String vocabulary, String name,
		FactorWordDefinition def) throws Exception
	{
		this.vocabulary = vocabulary;
		this.name = name;
		this.def = def;
	} //}}}

	//{{{ FactorWord constructor
	/**
	 * Do not use this constructor unless you're writing a packages
	 * implementation or something. Use an FactorDictionary's
	 * intern() method instead.
	 */
	public FactorWord(String vocabulary, String name)
	{
		this.vocabulary = vocabulary;
		this.name = name;
	} //}}}

	//{{{ getNamespace() method
	public FactorNamespace getNamespace()
		throws Exception
	{
		if(namespace == null)
			namespace = new FactorNamespace(this);
		return namespace;
	} //}}}
	
	//{{{ gensym() method
	/**
	 * Returns an un-internalized word with a unique name.
	 */
	public synchronized static FactorWord gensym()
	{
		return new FactorWord(null,"#:GENSYM:" + (gensymCount++));
	} //}}}

	//{{{ define() method
	public synchronized void define(FactorWordDefinition def)
	{
		if(compileRef)
		{
			System.err.println("WARNING: " + this
				+ " is used in one or more compiled words; old definition will remain until full recompile");
		}
		else if(this.def != null)
			System.err.println("WARNING: redefining " + this);

		this.def = def;

		loader = null;
		className = null;
	} //}}}

	//{{{ setCompiledInfo() method
	synchronized void setCompiledInfo(FactorClassLoader loader,
		String className)
	{
		this.loader = loader;
		this.className = className;
	} //}}}

	//{{{ compile() method
	public synchronized void compile(FactorInterpreter interp)
	{
		RecursiveState recursiveCheck = new RecursiveState();
		recursiveCheck.add(this,new StackEffect(),null,null,null);
		compile(interp,recursiveCheck);
		recursiveCheck.remove(this);
	} //}}}

	//{{{ compile() method
	public synchronized void compile(FactorInterpreter interp,
		RecursiveState recursiveCheck)
	{
		if(def == null)
			return;

		if(interpretOnly)
		{
			if(interp.verboseCompile)
				System.err.println(this + " is interpret-only");
			return;
		}

		//if(def.compileFailed)
		//	return;

		if(interp.verboseCompile)
			System.err.println("Compiling " + this);

		try
		{
			def = def.compile(interp,recursiveCheck);
		}
		catch(Throwable t)
		{
			def.compileFailed = true;
			if(interp.verboseCompile)
			{
				System.err.println("WARNING: cannot compile " + this);
				t.printStackTrace();
			}
		}
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return name == null ? "#<unnamed>"
			: FactorReader.charsToEscapes(name);
	} //}}}
}
