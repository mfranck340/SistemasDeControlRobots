close all;

%Definir la posicion de destino
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
endLocation = [14 4];
startLocation = [1 -4];
%Cargar el mapa
%%%%%%%%%%%%%%%
load ../mapas/map_simple_rooms.mat
map = map_modified;

% Graficas
fig_laser = figure; title('LASER');
fig_vfh = figure; title('VFH');

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

%Inicializar el localizador AMCL (práctica 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
odometryModel = odometryMotionModel;
odometryModel.Noise = [0.2 0.2 0.2 0.2];
rangeFinderModel = likelihoodFieldSensorModel;
rangeFinderModel.SensorLimits = [0 8];
rangeFinderModel.Map = map;
tftree = rostf;
waitForTransform(tftree, '/robot0', '/robot0_laser_1');
sensorTransform = getTransform(tftree, '/robot0', '/robot0_laser_1');
laserQuat = [sensorTransform.Transform.Rotation.W sensorTransform.Transform.Rotation.X ...
    sensorTransform.Transform.Rotation.Y sensorTransform.Transform.Rotation.Z];
laserRotation = quat2eul(laserQuat, 'ZYX');
rangeFinderModel.SensorPose = ...
    [sensorTransform.Transform.Translation.X sensorTransform.Transform.Translation.Y laserRotation(1)];

amcl = monteCarloLocalization;
amcl.UseLidarScan = true;
amcl.MotionModel = odometryModel;
amcl.SensorModel = rangeFinderModel;
amcl.UpdateThresholds = [0.2,0.2,0.2];
amcl.ResamplingInterval = 1;
amcl.ParticleLimits = [5000 50000];          % Minimum and maximum number of particles
amcl.GlobalLocalization = true;             % global = true      local=false
amcl.InitialPose = [2.5 -4 0];                 % Initial pose of vehicle   
amcl.InitialCovariance = eye(3)*0.5; % Covariance of initial pose

visualizationHelper = ExampleHelperAMCLVisualization(map);

%Rellenamos los campos por defecto de la velocidad del robot, para que la lineal
%sea siempre 0.1 m/s
msg_vel.Linear.X = 0.1;
msg_vel.Linear.Y = 0;
msg_vel.Linear.Z = 0;
msg_vel.Angular.X = 0;
msg_vel.Angular.Y = 0;
msg_vel.Angular.Z = 0;

targetDir = 0;

% Umbrales
umbralx = 0.01;
umbraly = 0.01;
umbralyaw = 0.01;
%%
%Bucle de control infinito
i = 1;
while(1)
    %Leer y dibujar los datos del láser en la figura ‘fig_laser’
    figure(fig_laser);
    leer_sensores;
    scan = msg_laser.lidarScan;

    %figure(fig_vfh);
    %show(VFH);
    
    %Leer la odometría
    %Obtener la posición pose=[x,y,yaw] a partir de la odometría anterior
    %Ejecutar amcl para obtener la posición estimada estimatedPose y la
    %covarianza estimatedCovariance (mostrar la última por pantalla para
    %facilitar la búsqueda de un umbral)
    odomQuat = [msg_odom.Pose.Pose.Orientation.W msg_odom.Pose.Pose.Orientation.X ...
        msg_odom.Pose.Pose.Orientation.Y msg_odom.Pose.Pose.Orientation.Z];
    odomRotation = quat2eul(odomQuat);
    pose = [msg_odom.Pose.Pose.Position.X msg_odom.Pose.Pose.Position.Y odomRotation(1)];
    [isUpdated,estimatedPose,estimatedCovariance] = amcl(pose,scan);
    estimatedCovariance

    %Si la covarianza está por debajo de un umbral, el robot está localizado y
    %finaliza el programa
    if (estimatedCovariance(1,1) < umbralx && estimatedCovariance(2,2) < umbraly && estimatedCovariance(3,3) < umbralyaw)
        disp('Robot Localizado');
        break;
    end
    %Dibujar los resultados del localizador con el visualizationHelper
    %Llamar al objeto VFH para obtener la dirección a seguir por el robot para
    %evitar los obstáculos. Mostrar los resultados del algoritmo (histogramas)
    %en la figura ‘fig_vfh’
    if isUpdated
        i = i + 1;
        plotStep(visualizationHelper, amcl, estimatedPose, scan, i);
    end
    
    steeringDir = VFH(scan,targetDir);
    figure(fig_vfh);
    show(VFH);

    %Rellenar el campo de la velocidad angular del mensaje de velocidad con un
    %valor proporcional a la dirección anterior (K=0.1)
    K = 0.1;
    V_ang = K * steeringDir;
    msg_vel.Angular.Z = V_ang;

    if (V_ang ~= 0)
        msg_vel.Linear.X = 0;
    else
        msg_vel.Linear.X = 0.1;
    end
    
    %Publicar el mensaje de velocidad
    send(pub_vel,msg_vel);

    %Esperar al siguiente periodo de muestreo
    waitfor(r);
end
%%
leer_sensores;
startLocation = [msg_odom.Pose.Pose.Position.X msg_odom.Pose.Pose.Position.Y];
%%%%%%%%%%% AL SALIR DE ESTE BUCLE EL ROBOT YA SE HA LOCALIZADO %%%%%%%%%%
%%%%%%%%%%% COMIENZA LA PLANIFICACIÓN GLOBAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Paramos el robot, para que no avance mientras planificamos
%Hacemos una copia del mapa, para “inflarlo” antes de planificar
cpMap = copy(map);
inflate(cpMap,0.25);
%Crear el objeto PRM y ajustar sus parámetros
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
planner = mobileRobotPRM;
planner.Map = cpMap;
planner.NumNodes = 1000;
planner.ConnectionDistance = 3;
%Obtener la ruta hacia el destino desde la posición actual del robot y mostrarla
%en una figura
ruta = findpath(planner, startLocation, endLocation);
figure;
show(planner);
