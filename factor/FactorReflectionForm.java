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

import java.lang.reflect.*;
import org.objectweb.asm.*;

class FactorReflectionForm implements Constants
{
	private FactorList form;

	//{{{ FactorReflectionForm constructor
	FactorReflectionForm(FactorList form)
	{
		this.form = form;
	} //}}}

	//{{{ compile() method
	boolean compile(FactorWord word, FactorInterpreter interp,
		ClassWriter cw, CodeVisitor mw)
		throws Exception
	{
		FactorDictionary dict = interp.dict;
		if(form.car == dict.jvarGet)
		{
			return compileVarGet(word,interp,cw,mw,
				form.next(),false);
		}
		else if(form.car == dict.jvarGetStatic)
		{
			return compileVarGet(word,interp,cw,mw,
				form.next(),true);
		}
		else if(form.car == dict.jinvoke)
		{
			return compileInvoke(word,interp,cw,mw,
				form.next(),false);
		}
		else if(form.car == dict.jinvokeStatic)
		{
			return compileInvoke(word,interp,cw,mw,
				form.next(),true);
		}
		else if(form.car == dict.jnew)
		{
			return compileNew(word,interp,cw,mw,
				form.next());
		}
		else
			throw new FactorRuntimeException("Cannot compile " + form.car);
	} //}}}

	//{{{ compileVarGet() method
	private boolean compileVarGet(FactorWord word,
		FactorInterpreter interp,
		ClassWriter cw,
		CodeVisitor mw,
		FactorList form,
		boolean staticGet) throws Exception
	{
		FactorDictionary dict = interp.dict;
		if(form.car != dict.jfield)
			return false;

		form = form.next();
		String field = (String)form.car;
		String clazz = (String)form.next().car;

		mw.visitVarInsn(ALOAD,2);
		mw.visitFieldInsn(GETFIELD,
			"factor/FactorInterpreter", "datastack",
			"Lfactor/FactorDataStack;");

		if(!staticGet)
		{
			mw.visitInsn(DUP);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "pop",
				"()Ljava/lang/Object;");
		}

		Class cls = FactorJava.getClass(clazz);

		generateFromConversion(mw,cls);

		Field fld = cls.getField(field);

		clazz = clazz.replace('.','/');

		mw.visitFieldInsn(staticGet ? GETSTATIC : GETFIELD,
			clazz,
			field,
			FactorJava.javaClassToVMClass(fld.getType()));

		generateToConversion(mw,fld.getType());

		mw.visitMethodInsn(INVOKEVIRTUAL,
			"factor/FactorArrayStack", "push",
			"(Ljava/lang/Object;)V");

		mw.visitInsn(RETURN);

		mw.visitMaxs(3,3);

