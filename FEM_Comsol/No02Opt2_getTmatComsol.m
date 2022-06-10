%% Get transition matrix from Comsol

%% load model
model = mphload('PECpatchSWMatlab');

% show model
% mphgeom(model)

% show mesh
% mphmesh(model,'mesh1')

% see parameters of the model
param = mphgetexpressions(model.param);
param

%% Lebedev's points
lebDegree = [6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302, ...
    350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, ...
    3470, 3890, 4334, 4802, 5294, 5810];

%% loop over frequency

Nka = 10; % number of frequencies
kaVec = linspace(1,2.6,Nka); % electrical size
TCell = cell(1,Nka);
lMax = nan(1,Nka);

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
    lMax(1,ika) = ceil(ka + iota*(ka)^(1/3) + 3);

    k0 = param{8,4} % wavenumber
    param{8,3}

    f0 = param{10,4} % frequency
    param{10,3}

    % number of spherical waves
    indexMatrix = ...
        sphericalVectorWaves.indexMatrix(lMax(1,ika));
    nSW = size(indexMatrix,2);

        
%% loop over spherical waves
    Tmat = [];
    for SWindex = 1:nSW
        tic

        % set parameters
        model.param.set('sWind',num2str(SWindex));

        % run given study
        model.study('std1').run

        %% generate grid for scattered field
        ind = find(lebDegree > 4/3*(lMax(1,ika) - 2)^2,1);
        nLebOut = lebDegree(1, ind);

        [gridEs, ~, ~] = utilities.getLebedevSphere(nLebOut);
        gridEs = gridEs.*scattRadius;

        %% evaluate scattered field
        rObs = gridEs.';
        [EsxRe, EsyRe, EszRe] = mphinterp(model,{'real(emw.relEx)',...
            'real(emw.relEy)','real(emw.relEz)'},'coord',rObs);
        [EsxIm, EsyIm, EszIm] = mphinterp(model,{'imag(emw.relEx)',...
            'imag(emw.relEy)','imag(emw.relEz)'},'coord',rObs);
        Es = [(EsxRe + 1i*EsxIm).', (EsyRe + 1i*EsyIm).', (EszRe + 1i*EszIm).'];

        %% get f-vector from Es
        [fSW] = utilities.projectEsTof(lMax(1,ika), k0, gridEs, Es);

        Tmat = [Tmat, fSW(:,1)];
        save([pwd,'\results\tmpTmat.mat'],'Tmat');

        disp(['SW index ',num2str(SWindex),', duration ',num2str(toc),' s', ...
            ' frequency sample: ',num2str(ika)])
    end


TCell{1,ika} = Tmat;    
end

save([pwd,'\results\TmatComsol-',date,'.mat'],'TCell','kaVec','lMax');