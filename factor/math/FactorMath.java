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

package factor.math;

import java.math.*;
import java.util.Random;

/**
 * Math-related words.
 */
public class FactorMath
{
	private static Random random = new Random();

	//{{{ add() method
	public static Number add(Number x, Number y)
	{
		if(y instanceof FactorNumber)
			return ((FactorNumber)y).add(x);
		else if(x instanceof Integer)
		{
			int _x = x.intValue();

			if(y instanceof Integer)
			{
				int _y = ((Integer)y).intValue();
				long result = (long)_x + (long)_y;
				return longToNumber(result);
			}
			else if(y instanceof BigInteger)
			{
				return BigInteger.valueOf(_x)
					.add((BigInteger)y);
			}
		}
		else if(x instanceof FactorNumber)
			return ((FactorNumber)x).add(y);
		else if(x instanceof BigInteger)
		{
			BigInteger _x = (BigInteger)x;

			if(y instanceof Integer)
			{
				return _x.add(BigInteger.valueOf(
					((Integer)y).intValue()));
			}
			else if(y instanceof BigInteger)
				return _x.add((BigInteger)y);
		}

		return new Double(x.doubleValue() + y.doubleValue());
	} //}}}

	//{{{ and() method
	public static Number and(Number x, Number y)
	{
		if(x instanceof BigInteger)
		{
			if(y instanceof BigInteger)
				return ((BigInteger)x).and((BigInteger)y);
			else
			{
				return ((BigInteger)x).and(BigInteger.valueOf(
					y.longValue()));
			}
		}
		else
		{
			if(y instanceof BigInteger)
			{
				return ((BigInteger)y).and(BigInteger.valueOf(
					x.longValue()));
			}
			else
			{
				long and = x.longValue() & y.longValue();
				return longToNumber(and);
			}
		}
	} //}}}

	//{{{ or() method
	public static Number or(Number x, Number y)
	{
		if(x instanceof BigInteger)
		{
			if(y instanceof BigInteger)
				return ((BigInteger)x).or((BigInteger)y);
			else
			{
				return ((BigInteger)x).or(BigInteger.valueOf(
					y.longValue()));
			}
		}
		else
		{
			if(y instanceof BigInteger)
			{
				return ((BigInteger)y).or(BigInteger.valueOf(
					x.longValue()));
			}
			else
			{
				long or = x.longValue() | y.longValue();
				return longToNumber(or);
			}
		}
	} //}}}

	//{{{ xor() method
	public static Number xor(Number x, Number y)
	{
		if(x instanceof BigInteger)
		{
			if(y instanceof BigInteger)
				return ((BigInteger)x).xor((BigInteger)y);
			else
			{
				return ((BigInteger)x).xor(BigInteger.valueOf(
					y.longValue()));
			}
		}
		else
		{
			if(y instanceof BigInteger)
			{
				return ((BigInteger)y).xor(BigInteger.valueOf(
					x.longValue()));
			}
			else
			{
				long xor = x.longValue() ^ y.longValue();
				return longToNumber(xor);
			}
		}
	} //}}}

	//{{{ not() method
	public static Number not(Number x)
	{
		if(x instanceof BigInteger)
			return ((BigInteger)x).not();
		else
			return longToNumber(~x.longValue());
	} //}}}

	//{{{ shiftLeft() method
	public static Number shift(Number x, int by)
	{
		if(by < 0)
			return shiftRight(x,-by);
		else
			return shiftLeft(x,by);
	} //}}}

	//{{{ shiftLeft() method
	public static Number shiftLeft(Number x, int by)
	{
		if(x instanceof BigInteger)
			return ((BigInteger)x).shiftLeft(by);
		else if(x instanceof Integer)
		{
			int ix = x.intValue();
			if(by >= 32)
				return BigInteger.valueOf(ix).shiftLeft(by);
			else
				return longToNumber((long)ix << by);
		}
		else
			return BigInteger.valueOf(x.longValue()).shiftLeft(by);
	} //}}}

	//{{{ shiftRight() method
	public static Number shiftRight(Number x, int by)
	{
		if(x instanceof BigInteger)
			return ((BigInteger)x).shiftRight(by);
		else
			return longToNumber(x.longValue() >> by);
	} //}}}

	//{{{ _divide() method
	/**
	 * Truncating division.
	 */
	public static Number _divide(Number x, Number y)
	{
		if(x instanceof Integer)
		{
			int _x = x.intValue();

			if(y instanceof Integer)
			{
				int _y = y.intValue();
				return new Integer(_x / _y);
			}
			else if(y instanceof BigInteger)
			{
				return BigInteger.valueOf(_x)
					.divide((BigInteger)y);
			}
		}
		else if(x instanceof BigInteger)
		{
			BigInteger _x = (BigInteger)x;

			if(y instanceof Integer)
			{
				return _x.divide(BigInteger.valueOf(
					y.intValue()));
			}
			else if(y instanceof BigInteger)
				return _x.divide((BigInteger)y);
		}

		return new Double(x.doubleValue() / y.doubleValue());
	} //}}}