		return true;
	} //}}}

	//{{{ compileInvoke() method
	private boolean compileInvoke(FactorWord word,
		FactorInterpreter interp,
		ClassWriter cw,
		CodeVisitor mw,
		FactorList form,
		boolean staticInvoke) throws Exception
	{
		FactorDictionary dict = interp.dict;
		if(form.car != dict.jmethod)
			return false;

		form = form.next();
		String method = (String)form.car;
		String clazz = (String)form.next().car;
		Class[] args = FactorJava.classNameToClassList(
			(FactorList)form.next().next().car);

		mw.visitVarInsn(ALOAD,2);
		mw.visitFieldInsn(GETFIELD,
			"factor/FactorInterpreter", "datastack",
			"Lfactor/FactorDataStack;");

		Class cls = FactorJava.getClass(clazz);
		clazz = clazz.replace('.','/');

		if(!staticInvoke)
		{
			mw.visitInsn(DUP);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "pop",
				"()Ljava/lang/Object;");
			generateFromConversion(mw,cls);
			if(args.length != 0)
				mw.visitInsn(SWAP);
		}

		generateArgs(mw,args,!staticInvoke);

		Method mth = cls.getMethod(method,args);

		Class returnType = mth.getReturnType();
		int opcode;
		if(staticInvoke)
			opcode = INVOKESTATIC;
		else if(cls.isInterface())
			opcode = INVOKEINTERFACE;
		else
			opcode = INVOKEVIRTUAL;
		mw.visitMethodInsn(opcode,
			clazz,
			method,
			FactorJava.javaSignatureToVMSignature(
			args,returnType));

		if(returnType != Void.TYPE)
		{
			generateToConversion(mw,returnType);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "push",
				"(Ljava/lang/Object;)V");
		}
		else
			mw.visitInsn(POP);

		mw.visitInsn(RETURN);

		mw.visitMaxs(4 + args.length,5);

		return true;
	} //}}}

	//{{{ compileNew() method
	private boolean compileNew(FactorWord word,
		FactorInterpreter interp,
		ClassWriter cw,
		CodeVisitor mw,
		FactorList form) throws Exception
	{
		FactorDictionary dict = interp.dict;
		if(form.car != dict.jconstructor)
			return false;

		form = form.next();
		String clazz = (String)form.car;
		Class[] args = FactorJava.classNameToClassList(
			(FactorList)form.next().car);

		clazz = clazz.replace('.','/');
		mw.visitTypeInsn(NEW,clazz);
		mw.visitInsn(DUP);

		mw.visitVarInsn(ALOAD,2);
		mw.visitFieldInsn(GETFIELD,
			"factor/FactorInterpreter", "datastack",
			"Lfactor/FactorDataStack;");

		generateArgs(mw,args,true);

		mw.visitMethodInsn(INVOKESPECIAL,
			clazz,
			"<init>",
			FactorJava.javaSignatureToVMSignature(
			args,void.class));

		mw.visitInsn(SWAP);
		mw.visitMethodInsn(INVOKEVIRTUAL,
			"factor/FactorArrayStack", "push",
			"(Ljava/lang/Object;)V");

		mw.visitInsn(RETURN);

		mw.visitMaxs(5 + args.length,5);

		return true;
	} //}}}

	//{{{ generateArgs() method
	/**
	 * Generate instructions for copying arguments from the Factor
	 * datastack to the JVM stack. The types array is used to
	 * perform type conversions.
	 */
	private void generateArgs(CodeVisitor mw, Class[] args,
		boolean generateSwap) throws Exception
	{
		if(args.length != 0)
		{
			// ensure the stack has enough elements
			mw.visitInsn(DUP);
			mw.visitIntInsn(BIPUSH,args.length);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "ensurePop",
				"(I)V");

			// datastack.stack -> 3
			mw.visitInsn(DUP);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "stack",
				"[Ljava/lang/Object;");
			mw.visitVarInsn(ASTORE,3);
			// datastack.top-args.length -> 4
			mw.visitInsn(DUP);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "top",
				"I");
			mw.visitIntInsn(BIPUSH,args.length);
			mw.visitInsn(ISUB);

			// datastack.top -= args.length
			mw.visitInsn(DUP2);
			mw.visitFieldInsn(PUTFIELD,
				"factor/FactorArrayStack", "top",
				"I");

			mw.visitVarInsn(ISTORE,4);

			if(generateSwap)
				mw.visitInsn(SWAP);

			for(int i = 0; i < args.length; i++)
			{
				mw.visitVarInsn(ALOAD,3);
				mw.visitVarInsn(ILOAD,4);
				mw.visitInsn(AALOAD);
				generateFromConversion(mw,args[i]);
				if(i != args.length - 1)
					mw.visitIincInsn(4,1);
			}
		}
	} //}}}

	//{{{ generateFromConversion() method
	/**
	 * Unbox value at top of the stack.
	 */
	private void generateFromConversion(CodeVisitor mw, Class type)
		throws Exception
	{
		if(type == Object.class)
			return;

		String methodName = null;

		if(type == Number.class)
			methodName = "toNumber";
		else if(type == String.class)
			methodName = "toString";
		else if(type == boolean.class)
			methodName = "toBoolean";
		else if(type == char.class)
			methodName = "toChar";
		else if(type == int.class)
			methodName = "toInt";
		else if(type == long.class)
			methodName = "toLong";
		else if(type == float.class)
			methodName = "toFloat";
		else if(type == double.class)
			methodName = "toDouble";
		else if(type == Class.class)
			methodName = "toClass";
		else if(type.isArray())
			methodName = "toArray";

		if(methodName == null)
		{
			mw.visitTypeInsn(CHECKCAST,
				type.getName()
				.replace('.','/'));
		}
		else
		{
			mw.visitMethodInsn(INVOKESTATIC,
				"factor/FactorJava",
				methodName,
				"(Ljava/lang/Object;)"
				+ FactorJava.javaClassToVMClass(type));
		}
	} //}}}

	//{{{ generateToConversion() method
	/**
	 * Box return value, if needed.
	 */
	private void generateToConversion(CodeVisitor mw, Class type)
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
			Class boxingType = FactorJava.javaBoxingType(type);
			if(boxingType != null)
			{
				String boxingName = boxingType.getName()
					.replace('.','/');
				mw.visitTypeInsn(NEW,boxingName);
				mw.visitInsn(DUP_X1);
				mw.visitInsn(SWAP);
				mw.visitMethodInsn(INVOKESPECIAL,boxingName,
					"<init>",
					"(" + FactorJava.javaClassToVMClass(
					type) + ")V");
			}
		}
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return form.toString();
	} //}}}
}
