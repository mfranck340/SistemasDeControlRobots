%Definir la posicion de destino
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
endLocation = [x y];
%Cargar el mapa
%%%%%%%%%%%%%%%
%Crear el objeto VFH…y ajustar sus propiedades
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inicializar el localizador AMCL (práctica 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rellenamos los campos por defecto de la velocidad del robot, para que la lineal
%sea siempre 0.1 m/s
%Bucle de control infinito
while(1)

 %Leer y dibujar los datos del láser en la figura ‘fig_laser’

 %Leer la odometría
 %Obtener la posición pose=[x,y,yaw] a partir de la odometría anterior
 %Ejecutar amcl para obtener la posición estimada estimatedPose y la
 %covarianza estimatedCovariance (mostrar la última por pantalla para
 %facilitar la búsqueda de un umbral)
 %Si la covarianza está por debajo de un umbral, el robot está localizado y
 %finaliza el programa
 %Dibujar los resultados del localizador con el visualizationHelper
 %Llamar al objeto VFH para obtener la dirección a seguir por el robot para
 %evitar los obstáculos. Mostrar los resultados del algoritmo (histogramas)
 %en la figura ‘fig_vfh’

 %Rellenar el campo de la velocidad angular del mensaje de velocidad con un
 %valor proporcional a la dirección anterior (K=0.1)

 %Publicar el mensaje de velocidad
 %Esperar al siguiente periodo de muestreo
end
%%%%%%%%%%% AL SALIR DE ESTE BUCLE EL ROBOT YA SE HA LOCALIZADO %%%%%%%%%%
%%%%%%%%%%% COMIENZA LA PLANIFICACIÓN GLOBAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Paramos el robot, para que no avance mientras planificamos
%Hacemos una copia del mapa, para “inflarlo” antes de planificar
cpMap= copy(map);
inflate(cpMap,0.25);
%Crear el objeto PRM y ajustar sus parámetros
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
planner = mobileRobotPRM;
planner.Map=
planner.NumNodes=
planner.ConnectionDistance =
%Obtener la ruta hacia el destino desde la posición actual del robot y mostrarla
%en una figura
