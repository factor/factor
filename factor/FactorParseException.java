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

public class FactorParseException extends FactorException
{
	private String filename;
	private int lineno;
	private int position;
	private String msg;

	public FactorParseException(
		String filename,
		int lineno,
		String str)
	{
		super(filename + ":" + lineno + ": " + str);
		this.filename = filename;
		this.lineno = lineno;
		this.msg = str;
	}

	public FactorParseException(
		String filename,
		int lineno,
		String line,
		int position,
		String str)
	{
		super(filename + ":" + lineno + ": " + str
			+ "\n" + getDetailMessage(line,position));
		this.filename = filename;
		this.lineno = lineno;
		this.position = position;
		this.msg = str;
	}

	public String getFileName()
	{
		return filename;
	}

	public int getLineNumber()
	{
		return lineno;
	}

	public int getPosition()
	{
		return position;
	}

	public String getParserMessage()
	{
		return msg;
	}

	private static String getDetailMessage(String line, int position)
	{
		if(line == null)
			return "#<at end of file>";

		StringBuffer buf = new StringBuffer(line);
		buf.append('\n');
		for(int i = 0; i < position; i++)
			buf.append(' ');
		buf.append('^');
		return buf.toString();
	}
}
