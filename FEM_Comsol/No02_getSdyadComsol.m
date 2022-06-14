%% Get scattering dyadic from Comsol

%% load model
model = mphload('PECpatchPWMatlab');

% show model
% mphgeom(model)

% show mesh
% mphmesh(model,'mesh1')

% see parameters of the model
param = mphgetexpressions(model.param);
param

%% loop over frequency

Nka = 10; % number of frequencies
kaVec = linspace(1,2.6,Nka); % electrical size
SdyadfullCell = cell(1,Nka);

for ika = 1:Nka
    
    ka = kaVec(1,ika); % electric size
    
    % set electric size
    model.param.set('ka',num2str(ka));
    param = mphgetexpressions(model.param);
    
    a = param{7,4} % circumscribing radius
    param{7,3}
    
    tAir = param{1,4}
    param{1,3}
    
    scattRadius = a + tAir/4; % radius of the measurement sphere
    
    % maximum degree of spherical waves
    iota = 2;
    lMax = ceil(ka + iota*(ka)^(1/3) + 3);
    
    k0 = param{8,4} % wavenumber
    param{8,3}
    
    f0 = param{10,4} % frequency
    param{10,3}
    
    %% Prepare incident PWs - Lebedev
    lebDegree = [6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302, ...
        350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, ...
        3470, 3890, 4334, 4802, 5294, 5810];
    
    nLebIn = 4/3*(lMax - 2)^2;
    ind = find(lebDegree > nLebIn,1 );
    nLebIn = lebDegree(1, ind); % Lebedev degree (incident planewaves)
    
    [nVec, ~, ~] = utilities.getLebedevSphere(nLebIn);
    nPW = size(nVec,1); % number of planewaves
    
    % evaluate unit vectors
    [~, theta, phi] = utilities.cart2sph(nVec(:,1), nVec(:,2), nVec(:,3));
    theta0 = [cos(theta).*cos(phi),cos(theta).*sin(phi),-sin(theta)];
    phi0 = [-sin(phi),cos(phi),zeros(size(theta,1),1)];
    
    %% generate grid for scattered field - Lebedev
    ind = find(lebDegree > 4/3*(lMax - 2)^2,1);
    nLebOut = lebDegree(1, ind);
    
    [gridEs, ~, ~] = utilities.getLebedevSphere(nLebOut);
    gridEs = gridEs.*scattRadius;
    
    % grid for surface plot
    % Nx = 50;
    % Ny = 50;
    % [X,Y] = meshgrid(linspace(-0.2,0.2,Nx),linspace(-0.2,0.2,Ny));
    % X = reshape(X,[Nx*Ny,1]);
    % Y = reshape(Y,[Nx*Ny,1]);
    % gridEs = [X,zeros(size(X)),Y];
    
    % plot grid
    % hold
    % figure
    % plot3(gridEs(:,1), gridEs(:,2), gridEs(:,3),'x')
    % grid on
    % xlabel('x [m]')
    % ylabel('y [m]')
    % zlabel('z [m]')
    % title('point grid for scattered field')
    
    Np = size(gridEs,1);
    
    %% phi - polarization
    PWphiToFmat = []; % each column is an f-vector of SW expansion for a given incident PW
    for iPW = 1:nPW
        tic
        
        % set parameters PW
        model.param.set('n0x',num2str(nVec(iPW,1)));
        model.param.set('n0y',num2str(nVec(iPW,2)));
        model.param.set('n0z',num2str(nVec(iPW,3)));
        
        model.param.set('e0x',num2str(phi0(iPW,1)));
        model.param.set('e0y',num2str(phi0(iPW,2)));
        model.param.set('e0z',num2str(phi0(iPW,3)));
        
        % run given study
        model.study('std1').run
        
        %% evaluate scattered field
        rObs = gridEs.';
        [EsxRe, EsyRe, EszRe] = mphinterp(model,{'real(emw.relEx)',...
            'real(emw.relEy)','real(emw.relEz)'},'coord',rObs);
        [EsxIm, EsyIm, EszIm] = mphinterp(model,{'imag(emw.relEx)',...
            'imag(emw.relEy)','imag(emw.relEz)'},'coord',rObs);
        Es = [(EsxRe + 1i*EsxIm).', (EsyRe + 1i*EsyIm).', (EszRe + 1i*EszIm).'];
        
        %% get f-vector from Es
        [f] = utilities.projectEsTof(lMax, k0, gridEs, Es);
        
        PWphiToFmat = [PWphiToFmat, f(:,1)];
        save([pwd,'\results\tmpPWphiToFmat.mat'],'PWphiToFmat');
        
        disp(['PW (phi) index ',num2str(iPW),', duration ',num2str(toc),' s', ...
            ', frequency sample: ',num2str(ika)])
        
    end
    
    
    %% theta - polarization
    PWthetaToFmat = []; % each column is an f-vector of SW expansion for a given incident PW
    for iPW = 1:nPW
        tic
        
        % set parameters PW
        model.param.set('n0x',num2str(nVec(iPW,1)));
        model.param.set('n0y',num2str(nVec(iPW,2)));
        model.param.set('n0z',num2str(nVec(iPW,3)));
        
        model.param.set('e0x',num2str(theta0(iPW,1)));
        model.param.set('e0y',num2str(theta0(iPW,2)));
        model.param.set('e0z',num2str(theta0(iPW,3)));
        
        % run given study
        model.study('std1').run
        
        %% evaluate scattered field
        rObs = gridEs.';
        [EsxRe, EsyRe, EszRe] = mphinterp(model,{'real(emw.relEx)',...
            'real(emw.relEy)','real(emw.relEz)'},'coord',rObs);
        [EsxIm, EsyIm, EszIm] = mphinterp(model,{'imag(emw.relEx)',...
            'imag(emw.relEy)','imag(emw.relEz)'},'coord',rObs);
        Es = [(EsxRe + 1i*EsxIm).', (EsyRe + 1i*EsyIm).', (EszRe + 1i*EszIm).'];
        
        %% get f-vector from Es
        [f] = utilities.projectEsTof(lMax, k0, gridEs, Es);
        
        PWthetaToFmat = [PWthetaToFmat, f(:,1)];
        save([pwd,'\results\tmpPWthetaToFmat.mat'],'PWthetaToFmat');
        
        disp(['PW (theta) index ',num2str(iPW),', duration ',num2str(toc),' s', ...
            ', frequency sample: ',num2str(ika)])
        
    end
    
    %% get scattering dyadic
    [SdyadThetaPhi, SdyadPhiPhi] = utilities.getFfromFSW(PWphiToFmat, nPW, lMax);
    [SdyadThetaTheta, SdyadPhiTheta] = utilities.getFfromFSW(PWthetaToFmat, nPW, lMax);
    
    Sdyadfull = [[SdyadThetaTheta, SdyadThetaPhi]; ...
        [SdyadPhiTheta, SdyadPhiPhi]];
    
    SdyadfullCell{1,ika} = Sdyadfull;
    
end

save([pwd,'\results\SdyadComsol-',date,'.mat'],'SdyadfullCell','kaVec','nPW','a');