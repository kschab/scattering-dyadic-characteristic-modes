function [Q, D, nIter, err] = iterativeEig(Afun, nSW, nModes, relError)
% Implemented according Mats' proposal, see Notes, sec. 5.4

%% initialize
QA = rand(nSW,1);
QF = [];
Diter = zeros(nSW,1);
m     = 1;
err   = 1;
ind   = 1:nModes;

%% iterate
while err(end) > relError
    nIter = m;
    QA(:,m) = QA(:,m)/sqrt(QA(:,m)'*QA(:,m));
    QF = [QF, Afun(QA(:,m))];

    S = zeros(nSW);
    P = zeros(nSW);
    for ip = 1:m
        S = S + QF(:,ip)*QA(:,ip)';
        P = P + QA(:,ip)*QA(:,ip)';
    end

    [Q, D] = eig(S);
    Diter  = [Diter, sort(diag(D), 'descend')];
    QA     = [QA, QF(:,m) - P*QF(:,m)];

    err(m) = max(abs((Diter(ind,m+1) - Diter(ind,m))./Diter(ind,m+1)));    
    m = m + 1;
end
end