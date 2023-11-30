%Crear figuras distintas para el láser y el visualizador del VFH
% NOTA: para dibujar sobre una figura concreta, antes de llamar a la
% correspondiente función de dibujo debe convertirse en la figura activa
% utilizando figure(fig_laser) o figure(fig_vfh) respectivamente.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
fig_laser = figure; title('LASER')
fig_vfh = figure; title('VFH')

%Crear el objeto VFH…
%%%%%%%%%%%%%%%%%%%%%%
VFH = controllerVFH;

%y ajustamos sus propiedades
%%%%%%%%%%%%%%%%%%%%%%%%%%
VFH.NumAngularSectors;
VFH.DistanceLimits;
VFH.RobotRadius = 0.15;
VFH.SafetyDistance;
VFH.MinTurningRadius;
VFH.TargetDirectionWeight;
VFH.CurrentDirectionWeight;
VFH.PreviousDirectionWeight;
VFH.HistogramThresholds;
VFH.UseLidarScan = true; %para permitir utilizar la notación del scan

%Rellenamos los campos por defecto de la velocidad del robot, para que la lineal
%sea siempre 0.1 m/s
msg_vel.Linear.X = 0.1;
msg_vel.Linear.Y = 0;
msg_vel.Linear.Z = 0;
msg_vel.Angular.X = 0;
msg_vel.Angular.Y = 0;
msg_vel.Angular.Z = 0;

%Bucle de control infinito
while(1)
  %Leer y dibujar los datos del láser en la figura ‘fig_laser’   
  scan = receive(laserSub);
  figure(fig_laser);
  plot(scan);

  %Llamar al objeto VFH para obtener la dirección a seguir por el robot para
  %evitar los obstáculos. Mostrar los resultados del algoritmo (histogramas)
  %en la figura ‘fig_vfh’
  targetDir = 0;
  steeringDir = VFH(scan, targetDir);
  figure(fig_vfh);
  plot(VFH);

  %Rellenar el campo de la velocidad angular del mensaje de velocidad con un
  %valor proporcional a la dirección anterior (K=0.1)
  K = 0.1;
  V_ang = K * steeringDir;

  %Publicar el mensaje de velocidad
  msg_vel.Angular.Z = V_ang;
  send(pub_vel, msg_vel);

  %Esperar al siguiente periodo de muestreo
  leer_sensores;
  waitfor(r);
end



