close all;
clear all;

%% DECLARACIÓN DE SUBSCRIBERS
%% Odometria
sub_odom = rossubscriber('/pose', 'nav_msgs/Odometry'); 

%% Laser
sub_laser = rossubscriber('/scan', 'sensor_msgs/LaserScan');
%% Sonares
sub_sonar0 = rossubscriber('/sonar_0', 'sensor_msgs/Range');
sub_sonar1 = rossubscriber('/sonar_1', 'sensor_msgs/Range');
sub_sonar2 = rossubscriber('/sonar_2', 'sensor_msgs/Range');
sub_sonar3 = rossubscriber('/sonar_3', 'sensor_msgs/Range');
sub_sonar4 = rossubscriber('/sonar_4', 'sensor_msgs/Range');
sub_sonar5 = rossubscriber('/sonar_5', 'sensor_msgs/Range');
sub_sonar6 = rossubscriber('/sonar_6', 'sensor_msgs/Range');
sub_sonar7 = rossubscriber('/sonar_7', 'sensor_msgs/Range');

%% DECLARACIÓN DE PUBLISHERS
pub_vel = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
pub_enable = rospublisher('/cmd_motor_state', 'std_msgs/Int32');

%% GENERACIÓN DE MENSAJE
msg_vel = rosmessage(pub_vel);
msg_enable_motor = rosmessage(pub_enable);

%% Ratio del bucle
r=rateControl(10);

% Activar motores enviando enable_motor = 1
msg_enable_motor.Data = 1;
send(pub_enable, msg_enable_motor);

disp('Inicializacion finalizada correctamente');