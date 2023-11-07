angulo = -pi/2;

if (angulo > 0) velocidad=0.1;
else velocidad=-0.1;
end

% Rellenamos el mensaje
msg_vel.Linear.X = 0;
msg_vel.Linear.Y = 0;
msg_vel.Linear.Z = 0;

% Velocidades angulares
msg_vel.Angular.X = 0;
msg_vel.Angular.Y = 0;
msg_vel.Angular.Z = velocidad;

% Leemos la primera posicion
initori = sub_odom.LatestMessage.Pose.Pose.Orientation;
yawini = quat2eul([initori.W initori.X initori.Y initori.Z]);
yawini = yawini(1);

% Bucle de control infinito
while(1)
    % Obtenemos la posicion actual
    ori = sub_odom.LatestMessage.Pose.Pose.Orientation;

    yaw = quat2eul([ori.W ori.X ori.Y ori.Z]);
    yaw = yaw(1);
    fprintf('Orientacion actual: X=%f\n', yaw)

    % Calculamos el angulo girado
    ang=angdiff(yawini, yaw);
    fprintf('Angulo girado: %f\n', rad2deg(ang))

    % Si hemos girado el angulo indicado, detenemos el robot y salimos del bucle
    if (abs(ang) > abs(angulo))
        msg_vel.Angular.Z = 0;
        send(pub_vel, msg_vel);
        break;
    else
        send(pub_vel, msg_vel);
    end

    leer_sensores;

    waitfor(r);
end
