
b = 4;
r = linspace(0,10,100);
M = exp(-((r).^2)/b^2);

figure,plot(r,M)

a = 10.5;
r(find(r>a)) = a;
cp = (1-r/a).^4.*(4*r/a+1);

hold on
plot(r,cp,'--r')