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
#include <omp.h>
typedef float v4sf __attribute__ ((vector_size (16))); // 4 vector
typedef float v4df __attribute__ ((vector_size (64))); // 4 vector

union f4vector
{
    v4sf v;
    float f[4];
};
union d4vector
{
    v4df v;
    double f[4];
};

#define SIMD
//#undef SIMD
#ifdef SIMD
#define v4add(res,v1,v2) res.v = v1.v + v2.v;
#else
#define v4add(res,v1,v2) { res.f[0] = v1.f[0] + v2.f[0]; res.f[1] = v1.f[1] + v2.f[1]; res.f[2] = v1.f[2] + v2.f[2]; res.f[3] = v1.f[3] + v2.f[3]; }
#endif

int main(int argc, char *argv[]) {
    union f4vector fa, fb, fc;

    if (argc != 2) {
        printf("usage: test1 N\n");
        exit(1);
    }

    int N = atoi(argv[1]);
    printf("running with N=%d\n",N);

    fa.f[0] = 1; fa.f[1] = 2; fa.f[2] = 3; fa.f[3] = 4; 
    fb.f[0] = 5; fb.f[1] = 6; fb.f[2] = 7; fb.f[3] = 8;
 
    fc.v = fa.v;
    //fc.f[0] = fa.f[0]; fc.f[1] = fa.f[1]; fc.f[2] = fa.f[2]; fc.f[3] = fa.f[3];
    double ft0 = omp_get_wtime();
    for (int i=0; i<N; i++)
        v4add(fc,fb,fc); // NOTE: 'overflow' will probably occur
        //fc.f[0] = fb.f[0] + fc.f[0];
    //fc.f[0] = fa.f[0]+N*fb.f[0];
    double ft1 = omp_get_wtime();
    double ftdelta = ft1-ft0;

    printf("%f, %f, %f, %f (%e s./iteration)\n", fc.f[0], fc.f[1], fc.f[2], fc.f[3], ftdelta/N);

    union d4vector da, db, dc;

    da.f[0] = 1; da.f[1] = 2; da.f[2] = 3; da.f[3] = 4; 
    db.f[0] = 5; db.f[1] = 6; db.f[2] = 7; db.f[3] = 8;

    dc.v = da.v;
    //dc.f[0] = da.f[0]; dc.f[1] = da.f[1]; dc.f[2] = da.f[2]; dc.f[3] = da.f[3];
    double dt0 = omp_get_wtime();
    for (int i=0; i<N; i++)
        v4add(dc,db,dc);
        //dc.f[0] = db.f[0] + dc.f[0];
    //dc.f[0] = da.f[0]+N*db.f[0];
    double dt1 = omp_get_wtime();
    double dtdelta = dt1-dt0;

    printf("%f, %f, %f, %f (%e s./iteration)\n", dc.f[0], dc.f[1], dc.f[2], dc.f[3], dtdelta/N);
}