	//{{{ divide() method
	public static Number divide(Number x, Number y)
	{
		if(
			(x instanceof Integer
			|| x instanceof BigInteger)
			&&
			(y instanceof Integer
			|| y instanceof BigInteger))
		{
			return Ratio.valueOf(x,y);
		}
		else if(x instanceof FactorNumber)
			return ((FactorNumber)x).divide(y);
		else if(y instanceof FactorNumber)
			return ((FactorNumber)y)._divide(x);

		return new Double(x.doubleValue() / y.doubleValue());
	} //}}}

	//{{{ mod() method
	public static Number mod(Number x, Number y)
	{
		if(x instanceof BigInteger)
		{
			if(y instanceof BigInteger)
				return ((BigInteger)x).mod((BigInteger)y);
			else
			{
				return ((BigInteger)x).mod(
					BigInteger.valueOf(y.longValue()));
			}
		}
		else if(y instanceof BigInteger)
		{
			return BigInteger.valueOf(x.longValue())
				.mod((BigInteger)y);
		}
		else
			return new Integer(x.intValue()%y.intValue());
	} //}}}

	//{{{ longToNumber() method
	private static Number longToNumber(long x)
	{
		if(x < Integer.MIN_VALUE || x > Integer.MAX_VALUE)
			return BigInteger.valueOf(x);
		else
			return new Integer((int)x);
	} //}}}

	//{{{ gcd() method
	public static long gcd(long x, long y)
	{
		if(x < 0)
			x = -x;
		if(y < 0)
			y = -y;
		if(x > y)
		{
			long t = x;
			x = y;
			y = t;
		}

		for(;;)
		{
			if(x == 0)
				return y;

			long t = y % x;
			y = x;
			x = t;
		}
	} //}}}

	//{{{ gcd() method
	public static Number gcd(Number x, Number y)
	{
		if(x instanceof BigInteger)
		{
			BigInteger _x = (BigInteger)x;
			if(y instanceof BigInteger)
				return _x.gcd((BigInteger)y);
			else
			{
				return _x.gcd(BigInteger.valueOf(
					y.longValue()));
			}
		}
		else
		{
			long _x = x.longValue();
			if(y instanceof BigInteger)
			{
				return ((BigInteger)y).gcd(
					BigInteger.valueOf(_x));
			}
			else
				return longToNumber(gcd(_x,y.longValue()));
		}
	} //}}}

	//{{{ is0() method
	public static boolean is0(Number x)
	{
		if(x instanceof BigInteger)
			return x.equals(BigInteger.ZERO);
		else if(x instanceof Integer)
			return x.intValue() == 0;
		else
			return x.floatValue() == 0.0f;
	} //}}}

	//{{{ is1() method
	public static boolean is1(Number x)
	{
		if(x instanceof BigInteger)
			return x.equals(BigInteger.ONE);
		else if(x instanceof Integer)
			return x.intValue() == 1;
		else
			return x.floatValue() == 1.0f;
	} //}}}

	//{{{ compare() method
	/**
	 * -1: x < y
	 * 0: x = y
	 * 1: x > y
	 */
	public static int compare(Number x, Number y)
	{
		if(x instanceof Complex || y instanceof Complex)
			throw new ArithmeticException("Complex numbers are not comparable");

		if(x instanceof Ratio)
			return ((Ratio)x).compare(y);
		else if(y instanceof Ratio)
			return -((Ratio)y).compare(x);
		else if(x instanceof BigInteger)
		{
			if(y instanceof BigInteger)
			{
				return ((BigInteger)x).compareTo(
					(BigInteger)y);
			}
			else if(y instanceof Integer || y instanceof Long)
			{
				return ((BigInteger)x).compareTo(
					BigInteger.valueOf(y.longValue()));
			}
		}
		else if(y instanceof BigInteger)
		{
			if(x instanceof Integer || x instanceof Long)
			{
				return BigInteger.valueOf(x.longValue())
					.compareTo((BigInteger)y);
			}
		}
		else if(x instanceof Integer || x instanceof Long)
		{
			if(y instanceof Integer || y instanceof Long)
			{
				return sgn(x.longValue() - y.longValue());
			}
		}

		return sgn(x.doubleValue() - y.doubleValue());
	} //}}}

