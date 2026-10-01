%% SISTEMA SIN REALIMENTACION
C=40*40;
Hp=18.7;
Qp=7;
R=Hp/(Qp*1000/60);
Qi=322;
num=[0 R];
den=[R*C 1];
P=tf(num,den)
figure(1),step(Qi*P)
%% REQUERIMIENTOS
Mp=0.001, ts=10*60;
%% SISTEMA REALIMENTADO SERVOSISTEMA
Aa=[-1/(R*C) 0;-1 0], Ba=[1/C;0], Ca=[1 0], Da=[0], Ea=[0;1]
Co=ctrb(Aa,Ba);
Z=sqrt(log(Mp)^2/(log(Mp)^2+pi^2));
Wn=4/(ts*Z);
polos=roots([1 2*Wn*Z Wn^2]);
Ka=acker(Aa,Ba,polos)
sys_cl = ss(Aa-Ba*Ka,Ea,Ca,Da);
figure(2),step(30*sys_cl),title('Sistema Continuo'),grid,ylabel('altura (cm)')

%% CONTROL POR REALIMENTACION DE ESTADOS
%% CONTINUO
Aa1=[-1/(R*C)], Ba1=[1/C], Ca1=[1], Da1=[0]
Co1=ctrb(Aa1,Ba1);
polos1=roots([1 4/ts])
Ka1=acker(Aa1,Ba1,polos1),K=1*inv(ctrb(Aa1,Ba1))*(Aa1+4/ts)
syms s
fun_t=eval(simplify(Ca1*inv(eye(1)*s-(Aa1-Ba1*Ka1))*Ba1 + Da1));
N=eval(1/subs(fun_t,s,0))
sys_cl1 = ss(Aa1-Ba1*Ka1,N*Ba1,Ca1,Da1);
figure(3),step(30*sys_cl1),title('Sistema Continuo'),grid,ylabel('altura (cm)')

[Nuc,Dec]=ss2tf(Aa1-Ba1*Ka1,N*Ba1,Ca1,Da1);Fs=tf(Nuc,Dec)
%% DISCRETO
T=C*R/10;
syms t
OP1=ilaplace(inv(s-Aa1));
Ac=eval(subs(OP1,t,T));
Bc=eval(int(OP1,0,T))*Ba1;
Cc=Ca1, Dc=Da1;
polos2=roots([1 -exp(-T/(ts/4))])
Kc=acker(Ac,Bc,polos2)
syms z
fun_k=eval(simplify(Cc*inv(eye(1)*z-(Ac-Bc*Kc))*Bc + Dc));
Nk=eval(1/subs(fun_k,z,1))
sys_cld = ss(Ac-Bc*Kc,Nk*Bc,Cc,Dc,T);
figure(4),step(30*sys_cld),title('Sistema Discreto'),grid,ylabel('altura (cm)')

[Nu,De]=ss2tf(Ac-Bc*Kc,Nk*Bc,Cc,Dc);Fs=tf(Nu,De,T)
%% COMPARACION
figure(5)
subplot(2,2,1),step(30*sys_cl1), title('Continua'),grid,ylabel('altura (cm)')
subplot(2,2,2),step(30*sys_cld),title('Discreta'),grid,ylabel('altura (cm)')
subplot(2,2,[3 4]),step(30*sys_cld,30*sys_cl1), title('Comparacion'),grid,ylabel('altura (cm)')