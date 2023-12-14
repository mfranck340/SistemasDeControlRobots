%Crear el objeto PurePursuit y ajustar sus propiedades
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controller=controllerPurePursuit;
controller.LookaheadDistance = 0.1;
controller.DesiredLinearVelocity= 3; 
controller.MaxAngularVelocity = 0.5;
%Rellenamos los campos por defecto de la velocidad del robot, para que la lineal
%sea siempre 0.1 m/s
%Bucle de control infinito




%%%%%%%%%%% COMIENZA EL BUCLE DE CONTROL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Indicamos al controlador la lista de waypoints a recorrer (ruta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controller.Waypoints = ruta;
%Bucle de control
%%%%%%%%%%%%%%%%%
umbral_dist = 0.1;

while(1)
    %Leer el láser y la odometría
    figure(fig_laser);
    leer_sensores;
    scan = msg_laser.lidarScan;

    %Obtener la posición pose=[x,y,yaw] a partir de la odometría anterior
    odomQuat = [msg_odom.Pose.Pose.Orientation.W msg_odom.Pose.Pose.Orientation.X ...
        msg_odom.Pose.Pose.Orientation.Y msg_odom.Pose.Pose.Orientation.Z];
    odomRotation = quat2eul(odomQuat);
    pose = [msg_odom.Pose.Pose.Position.X msg_odom.Pose.Pose.Position.Y odomRotation(1)];

    %Ejecutar amcl para obtener la posición estimada estimatedPose
    [isUpdated, estimatedPose, estimatedCovariance] = amcl(pose,scan);

    %Dibujar los resultados del localizador con el visualizationHelper

    %Ejecutar el controlador PurePursuit para obtener las velocidades lineal
    %y angular
    [lin_vel,ang_vel] = CONTROLLER(estimatedPose);

    %Rellenar los campos del mensaje de velocidad
    msg_vel.Linear.X = lin_vel;
    msg_vel.Angular.Z = ang_vel;

    %Publicar el mensaje de velocidad
    send(pub_vel,msg_vel);
    
    %Comprobar si hemos llegado al destino, calculando la distancia euclidea
    %y estableciendo un umbral
    dist = sqrt((estimatedPose(1)-ruta(end,1))^2 + (estimatedPose(2)-ruta(end,2))^2); 

    if (dist < umbral_dist)
        %Parar el robot
        break;
    end

    %Esperar al siguiente periodo de muestreo
    waitfor(r);
end


