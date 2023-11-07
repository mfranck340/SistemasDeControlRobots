distancia = 1;

%% Rellenamos los campos del mensaje
%% Velocidad lineal
msg_vel.Linear.X=0.2;
msg_vel.Linear.Y=0;
msg_vel.Linear.Z=0;

%% Velocidad angular
msg_vel.Angular.X=0;
msg_vel.Angular.Y=0;
msg_vel.Angular.Z=0;

%% Forma de acceder al campo de posicion
%% Leemos la primera posicion
initpos = sub_odom.LatestMessage.Pose.Pose.Position;

while (1)
    %% Obtenemos la posicion actual
    pos = sub_odom.LatestMessage.Pose.Pose.Position;
    disp(fprintf('Posicion actual: (%f,%f,%f)',pos.X,pos.Y,pos.Z));

    %% Calculamos la distancia recorrida
    dist = sqrt((initpos.X-pos.X)^2 + (initpos.Y-pos.Y)^2);
    disp(fprintf('Distancia recorrida: %f',dist));

    if (dist > distancia)
        msg_vel.Linear.X=0;
        send(pub_vel, msg_vel);
        break;
    else
        send(pub_vel, msg_vel)
    end

    leer_sensores;

    %% vfh_controller
    %% Temporización del bucle
    waitfor(r);
end
