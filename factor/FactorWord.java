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

import java.util.*;

/**
 * An internalized symbol.
 */
public class FactorWord implements FactorExternalizable
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
	 * Should the parser keep doc comments?
	 */
	public boolean docComment;

	/**
	 * For text editor integration.
	 */
	public String file;
	public int line;
	public int col;

	//{{{ FactorWord constructor
	/**
	 * Do not use this constructor unless you're writing a packages
	 * implementation or something. Use an FactorDictionary's
	 * intern() method instead.
	 */
	public FactorWord(String vocabulary, String name,
		FactorWordDefinition def)
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

	//{{{ define() method
	public void define(FactorWordDefinition def)
	{
		this.def = def;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return name == null ? "#<unnamed>" : name;
	} //}}}
}
