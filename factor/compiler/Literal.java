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

public class Literal extends FlowObject
{
	private Object literal;

	//{{{ Literal constructor
	Literal(Object literal, FactorCompiler compiler,
		RecursiveForm word)
	{
		super(compiler,word);
		this.literal = literal;
		expectedType = literal.getClass();
	} //}}}

	//{{{ pop() method
	public void pop(CodeVisitor mw)
	{
		mw.visitFieldInsn(GETSTATIC,compiler.className,
			compiler.literal(literal),
			"Ljava/lang/Object;");
	} //}}}

	//{{{ getLiteral() method
	Object getLiteral()
	{
		return literal;
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Write code for evaluating this. Returns maximum JVM stack
	 * usage.
	 */
	public void compileCallTo(CodeVisitor mw, RecursiveState recursiveCheck)
		throws Exception
	{
		throw new FactorCompilerException("Not a quotation: " + literal);
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		return new Literal(literal,compiler,word);
	} //}}}
}
