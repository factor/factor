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
import java.math.BigInteger;
import java.util.*;
import org.objectweb.asm.*;

public abstract class FlowObject
implements Constants, FactorExternalizable, PublicCloneable
{
	protected FactorCompiler compiler;
	protected RecursiveForm word;
	protected Class expectedType;

	//{{{ FlowObject constructor
	FlowObject(FactorCompiler compiler,
		RecursiveForm word)
	{
		this.compiler = compiler;
		this.word = word;
		expectedType = Object.class;
	} //}}}

	//{{{ push() method
	protected void push(CodeVisitor mw)
		throws Exception
	{
		throw new FactorCompilerException("Cannot push: " + this);
	} //}}}

	//{{{ push() method
	public void push(CodeVisitor mw, Class type)
		throws Exception
	{
		if(type == null)
			throw new NullPointerException();
		expectedType = (type.isPrimitive()
			? FactorJava.getBoxingType(type)
			: type);
		if(mw != null)
		{
			generateToConversion(mw,type);
			push(mw);
		}
	} //}}}

	protected abstract void pop(CodeVisitor mw);

	//{{{ pop() method
	public void pop(CodeVisitor mw, Class type)
		throws Exception
	{
		if(mw != null)
			pop(mw);

		Class actualType;
		if(type.isPrimitive())
			actualType = FactorJava.getBoxingType(type);
		else
			actualType = type;

		// if we're looking for a subclass the expected type,
		// specialize the expected type.
		if(expectedType.isAssignableFrom(actualType))
			expectedType = actualType;
		// if we're looking for a superclass, that is ok too,
		// eg we can generate every flow object as a
		// java.lang.Object instance
		else if(actualType.isAssignableFrom(expectedType))
			/* do nothing */;
		// otherwise, type error!
		else
		{
			/* System.err.println(new TypeInferenceException(
				this,expectedType,actualType)); */
		}

		if(mw != null)
			generateFromConversion(mw,type);
	} //}}}

	//{{{ getConversionMethodName() method
	/**
	 * Returns method name for converting an object to the given type.
	 * Only for primitives.
	 */
	private static String getConversionMethodName(Class type)
	{
		if(type.isPrimitive())
		{
			String name = type.getName();
			return "to"
				+ Character.toUpperCase(name.charAt(0))
				+ name.substring(1);
		}
		else
			return null;
	} //}}}

	//{{{ generateFromConversion() method
	/**
	 * Unbox value at top of the stack.
	 */
	private static void generateFromConversion(CodeVisitor mw, Class type)
		throws Exception
	{
		if(type == Object.class)
			return;

		String methodName = null;

		if(type == Number.class)
			methodName = "toNumber";
		if(type == BigInteger.class)
			methodName = "toBigInteger";
		else if(type == String.class)
			methodName = "toString";
		else if(type == CharSequence.class)
			methodName = "toCharSequence";
		else if(type.isPrimitive())
			methodName = getConversionMethodName(type);
		else if(type == Class.class)
			methodName = "toClass";
		else if(type == FactorNamespace.class)
			methodName = "toNamespace";
		else if(type.isArray())
		{
			Class comp = type.getComponentType();
			if(comp.isPrimitive())
			{
				methodName = getConversionMethodName(comp)
					+ "Array";
			}
			else
				methodName = "toArray";
		}

		if(methodName == null)
		{
			mw.visitTypeInsn(CHECKCAST,
				type.getName()
				.replace('.','/'));
		}
		else
		{
			String signature;
			if(type.isArray())
			{
				signature = "(Ljava/lang/Object;)"
					+ "[Ljava/lang/Object;";
			}
			else
			{
				signature = "(Ljava/lang/Object;)"
					+ FactorJava.javaClassToVMClass(type);
			}
			mw.visitMethodInsn(INVOKESTATIC,"factor/FactorJava",
				methodName,signature);
			/* if(type.isArray())
			{
				mw.visitTypeInsn(CHECKCAST,
					type.getName()
					.replace('.','/'));
			} */
		}
	} //}}}

	//{{{ generateToConversionPre() method
	/**
	 * Avoid having to deal with category 1/2 computational type
	 * distinction.
	 */
	public static void generateToConversionPre(CodeVisitor mw, Class type)
		throws Exception
	{
		if(type == boolean.class)
			return;

		Class boxingType = FactorJava.getBoxingType(type);
		if(boxingType != null)
		{
			String boxingName = boxingType.getName()
				.replace('.','/');
			mw.visitTypeInsn(NEW,boxingName);
			mw.visitInsn(DUP);
		}
	} //}}}

	//{{{ generateToConversion() method
	/**
	 * Box return value, if needed.
	 */
	private static void generateToConversion(CodeVisitor mw, Class type)
		throws Exception
	{
		if(type == boolean.class)
		{
			// this case is handled specially
			mw.visitMethodInsn(INVOKESTATIC,
				"factor/FactorJava",
				"fromBoolean",
				"(Z)Ljava/lang/Object;");
		}
		else
		{
			Class boxingType = FactorJava.getBoxingType(type);
			if(boxingType != null)
			{
				String boxingName = boxingType.getName()
					.replace('.','/');
				mw.visitMethodInsn(INVOKESPECIAL,boxingName,
					"<init>",
					"(" + FactorJava.javaClassToVMClass(
					type) + ")V");
			}
		}
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
		return new Result(index + base,compiler,recursiveCheck.last(),
			expectedType);
	} //}}}

	//{{{ usingLocal() method
	boolean usingLocal(int local)
	{
		return false;
	} //}}}

	//{{{ getLiteral() method
	Object getLiteral()
		throws FactorCompilerException
	{
		throw new FactorCompilerException("Cannot compile unless literal on stack: " + this);
	} //}}}

	//{{{ getLocal() method
	/**
	 * @return -1 if the result is not store in a local variable.
	 */
	public int getLocal()
	{
		return -1;
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Write code for evaluating this. Returns maximum JVM stack
	 * usage.
	 */
	public void compileCallTo(CodeVisitor mw, RecursiveState recursiveCheck)
		throws Exception
	{
		throw new FactorCompilerException("Cannot compile call to non-literal quotation");
	} //}}}

	//{{{ getWord() method
	/**
	 * Returns the word where this flow object originated from.
	 */
	public RecursiveForm getWord()
	{
		return word;
	} //}}}

	//{{{ getType() method
	public Class getType()
	{
		return expectedType;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		try
		{
			return FactorReader.unparseObject(getLiteral());
		}
		catch(Exception e)
		{
			throw new RuntimeException("Override toString() if your getLiteral() bombs!");
		}
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		// cannot be abstract, and cannot be left undefined!
		throw new InternalError();
	} //}}}
}