	//{{{ greater() method
	public static boolean greater(Number x, Number y)
	{
		return compare(x,y) > 0;
	} //}}}

	//{{{ greaterEqual() method
	public static boolean greaterEqual(Number x, Number y)
	{
		return compare(x,y) >= 0;
	} //}}}

	//{{{ less() method
	public static boolean less(Number x, Number y)
	{
		return compare(x,y) < 0;
	} //}}}

	//{{{ lessEqual() method
	public static boolean lessEqual(Number x, Number y)
	{
		return compare(x,y) <= 0;
	} //}}}

	//{{{ multiply() method
	public static Number multiply(Number x, Number y)
	{
		if(y instanceof FactorNumber)
			return ((FactorNumber)y).multiply(x);
		else if(x instanceof Integer)
		{
			int _x = x.intValue();

			if(y instanceof Integer)
			{
				int _y = y.intValue();
				long result = (long)_x * (long)_y;
				return longToNumber(result);
			}
			else if(y instanceof BigInteger)
			{
				return BigInteger.valueOf(_x)
					.multiply((BigInteger)y);
			}
		}
		else if(x instanceof FactorNumber)
			return ((FactorNumber)x).multiply(y);
		else if(x instanceof BigInteger)
		{
			BigInteger _x = (BigInteger)x;

			if(y instanceof Integer)
			{
				return _x.multiply(BigInteger.valueOf(
					y.intValue()));
			}
			else if(y instanceof BigInteger)
				return _x.multiply((BigInteger)y);
		}

		return new Double(x.doubleValue() * y.doubleValue());
	} //}}}

	//{{{ neg() method
	public static Number neg(Number x)
	{
		if(x instanceof Integer)
			return new Integer(-x.intValue());
		else if(x instanceof BigInteger)
			return ((BigInteger)x).negate();
		else if(x instanceof FactorNumber)
			return ((FactorNumber)x).neg();
		else if(x instanceof Float)
			return new Float(-x.floatValue());
		else
			return new Double(-x.doubleValue());
	} //}}}

	//{{{ randomAngle() method
	public static float randomAngle()
	{
		return (float)Math.PI * randomInt(0,360) / 180;
	} //}}}

	//{{{ randomBoolean() method
	public static boolean randomBoolean()
	{
		return random.nextBoolean();
	} //}}}

	//{{{ randomInt() method
	public static int randomInt(int min, int max)
	{
		if(min == max)
			return min;

		return min + random.nextInt(max - min + 1);
	} //}}}

	//{{{ randomFloat() method
	public static float randomFloat(int min, int max, float scale)
	{
		return randomInt(min,max) / scale;
	} //}}}

	//{{{ sgn() method
	public static int sgn(float num)
	{
		if(num < 0.0f)
			return -1;
		else if(num == 0.0f)
			return 0;
		else
			return 1;
	} //}}}

	//{{{ sgn() method
	public static int sgn(double num)
	{
		if(num < 0.0)
			return -1;
		else if(num == 0.0)
			return 0;
		else
			return 1;
	} //}}}

	//{{{ sgn() method
	public static int sgn(long num)
	{
		if(num < 0)
			return -1;
		else if(num == 0)
			return 0;
		else
			return 1;
	} //}}}

	//{{{ sgn() method
	public static int sgn(Number num)
	{
		if(num instanceof Ratio)
			return sgn(((Ratio)num).numerator);
		else if(num instanceof BigInteger)
			return ((BigInteger)num).signum();
		else if(num instanceof Integer || num instanceof Long)
			return sgn(num.longValue());
		else if(num instanceof Float)
			return sgn(num.floatValue());
		else //if(num instanceof Double)
			return sgn(num.doubleValue());
	} //}}}

	//{{{ subtract() method
	public static Number subtract(Number x, Number y)
	{
		if(y instanceof FactorNumber)
			return ((FactorNumber)y)._subtract(x);
		else if(x instanceof Integer)
		{
			int _x = x.intValue();

			if(y instanceof Integer)
			{
				int _y = y.intValue();
				long result = (long)_x - (long)_y;
				return longToNumber(result);
			}
			else if(y instanceof BigInteger)
			{
				return BigInteger.valueOf(_x)
					.subtract((BigInteger)y);
			}
		}
		else if(x instanceof FactorNumber)
			return ((FactorNumber)x).subtract(y);
		else if(x instanceof BigInteger)
		{
			BigInteger _x = (BigInteger)x;

			if(y instanceof Integer)
			{
				return _x.subtract(BigInteger.valueOf(
					((Integer)y).intValue()));
			}
			else if(y instanceof BigInteger)
				return _x.subtract((BigInteger)y);
		}

		return new Double(x.doubleValue() - y.doubleValue());
	} //}}}
}
