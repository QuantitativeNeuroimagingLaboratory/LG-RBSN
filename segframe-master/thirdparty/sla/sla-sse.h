/*
 *
 * This file is part of sla.
 *
 * Copyright (C) 2012, Stefan Sommer (sommer@diku.dk)
 * https://github.com/nefan/sla.git
 *
 * sla is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * sla is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with sla.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// small linear algebra with sse vector operations
//

#ifndef SLA_SSE_H
#define SLA_SSE_H

namespace v3 { // vector 3 namespace

typedef float v4sf __attribute__ ((vector_size (16))); // 4 vector

template <>
union Container<float>
{
    v4sf simd;
    float v[4];
};

template <>
inline Container<float> add(const Container<float> v0, const Container<float> v1) {
    Container<float> res;
    res.simd = v0.simd+v1.simd;

    return res;
}

template <>
inline Container<float> sub(const Container<float> v0, const Container<float> v1) {
    Container<float> res;
    res.simd = v0.simd-v1.simd;

    return res;
}

#include <smmintrin.h>
template <>
inline float dot(const Container<float> v0, const Container<float> v1) {
    float dot;
    __m128 res;
    //na=_mm_loadu_ps(v0.v);
    //nb=_mm_loadu_ps(v1.v);
    res=_mm_dp_ps(v0.simd,v1.simd,0x7f);
    _mm_store_ss(&dot,res);
    return dot;
}

} // namespace v3

#endif // SLA_SSE_H
