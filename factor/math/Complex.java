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

package factor.math;

import factor.FactorLib;

public class Complex extends FactorNumber
{
	public final Number real, imaginary;

	//{{{ Complex constructor
	/**
	 * Creates a new complex number.
	 */
	private Complex(Number real, Number imaginary)
	{
		this.real = real;
		this.imaginary = imaginary;
	} //}}}

	//{{{ add() method
	public Number add(Number num)
	{
		if(num instanceof Complex)
		{
			Complex c = (Complex)num;

			return valueOf(
				FactorMath.add(real,c.real),
				FactorMath.add(imaginary,c.imaginary));
		}
		else
		{
			return valueOf(
				FactorMath.add(real,num),
				imaginary);
		}
	} //}}}

	//{{{ subtract() method
	/**
	 * this - num
	 */
	public Number subtract(Number num)
	{
		if(num instanceof Complex)
		{
			Complex c = (Complex)num;

			return valueOf(
				FactorMath.subtract(real,c.real),
				FactorMath.subtract(imaginary,c.imaginary));
		}
		else
		{
			return valueOf(
				FactorMath.subtract(real,num),
				imaginary);
		}
	} //}}}

	//{{{ _subtract() method
	/**
	 * num - this
	 */
	public Number _subtract(Number num)
	{
		if(num instanceof Complex)
		{
			Complex c = (Complex)num;

			return valueOf(
				FactorMath.subtract(c.real,real),
				FactorMath.subtract(c.imaginary,imaginary));
		}
		else
		{
			return valueOf(
				FactorMath.subtract(num,real),
				FactorMath.neg(imaginary));
		}
	} //}}}

	//{{{ multiply() method
	/**
	 * (a+bi)*(c+di) = ac - bd + (ad + bc)i
	 */
	public Number multiply(Number num)
	{
		if(num instanceof Complex)
		{
			Complex c = (Complex)num;

			return valueOf(
				FactorMath.subtract(
					FactorMath.multiply(real,c.real),
					FactorMath.multiply(imaginary,c.imaginary)),
				FactorMath.add(
					FactorMath.multiply(real,c.imaginary),
					FactorMath.multiply(imaginary,c.real)));
		}
		else
		{
			return valueOf(
				FactorMath.multiply(num,real),
				FactorMath.multiply(num,imaginary));
		}
	} //}}}

	//{{{ magnitude2() method
	/**
	 * Magnitude squared.
	 */
	public Number magnitude2()
	{
		return FactorMath.add(FactorMath.multiply(real,real),
			FactorMath.multiply(imaginary,imaginary));
	} //}}}

	//{{{ divide() method
	/**
	 * a+bi   (a+bi)*(c-di)   ac + db + (cb - ad)i
	 * ---- = ------------- = --------------------
	 * c+di       cc+dd            cc + dd
	 */
	public Number divide(Number num)
	{
		if(num instanceof Complex)
		{
			Complex c = (Complex)num;
			Number mag = c.magnitude2();
			Number r = FactorMath.add(
				FactorMath.multiply(real,c.real),
				FactorMath.multiply(imaginary,c.imaginary));
			Number i = FactorMath.subtract(
				FactorMath.multiply(imaginary,c.real),
				FactorMath.multiply(real,c.imaginary));
			return valueOf(
				FactorMath.divide(r,mag),
				FactorMath.divide(i,mag));
		}
		else
		{
			return valueOf(FactorMath.divide(real,num),
				FactorMath.divide(imaginary,num));
		}
	} //}}}

	//{{{ _divide() method
	/**
	 * num / this
	 */
	public Number _divide(Number num)
	{
		Number mag = magnitude2();

		if(num instanceof Complex)
		{
			Complex c = (Complex)num;
			Number r = FactorMath.add(
				FactorMath.multiply(c.real,real),
				FactorMath.multiply(c.imaginary,imaginary));
			Number i = FactorMath.subtract(
				FactorMath.multiply(c.imaginary,real),
				FactorMath.multiply(c.real,imaginary));
			return valueOf(
				FactorMath.divide(r,mag),
				FactorMath.divide(i,mag));
		}
		else
		{
			Number r = FactorMath.multiply(real,num);
			Number i = FactorMath.neg(
				FactorMath.multiply(imaginary,num));
			return valueOf(FactorMath.divide(r,mag),
				FactorMath.divide(i,mag));
		}
	} //}}}

	//{{{ neg() method
	public Number neg()
	{
		return new Complex(FactorMath.neg(real),
			FactorMath.neg(imaginary));
	} //}}}

	//{{{ valueOf() method
	public static Number valueOf(Number real, Number imaginary)
	{
		if(FactorMath.is0(imaginary))
			return real;
		else if(real instanceof Complex)
			throw new ArithmeticException("Not a real: " + real);
		if(imaginary instanceof Complex)
			throw new ArithmeticException("Not a real: " + imaginary);
		else
			return new Complex(real,imaginary);
	} //}}}

	//{{{ intValue() method
	public int intValue()
	{
		return real.intValue();
	} //}}}

	//{{{ longValue() method
	public long longValue()
	{
		return real.longValue();
	} //}}}

	//{{{ floatValue() method
	public float floatValue()
	{
		return real.floatValue();
	} //}}}

	//{{{ doubleValue() method
	public double doubleValue()
	{
		return real.doubleValue();
	} //}}}

	//{{{ byteValue() method
	public byte byteValue()
	{
		return real.byteValue();
	} //}}}

	//{{{ shortValue() method
	public short shortValue()
	{
		return real.shortValue();
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return "#{ " + real + " " + imaginary + " }";
	} //}}}

	//{{{ equals() method
	public boolean equals(Object o)
	{
		if(o instanceof Complex)
		{
			Complex c = (Complex)o;
			return FactorLib.equal(real,c.real)
				&& FactorLib.equal(imaginary,c.imaginary);
		}
		else
			return false;
	} //}}}

	//{{{ hashCode() method
	public int hashCode()
	{
		return real.hashCode() ^ imaginary.hashCode();
	} //}}}
}
