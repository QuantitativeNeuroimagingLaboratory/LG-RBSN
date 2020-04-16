# 
#  This file is part of sla.
# 
#  Copyright (C) 2012, Stefan Sommer (sommer@diku.dk)
#  https://github.com/nefan/sla.git
# 
#  sla is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  sla is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with sla.  If not, see <http://www.gnu.org/licenses/>.
# 

#-----------------------------------------------------------------------------
# Make rules:
#-----------------------------------------------------------------------------
all: test1

test1:
	gcc -mavx -O3 -c test1.c -std=c99 -fopenmp && gcc -mavx -O3 -S -fverbose-asm test1.c -std=c99 -fopenmp && gcc -lgomp -fopenmp -o test1 test1.o

run:
	./test1 1000000

clean:
	rm test1
