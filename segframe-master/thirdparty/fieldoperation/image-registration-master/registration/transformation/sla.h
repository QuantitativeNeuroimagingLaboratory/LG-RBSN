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

// main header for SLA (small linear algebra)
//

#ifndef SLA_H
#define SLA_H

#include <iostream>

namespace sla {

// include operations and data structures suited to chosen architecture
#include "sla-seq.h" // most general

#if defined(__AVX__)
#elif defined(__SSE4_1__)
#include "sla-sse.h"
#endif

// vector 
template <typename T>
class Vector3 {
    template <typename U>
        friend class Matrix3;

    v3::Container<T> val;

    Vector3(v3::Container<T> _val) {
        val = _val;
    }

    public:

    Vector3() {
        val = v3::getContainer<T>(0.0,0.0,0.0);
    }

    Vector3(T x0, T x1, T x2) {
        val = v3::getContainer<T>(x0,x1,x2);
    }

    Vector3(T *_val) {
        val = v3::getContainer<T>(_val);
    }

    inline const T& operator[] (unsigned i) const {
        return v3::get(val,i);
    }

    inline void set(T s, unsigned i) {
        v3::set(val,s,i);
    }

    inline void store(T* p) {
        v3::store(val,p);
    }

    inline Vector3 operator+ (const Vector3 &v) const {
        Vector3 res(v3::add<T>(val,v.val));

        return res;
    }

    inline Vector3 operator- (const Vector3 &v) const {
        Vector3 res(v3::sub<T>(val,v.val));

        return res;
    }

    inline Vector3 operator* (const T s) const {
        Vector3 res(v3::scalarmul<T>(val,s));

        return res;
    }

    template <typename U>
        friend inline Vector3<U> operator* (const U s, const Vector3<U>& v);

    template <typename U>
        friend inline U dot(const Vector3<U>& v0, const Vector3<U>& v1);
    
    template <typename U>
        friend inline U sum(const Vector3<U>& v0);
    
    // zero vector
    static inline Vector3 zero() {
        return Vector3(0.0,0.0,0.0);
    }
    // jth component of standard basis
    static inline Vector3 e(unsigned j) {
        Vector3 res = zero();
        res.set(j-1,1.0);

        return res;
    }

    T* getArray() {
        return v3::GetArray<T>(val);
    }
};

template <typename T>
inline Vector3<T> operator* (const T s, const Vector3<T>& v) {
    Vector3<T> res(v3::scalarmul<T>(v.val,s));

    return res;
}

template <typename T>
inline T dot(const Vector3<T>& v0, const Vector3<T>& v1) {
    return v3::dot(v0.val,v1.val);
}

template <typename T>
inline T sum(const Vector3<T>& v0) {
    return v3::sum(v0.val);
}

template <typename T>
std::ostream& operator<< (std::ostream& lhs, Vector3<T>& v) {
    T* res = v.getArray();

    lhs << "(" << 
        res[0] << "," <<
        res[1] << "," <<
        res[2] << ")";

    return lhs;
}

// matrix 
template <typename S>
class Matrix3 {
    m3::Container<S> val;

    Matrix3(m3::Container<S> _val) {
        val = _val;
    }

    Matrix3(v3::Container<S> r0, v3::Container<S> r1, v3::Container<S> r2) {
        val = m3::getContainer<S>(r0,r1,r2);
    }

    public:

    Matrix3(Vector3<S> r0, Vector3<S> r1, Vector3<S> r2) {
        val = m3::getContainer<S>(r0.val,r1.val,r2.val);
    }

    Matrix3(S *_val) {
        val = m3::getContainer<S>(_val);
    }

    Matrix3() {
        Vector3<S> zero;
        val = m3::getContainer<S>(zero.val,zero.val,zero.val);
    }

    inline Vector3<S> operator[] (unsigned i) const {
        return m3::getRow<S>(val,i);
    }
    
    inline Vector3<S> row (const int i) const {
        return m3::getRow<S>(val,i);
    }

    inline void setRow (const int i, const Vector3<S> &v) {
        return m3::setRow<S>(val,i,v.val);
    }

    inline void addRow (const int i, const Vector3<S> &v) {
        return m3::addRow<S>(val,i,v.val);
    }

    inline Vector3<S> column (const int i) const {
        return m3::getColumn<S>(val,i);
    }

    inline void store(S* p) {
        m3::store<S>(val,p);
    }

    inline Matrix3 operator+ (const Matrix3 &v) const {
        Matrix3 res(m3::add<S>(val,v.val));

        return res;
    }

    inline Matrix3 operator- (const Matrix3 &v) const {
        Matrix3 res(m3::sub<S>(val,v.val));

        return res;
    }

    inline Matrix3 operator* (const S s) const {
        Matrix3 res(m3::scalarmul<S>(val,s));

        return res;
    }

    inline Vector3<S> operator* (const Vector3<S> v) const {
        Vector3<S> res(Vector3<S>(m3::vecmul<S>(val,v.val)));

        return res;
    }

    inline Matrix3<S> operator* (const Matrix3<S> m) const {
        Matrix3<S> res(Matrix3<S>(m3::mmul<S>(val,m.val)));

        return res;
    }

    // derterminant
    inline S det () const {
        S res = determinant(val);

        return res;
    }

    // matrix inverse
    inline Matrix3<S> inv () const {
        Matrix3<S> res(Matrix3<S>(m3::inverse<S>(val)));

        return res;
    }

    // matrix transpose
    inline Matrix3<S> T () const {
        Matrix3<S> res(column(0),column(1),column(2));

        return res;
    }

    template <typename U>
        friend inline Matrix3<U> operator* (const U s, const Matrix3<U>& v);

    template <typename U>
        friend inline U dot(const Matrix3<U> v0, const Matrix3<U> v1);

    // identity matrix
    static inline Matrix3<S> E() {
        Matrix3<S> res(Vector3<S>::e(1),Vector3<S>::e(2),Vector3<S>::e(3));

        return res;
    }

    //S* getArray() {
    //    return m3::GetArray<S>(val);
    //}
};

template <typename T>
inline Matrix3<T> operator* (const T s, const Matrix3<T>& v) {
    Matrix3<T> res(m3::scalarmul<T>(v.val,s));

    return res;
}

template <typename T>
std::ostream& operator<< (std::ostream& lhs, Matrix3<T>& v) {
    Vector3<T> v0 = v[0];
    Vector3<T> v1 = v[1];
    Vector3<T> v2 = v[2];

    lhs << "(" << 
        v0 << "|" <<
        v1 << "|" <<
        v2 << ")";

    return lhs;
}

}

#endif // SLA_H
