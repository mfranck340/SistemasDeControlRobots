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
 if (estimatedCovariance(1,1) < umbralx && estimatedCovariance(2,2) < umbraly && ...
         estimatedCovariance(3,3) < umbralyaw)
    disp('Robot Localizado');
    break;
 end
 %Dibujar los resultados del localizador con el visualizationHelper
 %Llamar al objeto VFH para obtener la dirección a seguir por el robot para
 %evitar los obstáculos. Mostrar los resultados del algoritmo (histogramas)
 %en la figura ‘fig_vfh’

 %Rellenar el campo de la velocidad angular del mensaje de velocidad con un
 %valor proporcional a la dirección anterior (K=0.1)

 %Publicar el mensaje de velocidad

 %Esperar al siguiente periodo de muestreo
end