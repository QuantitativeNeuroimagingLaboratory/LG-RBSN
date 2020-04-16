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

#include <stdio.h>
#include <stdlib.h>
#include <iostream>

//#undef __SSE__
#include "sla.h"
using namespace sla;

typedef float scalar;
//typedef double scalar;
//


scalar matrixVector(const Matrix3<scalar>& m, const Vector3<scalar>& v1, const Vector3<scalar>& v2, int N) {
    return dot<scalar>(m[0],v2);
}

int main(int argc, char *argv[]) {

    if (argc != 2) {
        printf("usage: test1 N\n");
        exit(1);
    }

    int N = atoi(argv[1]);

    Vector3<scalar> a(7.5,1,2);
    Vector3<scalar> b(1,2,3);

    Vector3<scalar> c = a;
    for (int i =0; i<N; i++)
        c = c+b;

    matrixVector(Matrix3<scalar>::E(),a,b,N);

    Vector3<scalar> d = a-b;
    Vector3<scalar> e = 4.f*a;
    Vector3<scalar> f = a*5.f;

    std::cout << c << "," << d << "," << e << "," << f << std::endl;
    std::cout << dot<scalar>(a,b) << "," << a[1] << std::endl;

    std::cout << " ----------------- " << std::endl;

    std::cout << a << "," << b << "," << c << std::endl;
    Matrix3<scalar> m1(a,b,c);
    std::cout << m1 << std::endl;

    Matrix3<scalar> m2 = 2.f*m1;
    Matrix3<scalar> m3 = m2+m1;
    Matrix3<scalar> m4 = m2-m1;
    std::cout << m2 << std::endl;
    std::cout << m3 << std::endl;
    std::cout << m4 << std::endl;

    Vector3<scalar> v1 = m2*a;
    std::cout << v1 << std::endl;

    Vector3<scalar> e2 = Vector3<scalar>::e(2);
    std::cout << e2 << std::endl;

    Matrix3<scalar> E = Matrix3<scalar>::E();
    std::cout << E << std::endl;
    Vector3<scalar> v2 = E*v1;
    std::cout << v2 << std::endl;

    std::cout << " ----------------- " << std::endl;

    Matrix3<scalar> m5(a,b,Vector3<scalar>(-1.0,2.0,1.0));
    std::cout << m5 << std::endl;
    Matrix3<scalar> m5T = m5.T();
    std::cout << "transpose: " << m5T << std::endl;
    Matrix3<scalar> m5inv = m5.inv();
    Matrix3<scalar> product1 = m5*m5inv;
    Matrix3<scalar> product2 = m5inv*m5;
    scalar det1 = m5.det();
    scalar det2 = m5inv.det();
    std::cout << "inverse: " << m5inv << std::endl;
    std::cout << "product1: " << product1 << std::endl;
    std::cout << "product2: " << product2 << std::endl;
    std::cout << "determinants: " << det1 << " , " << det2 << " , " << det1*det2 << std::endl;

    std::cout << " ----------------- " << std::endl;

    Matrix3<scalar> m6(
            Vector3<scalar>(1.0,2.0,3.0),
            Vector3<scalar>(4.0,5.0,6.0),
            Vector3<scalar>(7.0,8.0,9.0));
    Matrix3<scalar> m7 = m6*m6.T();
    std::cout << m7 << std::endl;

    return 0;
}
