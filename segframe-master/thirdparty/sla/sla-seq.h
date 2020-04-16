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

// small linear algebra without vector optimizations
//

#ifndef SLA_SEQ_H
#define SLA_SEQ_H

#include <assert.h>

namespace v3 { // vector 3 namespace

template <typename T>
union  Container {
    T v[3];
};

template <typename T>
inline const T& get(const Container<T> &c, unsigned i) {
    return c.v[i];
}

template <typename T>
inline void set(Container<T> &c, const Container<T> &v) {
    c.v[0] = v.v[0];
    c.v[1] = v.v[1];
    c.v[2] = v.v[2];
}

template <typename T>
inline void set(Container<T> &c, T s, unsigned i) {
    c.v[i] = s;
}

template <typename T>
inline void store(Container<T> &c, T* p) {
    p[0] = c.v[0];
    p[1] = c.v[1];
    p[2] = c.v[2];
}

template <typename T>
inline Container<T> add(const Container<T> v0, const Container<T> v1) {
    Container<T> res;
    res.v[0] = v0.v[0]+v1.v[0];
    res.v[1] = v0.v[1]+v1.v[1];
    res.v[2] = v0.v[2]+v1.v[2];

    return res;
}

template <typename T>
inline void addTo(Container<T>& v0, const Container<T> v1) {
    Container<T> res;
    v0.v[0] = v0.v[0]+v1.v[0];
    v0.v[1] = v0.v[1]+v1.v[1];
    v0.v[2] = v0.v[2]+v1.v[2];
}

template <typename T>
inline Container<T> sub(const Container<T> v0, const Container<T> v1) {
    Container<T> res;
    res.v[0] = v0.v[0]-v1.v[0];
    res.v[1] = v0.v[1]-v1.v[1];
    res.v[2] = v0.v[2]-v1.v[2];

    return res;
}

template <typename T>
inline Container<T> scalarmul(const Container<T> v0, T s) {
    Container<T> res;
    res.v[0] = s*v0.v[0];
    res.v[1] = s*v0.v[1];
    res.v[2] = s*v0.v[2];

    return res;
}

template <typename T>
inline T dot(const Container<T> v0, const Container<T> v1) {
    return v0.v[0]*v1.v[0]+v0.v[1]*v1.v[1]+v0.v[2]*v1.v[2];
}

template <typename T>
inline T sum(const Container<T> v0) {
    return v0.v[0]+v0.v[1]+v0.v[2];
}

template <typename T>
inline Container<T> getContainer(T x0, T x1, T x2) {
    Container<T> res;
    res.v[0] = x0;
    res.v[1] = x1;
    res.v[2] = x2;

    return res;
}

template <typename T>
inline Container<T> getContainer(T *val) {
    Container<T> res;
    res.v[0] = val[0];
    res.v[1] = val[1];
    res.v[2] = val[2];

    return res;
}

template <typename T>
inline T* GetArray(Container<T> &val) {
    return val.v;
}

} // namespace v3


