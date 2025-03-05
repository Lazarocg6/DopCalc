%--------------------------------------------------------------------------
%                   SGP4 Orbit Propagator (vectorized)
%
% References:
% Hoots, Felix R., and Ronald L. Roehrich. 1980. Models for Propagation of
% NORAD Element Sets. Spacetrack Report #3. U.S. Air Force: Aerospace Defense
% Command.
% 
% Vallado D. A; Fundamentals of Astrodynamics and Applications; McGraw-Hill
% , New York; 4th edition (2013).
% 
% Last modified:   2025/03/02   Lázaro Cantos García
%--------------------------------------------------------------------------
clc
clear
close all
format long g

f = 1/298.26; % Params WGS72
Re = 6378135; % Params WGS72
rTierra = 6378.0; %Radio medio de la tierra

addpath('SGP4_Vectorized')

%Coordenadas

latETSIT = 40.45206046037957;
lonETSIT = -3.726407299669201;
elETSIT = 670;

latVill = 40.6223011985758;
lonVill = -4.010124224894723;
elVill = 930;

latGRAVES = 47.34813145826119;
lonGRAVES = 5.51487314868131;
elGRAVES = 180; %altitud media

duracion = 300;% En minutos, 'duracion' minutos antes y despues del momento actual 
precision = 60/60;% En minutos

ISS = 25544;
Starlink = 44737;
OneWeb = 44057;

sats = [ISS];

n_sats = length(sats);

% filenames
filenameEOP = 'EOP-All.txt';  % Specify the file path
filenameTLEs = 'TLEs.txt';  % Specify the file path

% Actualizar archivo EOP
updateEOP(24,filenameEOP);

% Actualizar TLEs
updateTLE(6,sats,filenameTLEs);

%SGP4

[recef,vecef,rlla,vlla,tsince,epoch] = propagar(sats,duracion,precision,filenameTLEs,filenameEOP,f,Re);

%bistatic parameters

[bistaticRange,R1,R2,llaDIST,ecefDIST] = bistaticParams(latGRAVES,lonGRAVES,elGRAVES,latVill, ...
    lonVill,elVill,recef*1000,f,Re);

%Figuras

figure(1)

plot3(squeeze(recef(1,1,:)),squeeze(recef(1,2,:)),squeeze(recef(1,3,:)))
grid on
hold on 
for i = 2:n_sats
    plot3(squeeze(recef(i,1,:)),squeeze(recef(i,2,:)),squeeze(recef(i,3,:)))
end
hold off
pbaspect([1 1 1])
legend('ISS','Starlink','OneWeb','Location','best')

dist = zeros(n_sats,length(tsince));

for j = 1:n_sats
    for i = 1:length(tsince)
        dist(j,i) = norm(recef(j,:,i));
    end
end

figure(2)
plot(tsince,dist(1,:)-rTierra)
grid on
hold on
for i = 2:n_sats
    plot(tsince,dist(i,:)-rTierra)
end
hold off
legend('ISS','Starlink','OneWeb','Location','best')

lim = length(rlla)-(length(rlla)-length(recef));

figure(3)
geoplot(squeeze(rlla(1,1,1:lim)),squeeze(rlla(1,2,1:lim)))
% geobasemap('satellite'); 
% Annotate the plot with time
for i = floor(linspace(1,length(tsince),10))
    % Adding text annotations next to each satellite pass
    text(squeeze(rlla(1,1,i)),squeeze(rlla(1,2,i)), num2str(tsince(1,i)), ...
        'Color', 'black', 'FontSize', 7, 'HorizontalAlignment', 'center');
end
hold on
for i = 2:n_sats
    geoplot(squeeze(rlla(i,1,1:lim)),squeeze(rlla(i,2,1:lim)))
end
for i = 1:n_sats
    geoplot(squeeze(rlla(i,1,floor(lim/2))),squeeze(rlla(i,2,floor(lim/2))),'ok')
end
hold off
legend('ISS','Starlink','OneWeb','Location','northeast')

cte = 1000;
figure(4)
plot(tsince(1,:),bistaticRange(1,:)/cte)
grid on
hold on
plot(tsince(1,:),R1(1,:)/cte)
plot(tsince(1,:),R2(1,:)/cte)
for i = 2:n_sats
    plot(tsince(i,:),bistaticRange(i,:)/cte)
end
hold off
legend('ISS','Starlink','OneWeb','Location','best')
title('Bistatic range')
ylabel('Magnitude [Km]')
xlabel('Time [min]')