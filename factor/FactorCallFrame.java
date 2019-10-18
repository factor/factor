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

public class FactorCallFrame implements PublicCloneable, FactorExternalizable
{
	/**
	 * Word being evaluated.
	 */
	public FactorWord word;

	/**
	 * Namespace.
	 */
	public FactorNamespace namespace;

	/**
	 * Next word to be evaluated.
	 */
	public FactorList ip;

	/**
	 * Collapsed tail calls? See call().
	 */
	public boolean collapsed;

	//{{{ FactorCallFrame constructor
	public FactorCallFrame()
	{
	} //}}}

	//{{{ FactorCallFrame constructor
	public FactorCallFrame(FactorWord word,
		FactorNamespace namespace,
		FactorList ip)
	{
		this.word = word;
		this.namespace = namespace;
		this.ip = ip;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return toString(0);
	} //}}}

	//{{{ toString() method
	public String toString(int level)
	{
		StringBuffer buf = new StringBuffer();
		for(int i = 0; i < level; i++)
		{
			buf.append("    ");
		}
		String indent = buf.toString();

		buf = new StringBuffer();
		buf.append(indent);

		if(collapsed)
			buf.append("at ... then ");

		buf.append("at ").append(word);

		buf.append('\n').append(indent);

		buf.append("  namespace: ").append(namespace)
			.append('\n').append(indent);

		buf.append("  ip: ").append(ip);

		return buf.toString();
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		try
		{
			return super.clone();
		}
		catch(Exception e)
		{
			return null;
		}
	} //}}}
}