namespace m3 { // matrix 3 namespace

template <typename T>
union  Container {
    v3::Container<T> v[3]; // row major
};

// get row i, column j
template <typename T>
inline const T get(const Container<T> &m, unsigned i, unsigned j) {
    return v3::get<T>(m.v[i],j);
}

template <typename T>
inline const v3::Container<T> getRow(const Container<T> &m, unsigned i) {
    return m.v[i];
}

template <typename T>
inline void setRow(Container<T> &m, unsigned i, const v3::Container<T> &v) {
    v3::set<scalar>(m.v[i],v);
}

template <typename T>
inline void addRow(Container<T> &m, unsigned i, const v3::Container<T> &v) {
    v3::addTo<scalar>(m.v[i],v);
}


template <typename T>
inline const v3::Container<T> getColumn(const Container<T> &m, unsigned i) {
    return v3::getContainer<T>(get(m.v[0],i),get(m.v[1],i),get(m.v[2],i));
}

template <typename T>
inline void store(Container<T> &c, T* p) {
    v3::store<scalar>(c.v[0],p+3*0);
    v3::store<scalar>(c.v[1],p+3*1);
    v3::store<scalar>(c.v[2],p+3*2);
}

template <typename T>
inline Container<T> add(const Container<T> m0, const Container<T> m1) {
    Container<T> res;
    // row 0
    res.v[0] = v3::add(m0.v[0],m1.v[0]);
    // row 1
    res.v[1] = v3::add(m0.v[1],m1.v[1]);
    // row 2
    res.v[2] = v3::add(m0.v[2],m1.v[2]);

    return res;
}

template <typename T>
inline Container<T> sub(const Container<T> m0, const Container<T> m1) {
    Container<T> res;
    // row 0
    res.v[0] = v3::sub(m0.v[0],m1.v[0]);
    // row 1
    res.v[1] = v3::sub(m0.v[1],m1.v[1]);
    // row 2
    res.v[2] = v3::sub(m0.v[2],m1.v[2]);

    return res;
}

template <typename T>
inline Container<T> scalarmul(const Container<T> m, T s) {
    Container<T> res;
    // row 0
    res.v[0] = v3::scalarmul<T>(m.v[0],s);
    // row 1
    res.v[1] = v3::scalarmul<T>(m.v[1],s);
    // row 2
    res.v[2] = v3::scalarmul<T>(m.v[2],s);

    return res;
}

template <typename T>
inline v3::Container<T> vecmul(const Container<T> m, v3::Container<T> v) {
    v3::Container<T> res = v3::getContainer(
            v3::dot<T>(m.v[0],v),
            v3::dot<T>(m.v[1],v),
            v3::dot<T>(m.v[2],v)
            );

    return res;
}

template <typename T>
inline T determinant(const Container<T> m) {
    T res = get(m,0,0)*get(m,1,1)*get(m,2,2)
        + get<T>(m,0,1)*get<T>(m,1,2)*get<T>(m,2,0)
        + get<T>(m,0,2)*get<T>(m,1,0)*get<T>(m,2,1)
        - get<T>(m,0,0)*get<T>(m,1,2)*get<T>(m,2,1)
        - get<T>(m,0,1)*get<T>(m,1,0)*get<T>(m,2,2)
        - get<T>(m,0,2)*get<T>(m,1,1)*get<T>(m,2,0);

    return res;
}

template <typename T>
inline Container<T> getContainer(v3::Container<T> r0, v3::Container<T> r1, v3::Container<T> r2) {
    Container<T> res;
    // row 0
    res.v[0] = r0;
    // row 1
    res.v[1] = r1;
    // row 2
    res.v[2] = r2;

    return res;
}

template <typename T>
inline m3::Container<T> mmul(const Container<T> m, m3::Container<T> m2) {
    m3::Container<T> res = m3::getContainer(
            v3::getContainer(v3::dot<T>(m.v[0],getColumn<T>(m2,0)),v3::dot<T>(m.v[0],getColumn<T>(m2,1)),v3::dot<T>(m.v[0],getColumn<T>(m2,2))),
            v3::getContainer(v3::dot<T>(m.v[1],getColumn<T>(m2,0)),v3::dot<T>(m.v[1],getColumn<T>(m2,1)),v3::dot<T>(m.v[1],getColumn<T>(m2,2))),
            v3::getContainer(v3::dot<T>(m.v[2],getColumn<T>(m2,0)),v3::dot<T>(m.v[2],getColumn<T>(m2,1)),v3::dot<T>(m.v[2],getColumn<T>(m2,2))));

    return res;
}

template <typename T>
inline m3::Container<T> inverse(const Container<T> m) {
    T r = 1.0/determinant<T>(m);
    m3::Container<T> res = m3::getContainer(
            v3::getContainer(
                r*(get<T>(m,1,1)*get<T>(m,2,2)-get<T>(m,2,1)*get<T>(m,1,2)),
                r*(get<T>(m,2,1)*get<T>(m,0,2)-get<T>(m,0,1)*get<T>(m,2,2)),
                r*(get<T>(m,0,1)*get<T>(m,1,2)-get<T>(m,1,1)*get<T>(m,0,2))),
            v3::getContainer(
                r*(get<T>(m,2,0)*get<T>(m,1,2)-get<T>(m,1,0)*get<T>(m,2,2)),
                r*(get<T>(m,0,0)*get<T>(m,2,2)-get<T>(m,2,0)*get<T>(m,0,2)),
                r*(get<T>(m,1,0)*get<T>(m,0,2)-get<T>(m,0,0)*get<T>(m,1,2))),
            v3::getContainer(
                r*(get<T>(m,1,0)*get<T>(m,2,1)-get<T>(m,2,0)*get<T>(m,1,1)),
                r*(get<T>(m,2,0)*get<T>(m,0,1)-get<T>(m,0,0)*get<T>(m,2,1)),
                r*(get<T>(m,0,0)*get<T>(m,1,1)-get<T>(m,1,0)*get<T>(m,1,0))));

    return res;
}

template <typename T>
inline Container<T> getContainer(T *val) {
    Container<T> res;
    // row 0
    res.v[0][0] = val[0][0];
    res.v[0][1] = val[0][1];
    res.v[0][2] = val[0][2];
    // row 1
    res.v[1][0] = val[1][0];
    res.v[1][1] = val[1][1];
    res.v[1][2] = val[1][2];
    // row 2
    res.v[2][0] = val[2][0];
    res.v[2][1] = val[2][1];
    res.v[2][2] = val[2][2];

    return res;
}

//template <typename T>
//inline T* GetArray(Container<T> &val) {
//    return val.v;
//}

} // namespace m3

#endif // SLA_SEQ_H
