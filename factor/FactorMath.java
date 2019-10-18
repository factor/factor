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
		if(x instanceof FactorRatio)
			return ((FactorRatio)x).add(y);
		else if(y instanceof FactorRatio)
			return ((FactorRatio)y).add(x);
		else if(x instanceof Integer)
		{
			int _x = ((Integer)x).intValue();

			if(y instanceof Integer)
			{
				int _y = ((Integer)y).intValue();
				long result = (long)_x + (long)_y;
				if(result > Integer.MAX_VALUE
					|| result < Integer.MIN_VALUE)
				{
					return BigInteger.valueOf(result);
				}
				else
				{
					return new Integer((int)result);
				}
			}
			else if(y instanceof BigInteger)
			{
				return BigInteger.valueOf(_x)
					.add((BigInteger)y);
			}
		}
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

		return new Double(
			((Number)x).doubleValue()
			+ ((Number)y).doubleValue());
	} //}}}

	//{{{ _divide() method
	/**
	 * Truncating division.
	 */
	public static Number _divide(Number x, Number y)
	{
		if(x instanceof Integer)
		{
			int _x = ((Integer)x).intValue();

			if(y instanceof Integer)
			{
				int _y = ((Integer)y).intValue();
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
					((Integer)y).intValue()));
			}
			else if(y instanceof BigInteger)
				return _x.divide((BigInteger)y);
		}

		return new Double(
			((Number)x).doubleValue()
			/ ((Number)y).doubleValue());
	} //}}}

	//{{{ divide() method
	public static Number divide(Number x, Number y)
	{
		if(x instanceof FactorRatio)
			return ((FactorRatio)x).divide(y);
		else if(y instanceof FactorRatio)
			return ((FactorRatio)y)._divide(x);
		else if(
			(x instanceof Integer
			|| x instanceof BigInteger)
			&&
			(y instanceof Integer
			|| y instanceof BigInteger))
		{
			return FactorRatio.reduce(x,y);
		}

		return new Double(
			((Number)x).doubleValue()
			/ ((Number)y).doubleValue());
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
			BigInteger _x = BigInteger.valueOf(x.longValue());
			if(y instanceof BigInteger)
				return _x.gcd((BigInteger)y);
			else
			{
				return _x.gcd(BigInteger.valueOf(
					y.longValue()));
			}
		}
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

	//{{{ greater() method
	public static boolean greater(float x, float y)
	{
		return x > y;
	} //}}}

	//{{{ greaterEqual() method
	public static boolean greaterEqual(float x, float y)
	{
		return x >= y;
	} //}}}

	//{{{ less() method
	public static boolean less(float x, float y)
	{
		return x < y;
	} //}}}

	//{{{ lessEqual() method
	public static boolean lessEqual(float x, float y)
	{
		return x <= y;
	} //}}}

	//{{{ multiply() method
	public static Number multiply(Number x, Number y)
	{
		if(x instanceof FactorRatio)
			return ((FactorRatio)x).multiply(y);
		else if(y instanceof FactorRatio)
			return ((FactorRatio)y).multiply(x);
		else if(x instanceof Integer)
		{
			int _x = ((Integer)x).intValue();

			if(y instanceof Integer)
			{
				int _y = ((Integer)y).intValue();
				long result = (long)_x * (long)_y;
				if(result > Integer.MAX_VALUE
					|| result < Integer.MIN_VALUE)
				{
					return BigInteger.valueOf(result);
				}
				else
				{
					return new Integer((int)result);
				}
			}
			else if(y instanceof BigInteger)
			{
				return BigInteger.valueOf(_x)
					.multiply((BigInteger)y);
			}
		}
		else if(x instanceof BigInteger)
		{
			BigInteger _x = (BigInteger)x;

			if(y instanceof Integer)
			{
				return _x.multiply(BigInteger.valueOf(
					((Integer)y).intValue()));
			}
			else if(y instanceof BigInteger)
				return _x.multiply((BigInteger)y);
		}

		return new Double(
			((Number)x).doubleValue()
			* ((Number)y).doubleValue());
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

		int nextInt = random.nextInt();
		return min + Math.abs(nextInt % (max - min + 1));
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
	public static int sgn(Number num)
	{
		if(num instanceof FactorRatio)
			return sgn(((FactorRatio)num).numerator);
		else if(num instanceof BigInteger)
			return ((BigInteger)num).signum();
		else
		{
			double value = num.doubleValue();
			if(value < 0.0)
				return -1;
			else if(value == 0.0)
				return 0;
			else
				return 1;
		}
	} //}}}

	//{{{ subtract() method
	public static Number subtract(Number x, Number y)
	{
		if(x instanceof FactorRatio)
			return ((FactorRatio)x).subtract(y);
		else if(y instanceof FactorRatio)
			return ((FactorRatio)y)._subtract(x);
		else if(x instanceof Integer)
		{
			int _x = ((Integer)x).intValue();

			if(y instanceof Integer)
			{
				int _y = ((Integer)y).intValue();
				long result = (long)_x - (long)_y;
				if(result > Integer.MAX_VALUE
					|| result < Integer.MIN_VALUE)
				{
					return BigInteger.valueOf(result);
				}
				else
				{
					return new Integer((int)result);
				}
			}
			else if(y instanceof BigInteger)
			{
				return BigInteger.valueOf(_x)
					.subtract((BigInteger)y);
			}
		}
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

		return new Double(
			((Number)x).doubleValue()
			- ((Number)y).doubleValue());
	} //}}}
}
