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

package factor.compiler;

import factor.*;
import java.lang.reflect.*;
import java.util.*;
import org.objectweb.asm.*;

public class Null extends FlowObject
{
	//{{{ Null constructor
	Null(FactorCompiler compiler, RecursiveForm word)
	{
		super(compiler,word);
	} //}}}

	//{{{ pop() Method
	public void pop(CodeVisitor mw)
	{
		mw.visitInsn(ACONST_NULL);
	} //}}}

	//{{{ munge() method
	/**
	 * Munging transforms the flow object such that it is now stored in
	 * a local variable and hence can be mutated by compiled code, however
	 * its original compileCallTo() semantics remain (for example, if it is
	 * a quotation).
	 */
	FlowObject munge(int base, int index,
		FactorCompiler compiler,
		RecursiveState recursiveCheck)
		throws Exception
	{
		return new CompiledListResult(index + base,null,
			compiler,recursiveCheck);
	} //}}}

	//{{{ getLiteral() method
	Object getLiteral()
	{
		return null;
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Write code for evaluating this. Returns maximum JVM stack
	 * usage.
	 */
	public void compileCallTo(CodeVisitor mw, RecursiveState recursiveCheck)
		throws Exception
	{
	} //}}}

	//{{{ equals() method
	public boolean equals(Object o)
	{
		if(o instanceof Null)
			return true;
		else if(o instanceof CompiledList)
			return ((CompiledList)o).getLiteral() == null;
		else
			return false;
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		return new Null(compiler,word);
	} //}}}
}
