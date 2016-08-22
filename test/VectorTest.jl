using ApproxFun,Base.Test

import ApproxFun:interlace,Multiplication,ConstantSpace,TupleSpace,PointSpace


d=Interval()
D=Derivative(d);
B=ldirichlet();
Bn=lneumann();
A=[B 0;
   0 B;
   D-I 2I;
   0I D+I];

f=Fun(x->[exp(x),cos(x)],d)


b=Any[0.,0.,f...]
f1,f2=vec(f)
u=A\b
u1=vec(u)[1];u2=vec(u)[2];

@test norm(u1'-u1+2u2-f1)<10eps()
@test norm(u2'+u2-f2)<10eps()

Ai=Operator(A)
u=Ai\b
u1=vec(u)[1];u2=vec(u)[2];

@test norm(u1'-u1+2u2-f1)<10eps()
@test norm(u2'+u2-f2)<10eps()





A=[B 0;
   Bn 0;
   0 B;
   D^2-I 2I;
   0 D+I];


b=Any[0.,0.,0.,f...]


u=A\b
u1=vec(u)[1];u2=vec(u)[2];


@test norm(differentiate(u1,2)-u1+2u2-f1)<2eps()
@test norm(u2'+u2-f2)<2eps()

Ai=Operator(A)
u=Ai\b
u1=vec(u)[1];u2=vec(u)[2];


@test norm(u1''-u1+2u2-f1)<2eps()
@test norm(u2'+u2-f2)<2eps()






## Matrix exponential

n=4
d=fill(Interval(0.,1.),n)
B=Evaluation(d,0.)
D=Derivative(d)
A=rand(n,n)
L=[B;D-A]
u=L\eye(n)
@test norm(evaluate(u,1.)-expm(A))<eps(1000.)


n=4
d=fill(Interval(0.,1.),n)
B=Evaluation(d,0.)
D=Derivative(d)
A=rand(n,n)
L=[B;D-A]
u=L\eye(2)
@test norm(evaluate(u,1.)-expm(A)[:,1:2])<eps(1000.)




## Multiplication

d = Interval()
t=Fun(identity,d)
f = devec([t^2, sin(t)])
@test norm(((Derivative(space(f))*f)-Fun(t->[2t,cos(t)])).coefficients)<100eps()
@test norm((([1 2;3 4]*f)-Fun(t->[t^2+2sin(t),3t^2+4sin(t)])).coefficients)<100eps()



## Multiplication operator

Γ=Circle()∪Circle(0.5)
G=Fun(z->in(z,Γ[2])?[1 -z^(-1); 0 1]:
                   [z 0; 0 z^(-1)],Γ);
G1=demat(mat(G)[:,1])
M=Multiplication(G,space(G1))
u=M*G1
@test norm(u(exp(.1im))-[exp(.2im),0])<100eps()
@test norm(u(.5exp(.1im))-[1,0])<100eps()

# Vector operations
@test_approx_eq (Fun(x->[1., 2.]) + [2, 2])(0.) [3., 4.]




## Check conversion

f=Fun(t->[cos(t) 0;sin(t) 1],[-π,π])
g=Fun(f,Space(PeriodicInterval(-π,π)))
@test_approx_eq g(.1) f(.1)



## Interlace test
S1=Chebyshev()^2
S2=Chebyshev()
TS=TupleSpace((ConstantSpace(),S1,ConstantSpace(),S2,PointSpace([1.,2.])))
f=Fun(collect(1:10),TS)
@test f[1] == Fun([1.],TS[1])
@test f[2] == Fun([2.,6.,7.,10.],TS[2])
@test f[3] == Fun([3.],TS[3])
@test f[4] == Fun([4.,8.],TS[4])
@test f[5] == Fun([5.,9.],TS[5])
