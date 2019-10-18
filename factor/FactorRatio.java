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

public class FactorRatio extends Number implements FactorExternalizable
{
	public final Number numerator, denominator;

	//{{{ FactorRatio constructor
	/**
	 * Creates a new ratio.
	 */
	public FactorRatio(Number numerator, Number denominator)
	{
		this.numerator = numerator;
		this.denominator = denominator;
	} //}}}

	//{{{ add() method
	public Number add(Number num)
	{
		if(num instanceof FactorRatio)
		{
			// a   c   ad + bc
			// - + - = -------
			// b   d     bd
			FactorRatio r = (FactorRatio)num;
			return reduce(
				FactorMath.add(
					FactorMath.multiply(numerator,r.denominator),
					FactorMath.multiply(denominator,r.numerator)),
				FactorMath.multiply(denominator,r.denominator));
		}
		else if(num instanceof Float
			|| num instanceof Double)
		{
			return new Double(doubleValue() + num.doubleValue());
		}
		else
		{
			return reduce(
				FactorMath.add(numerator,
					FactorMath.multiply(denominator,num)),
				denominator);
		}
	} //}}}

	//{{{ subtract() method
	/**
	 * this - num
	 */
	public Number subtract(Number num)
	{
		if(num instanceof FactorRatio)
		{
			// a   c   ad - bc
			// - - - = -------
			// b   d     bd
			FactorRatio r = (FactorRatio)num;
			return reduce(
				FactorMath.subtract(
					FactorMath.multiply(numerator,r.denominator),
					FactorMath.multiply(denominator,r.numerator)),
				FactorMath.multiply(denominator,r.denominator));
		}
		else if(num instanceof Float
			|| num instanceof Double)
		{
			return new Double(doubleValue() - num.doubleValue());
		}
		else
		{
			return reduce(
				FactorMath.subtract(numerator,
					FactorMath.multiply(denominator,num)),
				denominator);
		}
	} //}}}

	//{{{ _subtract() method
	/**
	 * num - this
	 */
	public Number _subtract(Number num)
	{
		if(num instanceof FactorRatio)
		{
			// a   c   bc - ad
			// - - - = -------
			// b   d     bd
			FactorRatio r = (FactorRatio)num;
			return reduce(
				FactorMath.subtract(
					FactorMath.multiply(denominator,r.numerator),
					FactorMath.multiply(numerator,r.denominator)),
				FactorMath.multiply(denominator,r.denominator));
		}
		else if(num instanceof Float
			|| num instanceof Double)
		{
			return new Double(num.doubleValue() - doubleValue());
		}
		else
		{
			return reduce(
				FactorMath.subtract(FactorMath.multiply(denominator,num),
					numerator),
				denominator);
		}
	} //}}}

	//{{{ multiply() method
	public Number multiply(Number num)
	{
		if(num instanceof FactorRatio)
		{
			// a   c   ac
			// - * - = --
			// b   d   bd
			FactorRatio r = (FactorRatio)num;
			return reduce(
				FactorMath.multiply(numerator,r.numerator),
				FactorMath.multiply(denominator,r.denominator));
		}
		else if(num instanceof Float
			|| num instanceof Double)
		{
			return new Double(doubleValue() * num.doubleValue());
		}
		else
		{
			return reduce(
				FactorMath.multiply(numerator,num),
				denominator);
		}
	} //}}}

	//{{{ divide() method
	/**
	 * this / num
	 */
	public Number divide(Number num)
	{
		if(num instanceof FactorRatio)
		{
			// a   c   ad
			// - / - = --
			// b   d   bc
			FactorRatio r = (FactorRatio)num;
			return reduce(
				FactorMath.multiply(numerator,r.denominator),
				FactorMath.multiply(denominator,r.numerator));
		}
		else if(num instanceof Float
			|| num instanceof Double)
		{
			return new Double(doubleValue() / num.doubleValue());
		}
		else
		{
			return reduce(numerator,
				FactorMath.multiply(denominator,num));
		}
	} //}}}

	//{{{ _divide() method
	/**
	 * num / this
	 */
	public Number _divide(Number num)
	{
		if(num instanceof FactorRatio)
		{
			// c   a   cb
			// - / - = --
			// d   b   da
			FactorRatio r = (FactorRatio)num;
			return reduce(
				FactorMath.multiply(denominator,r.numerator),
				FactorMath.multiply(numerator,r.denominator));
		}
		else if(num instanceof Float
			|| num instanceof Double)
		{
			return new Double(num.doubleValue() / doubleValue());
		}
		else
		{
			return reduce(
				FactorMath.multiply(denominator,num),
				numerator);
		}
	} //}}}

	//{{{ reduce() method
	public static Number reduce(Number numerator, Number denominator)
	{
		if(FactorMath.sgn(denominator) == 0)
			throw new ArithmeticException("/ by zero");
		if(FactorMath.sgn(denominator) == -1)
		{
			numerator = FactorMath.neg(numerator);
			denominator = FactorMath.neg(denominator);
		}

		Number gcd = FactorMath.gcd(numerator,denominator);
		if(!FactorMath.is1(gcd))
		{
			numerator = FactorMath._divide(numerator,gcd);
			denominator = FactorMath._divide(denominator,gcd);
		}

		if(FactorMath.is1(denominator))
			return numerator;
		else
			return new FactorRatio(numerator,denominator);
	} //}}}

	//{{{ neg() method
	public FactorRatio neg()
	{
		return new FactorRatio(FactorMath.neg(numerator),denominator);
	} //}}}

	//{{{ intValue() method
	public int intValue()
	{
		return (int)doubleValue();
	} //}}}

	//{{{ longValue() method
	public long longValue()
	{
		return (long)doubleValue();
	} //}}}

	//{{{ floatValue() method
	public float floatValue()
	{
		return (float)doubleValue();
	} //}}}

	//{{{ doubleValue() method
	public double doubleValue()
	{
		return numerator.doubleValue() / denominator.doubleValue();
	} //}}}

	//{{{ byteValue() method
	public byte byteValue()
	{
		return (byte)doubleValue();
	} //}}}

	//{{{ shortValue() method
	public short shortValue()
	{
		return (short)doubleValue();
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return numerator + "/" + denominator;
	} //}}}
}
