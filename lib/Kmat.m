function K = Kmat(u)

[M,N] = size(u);

%% Derivatives operator (along i,j,k where k is the time)
D1 = spdiags([-ones(M,1) ones(M,1)],[0 1],M,M);
D2 = spdiags([-ones(N,1) ones(N,1)],[0 1],N,N);

% Neumann boundary conditions
D1(M,:) = 0;
D2(N,:) = 0;
D1 = kron(speye(N),D1); % i
D2 = kron(D2,speye(M)); % j

K{1} = D1;
K{2} = D2;

