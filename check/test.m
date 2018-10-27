wordLength = 32;
fractionLength = 16;
innerGridSize = 12;
globalfimath('RoundingMethod', 'Floor', 'SumMode', 'KeepLSB', 'OverflowAction', 'Wrap')
np1 = [];

nm1 = [];
n = [];
% for i = 1:(innerGridSize + 4)^2
%     nm1 = [nm1 sfi(i - 1, wordLength, fractionLength)];
%     n = [n sfi(i - 1, wordLength, fractionLength)];
%     np1 = [np1 sfi(i - 1, wordLength, fractionLength)];
% end
% nm1 = reshape(nm1, innerGridSize+4, innerGridSize+4);
% n = reshape(n, innerGridSize+4, innerGridSize+4);
% np1 = reshape(np1, innerGridSize+4, innerGridSize+4);
nm1 = zeros(innerGridSize+4, innerGridSize+4);
n = zeros(innerGridSize+4, innerGridSize+4);
np1 = zeros(innerGridSize+4, innerGridSize+4);
center = 3+innerGridSize/2;
for x=4:12
    for y = 4:12
      n(x, y) = 0.1 * cos(pi/(1*innerGridSize)*sqrt((x-center)^2+(y-center)^2) )^2;
      %disp(hex(sfi(n(x, y), wordLength, fractionLength)));

    end
end
nm1 = sfi(nm1, wordLength, fractionLength);
n = sfi(n, wordLength, fractionLength);

np1 = sfi(np1, wordLength, fractionLength);
disp('first');
%printInnerGrid(n);

SR = 44100;                         % sample rate(Hz)
gamma = 450;                        % wave speed (1/s)
T60 = 2;                            % loss [freq.(Hz), T60(s), freq.(Hz), T60(s)]
epsilon = 1;                      % domain aspect ratio

lambda = 1/sqrt(2);                 % Courant number

%%%%%% end global parameters

% begin derived parameters

k = 1/SR;                           % time step
sig0 = 6*log(10)/T60;               % loss parameter

% stability condition/scheme parameters

h = gamma*k/lambda;                 % find grid spacing
Nx = floor(sqrt(epsilon)/h);        % number of x-subdivisions of spatial domain
Ny = floor(1/(sqrt(epsilon)*h));    % number of y-subdivisions of spatial domain
h = sqrt(epsilon)/Nx; lambda = gamma*k/h;                        % reset Courant number

s0 = (2-4*lambda^2)/(1+sig0*k);
s1 = lambda^2/(1+sig0*k);
t0 = -(1-sig0*k)/(1+sig0*k);

coeffn =   zeros(1, 13);
coeffn(7) = s0;
coeffn(3) = s1;
coeffn(6) = s1;
coeffn(8) = s1;
coeffn(11) = s1;
coeffnm1 = [0 0 0 0 0   0 0 0   0 0 0 0 0];
coeffnm1(7) = t0;
% coeffnm1(3) = 0.02;
% coeffnm1(6) = 0.02;
% coeffnm1(8) = 0.02;
% coeffnm1(11) = 0.02;

% coeffn = rand(1,13);
% coeffn = coeffn/sum(coeffn)/10;
% coeffn = sfi(coeffn, wordLength, fractionLength);
% coeffnm1 = sfi(coeffnm1, wordLength, fractionLength);


coeffn = sfi(coeffn, wordLength, fractionLength);
coeffnm1 = sfi(coeffnm1, wordLength, fractionLength);
surf(1:16, 1:16, double(n));
drawnow;
%%
result = np1(8, 8);
%fprintf('startvalue: %s \n', count, hex(result));
for count = 1:1000
    for y = 3:2+innerGridSize
        for x = 3:2+innerGridSize
            newValue = cast(coeffn(1) * n(x, y+2), 'like', n(1, 1)) + cast(coeffn(2) * n(x-1, y+1), 'like', n(1, 1)) + cast(coeffn(3) * n(x, y+1), 'like', n(1, 1)) + cast(coeffn(4) * n(x+1, y+1), 'like', n(1, 1)) ...
           + cast(coeffn(5) * n(x-2, y), 'like', n(1, 1)) + cast(coeffn(6) * n(x-1, y), 'like', n(1, 1)) + cast(coeffn(7) * n(x, y), 'like', n(1, 1)) + cast(coeffn(8) * n(x+1, y), 'like', n(1, 1)) + cast(coeffn(9) * n(x+2, y), 'like', n(1, 1)) ...
           + cast(coeffn(10) * n(x-1, y-1), 'like', n(1, 1)) + cast(coeffn(11) * n(x, y-1), 'like', n(1, 1)) + cast(coeffn(12) * n(x+1, y-1), 'like', n(1, 1)) + cast(coeffn(13) * n(x, y-2), 'like', n(1, 1)) + ...
           cast(coeffnm1(1) * nm1(x, y+2), 'like', n(1, 1)) + cast(coeffnm1(2) * nm1(x-1, y+1), 'like', n(1, 1)) + cast(coeffnm1(3) * nm1(x, y+1), 'like', n(1, 1)) + cast(coeffnm1(4) * nm1(x+1, y+1), 'like', n(1, 1)) ...
           + cast(coeffnm1(5) * nm1(x-2, y), 'like', n(1, 1)) + cast(coeffnm1(6) * nm1(x-1, y), 'like', n(1, 1)) + cast(coeffnm1(7) * nm1(x, y), 'like', n(1, 1)) + cast(coeffnm1(8) * nm1(x+1, y), 'like', n(1, 1)) + cast(coeffnm1(9) * nm1(x+2, y), 'like', n(1, 1)) ...
           + cast(coeffnm1(10) * nm1(x-1, y-1), 'like', n(1, 1)) + cast(coeffnm1(11) * nm1(x, y-1), 'like', n(1, 1)) + cast(coeffnm1(12) * nm1(x+1, y-1), 'like', n(1, 1)) + cast(coeffnm1(13) * nm1(x, y-2), 'like', n(1, 1));
            disp(newValue.hex)
                np1(x, y) = newValue;
        end
    end
    nm1 = n;
    n = np1;
    result = np1(8, 8);
    surf(1:16, 1:16, double(n));
    drawnow;
    fprintf('count: %d value: %s \n', count, result.hex);
    %printInnerGrid(n);
    
end
%%
% for i = 1:13
%     asd = coeffn(i);
%     fprintf('%d => x"%s",',i-1, asd.hex);
% end
% fprintf('\n');