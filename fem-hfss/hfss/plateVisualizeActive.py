# ----------------------------------------------
# Script Recorded by ANSYS Electronics Desktop Version 2021.1.0
# 8:16:13  Mar 23, 2022
# ----------------------------------------------

import ScriptEnv

# initialize simulation
ScriptEnv.Initialize("Ansoft.ElectronicsDesktop")
oDesktop.RestoreWindow()
oProject = oDesktop.SetActiveProject("plate-plotting")
oDesign = oProject.SetActiveDesign("thin-pec-only")

datadir = 'C:/Users/kschab/Desktop/scattering-dyadic-characteristic-modes/fem-hfss/data/'
thetaList = [90, 90, 90, 90, 0, 180, 54.7356, 54.7356, 54.7356, 125.2644, 54.7356, 125.2644, 125.2644, 125.2644]
phiList = [0, 180, 90, -90, 0, 0, 45, 135, -45, 45, -135, -45, 135, -135]
fnAbsList = [0.0002634, 0.00027844, 5.5239e-05, 3.6828e-05, 0.0001672, 0.00014649, 0.25111, 0.25114, 0.25084, 0.25095, 0.25088, 0.25122, 0.25088, 0.2512, 0.055418, 0.055431, 0.46343, 0.46337, 1.6549e-05, 5.1896e-05, 0.086837, 0.086881, 0.086799, 0.086783, 0.086838, 0.086761, 0.086726, 0.086714]
fnPhaList = [178.5631, 29.0491, 9.2301, 13.7223, -151.6337, 175.8972, 1.2808, -178.7148, -178.7478, -178.7013, 1.2391, 1.2762, 1.2881, -178.7212, -168.2092, -168.3424, 0, -0.018926, 91.709, 89.3666, 177.5841, 177.6057, 177.5631, 177.3914, 177.6033, 177.4014, 177.387, 177.4197]
FGHZ = '0.8541'
rerunflag = 0

# if needed, clear solutions and rerun base simulation with no adaptive passes
if rerunflag == 1:
    # try to do full deletions, if data exists
    try: 
        oDesign.DeleteFullVariation("All", False)
    except:
        1
    TPOL = ['0','1']
    PPOL = ['1','0']
    NPOL = ['p','t']

    oModule = oDesign.GetModule("AnalysisSetup")
    oModule.EditSetup("Setup1", 
        [
            "NAME:Setup1",
            "SolveType:="		, "Single",
            "Frequency:="		, FGHZ+"GHz",
            "MaxDeltaE:="		, 0.01,
            "MaximumPasses:="	, 1,
            "MinimumPasses:="	, 1,
            "MinimumConvergedPasses:=", 1,
            "PercentRefinement:="	, 30,
            "IsEnabled:="		, True,
            [
                "NAME:MeshLink",
                "ImportMesh:="		, False
            ],
            "BasisOrder:="		, 1,
            "DoLambdaRefine:="	, True,
            "DoMaterialLambda:="	, True,
            "SetLambdaTarget:="	, False,
            "Target:="		, 0.3333,
            "UseMaxTetIncrease:="	, False,
            "UseDomains:="		, False,
            "UseIterativeSolver:="	, False,
            "SaveRadFieldsOnly:="	, False,
            "SaveAnyFields:="	, True,
            "IESolverType:="	, "Auto",
            "LambdaTargetForIESolver:=", 0.15,
            "UseDefaultLambdaTgtForIESolver:=", True,
            "IE Solver Accuracy:="	, "Balanced"
        ])



    # add excitations
    oModule = oDesign.GetModule("BoundarySetup")
    oModule.DeleteAllExcitations()
    count = 0
    for pdex in [0,1]:
        for idex in range(len(thetaList)):
            count = count+1
            # alter incident wave direction and polarization
            I_THETASTR = '%3.3f' % (180-thetaList[idex])
            I_PHISTR = '%3.3f' % (phiList[idex]+180)

            oModule = oDesign.GetModule("BoundarySetup")
            oModule.AssignPlaneWave(
                [
                    "NAME:IncPWave%d" %(count),
                    "IsCartesian:="		, False,
                    "PhiStart:="		, I_PHISTR+"deg",
                    "PhiStop:="		, I_PHISTR+"deg",
                    "PhiPoints:="		, 1,
                    "ThetaStart:="		, I_THETASTR+"deg",
                    "ThetaStop:="		, I_THETASTR+"deg",
                    "ThetaPoints:="		, 1,
                    "EoPhi:="		, PPOL[pdex],
                    "EoTheta:="		, TPOL[pdex],
                    "OriginX:="		, "0mm",
                    "OriginY:="		, "0mm",
                    "OriginZ:="		, "0mm",
                    "IsPropagating:="	, True,
                    "IsEvanescent:="	, False,
                    "IsEllipticallyPolarized:=", False
                ])


    oProject.Save()
    oDesign.AnalyzeAll()

# update incident field weights
oModule = oDesign.GetModule("Solutions")
for n in range(2*len(thetaList)):
    oModule.EditSources([
        [
            "FieldType:="		, "ScatteredFields",
            "IncludePortPostProcessing:=", False,
            "SpecifySystemPower:="	, False
        ],
        [
            "Name:="		, "IncPWave%d" %(n+1),
            "Magnitude:="		, "%3.5f V_per_meter" % (fnAbsList[n]),
            "Phase:="		, "%3.5fdeg" % (fnPhaList[n])
        ]])
        