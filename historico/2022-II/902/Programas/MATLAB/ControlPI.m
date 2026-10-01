%ETN 902 - SISTEMA DE NIVEL DE LIOUIDO
clc
clear 
% close all

st = {'PI SIN SATURACION','PI CON SATURACION',...
    'PI CON ANTI WIND UP'};
m = menu('Anti Windup',st);
%% Planta
K = 0.167;
tau = 118.75;
G = tf(K,[tau 1]);

%% Control PI
Kp = 5.69;
ti = 20.83;
td=0;
Ts=118.75/10;
C=tf([Kp*ti 1],[ti 0]);

% Calculo do controle PID digital
q0=Kp*(1+Ts/(2*ti)+td/Ts);
q1=-Kp*(1-Ts/(2*ti)+(2*td)/Ts);
q2=(Kp*td)/Ts;

%% Limites máximos y minimos
umax = 40;
umin = 0;

%% loop de control
nit = round(1000/Ts);
y(1:nit)=0;
u=y;
ug=u;
deltaU=u;
r=y;
e=y;
Ie=e;
%REFERENCIA DE NIVEL
r(round(50/Ts):end)=5;
 for k=3:nit
     %Respuesta del proceso
      t = 0:Ts:(k-1)*Ts;
      y=lsim(G,ug(1:k),t)';
      
      %Error
      e(k)=r(k)-y(k);
      
      %Parte Integral del Controlador
      Ie(k) = u(k-1) + q1*e(k-1);
      
      %PID
     u(k) = u(k-1) + q0*e(k) + q1*e(k-1) + q2*e(k-2); 
     %Anti-Windup
     if m>2
         if (u(k) >= umax)     
            u(k) = umax;
         elseif (u(k) <= umin)
             u(k) = umin;
         end
     end
     
     %PID ley de control incremental

    
     ug=u;
     
     %Saturación del elemento final de control
     if m>1
        ug(ug>umax)=umax;
     end
 end
 H = feedback(C*G,1);
 Hu = feedback(C,G);
 y2=lsim(H,r,t)';
 u2=lsim(Hu,r,t)';

    
 figure
 subplot(311)
 stairs(t,r,'r')
 hold on
 stairs(t,y,'k')
 hold on
 stairs(t,y2,'b')
 hold on
 
grid,
 
 title(st{m})
 ylabel('Salida')
 subplot(312)
 stairs(t,ug,'g')

 grid,
 ylabel('Control')
 subplot(313)
 stairs(t,Ie,'r')
 grid,
 ylabel('Integral del error')
