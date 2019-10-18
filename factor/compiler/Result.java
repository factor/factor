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
import java.util.*;
import org.objectweb.asm.*;

public class Result extends FlowObject
{
	private int local;
	private boolean input;

	public Result(int local, FactorCompiler compiler,
		RecursiveForm word, Class type)
	{
		this(local,compiler,word,type,false);
	}

	/**
	 * @param input An input result contains a parameter passed to a
	 * compiled word's core() method.
	 */
	public Result(int local, FactorCompiler compiler,
		RecursiveForm word, Class type,
		boolean input)
	{
		super(compiler,word);
		this.local = local;
		if(type == null)
			throw new NullPointerException();
		this.expectedType = (type.isPrimitive()
			? FactorJava.getBoxingType(type)
			: type);
		this.input = input;
	}

	public void push(CodeVisitor mw)
		throws Exception
	{
		mw.visitVarInsn(ASTORE,local);
	}

	public void pop(CodeVisitor mw)
	{
		mw.visitVarInsn(ALOAD,local);
	}

	public int getLocal()
	{
		return local;
	}

	boolean usingLocal(int local)
	{
		return (this.local == local);
	}

	public boolean isInput()
	{
		return input;
	}
	
	public String toString()
	{
		return expectedType.getName() + "#" + local;
	}

	//{{{ clone() method
	public Object clone()
	{
		return new Result(local,compiler,word,expectedType);
	} //}}}
}
