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

datadir = 'xxDATADIRxx'
thetaList = xxTHETALISTDECLARExx
phiList = xxPHILISTDECLARExx
fnAbsList = xxFABSxx
fnPhaList = xxFPHAxx
FGHZ = 'xxFGHZxx'
rerunflag = xxRERUNFLAGxx

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
        