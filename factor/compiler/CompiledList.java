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

public class CompiledList extends FlowObject
{
	protected Cons quotation;
	protected RecursiveState recursiveCheck;

	//{{{ CompiledList constructor
	CompiledList(Cons quotation, FactorCompiler compiler,
		RecursiveState recursiveCheck)
	{
		super(compiler,recursiveCheck.lastCallable());
		this.quotation = quotation;
		// clone it
		this.recursiveCheck = new RecursiveState(
			recursiveCheck);
		expectedType = Cons.class;
	} //}}}

	//{{{ pop() method
	public void pop(CodeVisitor mw)
	{
		mw.visitFieldInsn(GETSTATIC,compiler.className,
			compiler.literal(quotation),
			"Ljava/lang/Object;");
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
		return new CompiledListResult(index + base,
			quotation,compiler,
			this.recursiveCheck);
	} //}}}

	//{{{ getLiteral() method
	Object getLiteral()
	{
		return quotation;
	} //}}}

	//{{{ compileCallTo()
	/**
	 * Write code for evaluating this. Returns maximum JVM stack
	 * usage.
	 */
	public void compileCallTo(CodeVisitor mw,
		RecursiveState recursiveCheck)
		throws Exception
	{
		RecursiveForm last = this.recursiveCheck.last();
		FactorWord word = FactorWord.gensym();
		try
		{
			recursiveCheck.add(word,new StackEffect(),
				last.className,last.loader,last.method,last);
			recursiveCheck.last().callable = false;
			compiler.compile(quotation,mw,recursiveCheck);
		}
		finally
		{
			recursiveCheck.remove(word);
		}
	} //}}}

	//{{{ equals() method
	public boolean equals(Object o)
	{
		if(o instanceof CompiledList)
		{
			CompiledList c = (CompiledList)o;
			return FactorLib.objectsEqual(c.quotation,quotation);
		}
		else if(o instanceof Null)
			return quotation == null;
		else
			return false;
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		return new CompiledList(quotation,compiler,recursiveCheck);
	} //}}}
}
