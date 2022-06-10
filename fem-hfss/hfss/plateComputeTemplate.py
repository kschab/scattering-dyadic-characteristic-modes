# ----------------------------------------------
# Script Recorded by ANSYS Electronics Desktop Version 2021.1.0
# 8:16:13  Mar 23, 2022
# ----------------------------------------------

import ScriptEnv

# initialize simulation
ScriptEnv.Initialize("Ansoft.ElectronicsDesktop")
oDesktop.RestoreWindow()
oProject = oDesktop.SetActiveProject("plate-compute")
oDesign = oProject.SetActiveDesign("thin-pec-only")

# try to do full deletions, if data exists
try: 
    oDesign.DeleteFullVariation("All", False)
except:
    1

datadir = 'xxDATADIRxx'
thetaList = xxTHETALISTDECLARExx
phiList = xxPHILISTDECLARExx
FGHZ = 'xxFGHZxx'

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
        "MaximumPasses:="	, 10,
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
        "SaveRadFieldsOnly:="	, True,
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


f_compiled = open(datadir+"tmpB.csv",'w')
count = 0
for pdex in [0,1]:
    for idex in range(len(thetaList)):

        oModule = oDesign.GetModule("Solutions")
        count = count+1
        for n in range(2*len(thetaList)):
            oModule.EditSources([
                [
                    "FieldType:="		, "ScatteredFields",
                    "IncludePortPostProcessing:=", False,
                    "SpecifySystemPower:="	, False
                ],
                [
                    "Name:="		, "IncPWave%d" %(n+1),
                    "Magnitude:="		, "0V_per_meter",
                    "Phase:="		, "0deg"
                ]])
        oModule.EditSources([
            [
                    "FieldType:="		, "ScatteredFields",
                    "IncludePortPostProcessing:=", False,
                    "SpecifySystemPower:="	, False
                ],
            [
            "Name:="		, "IncPWave%d" %(count),
            "Magnitude:="		, "1V_per_meter",
            "Phase:="		, "0deg"
            ]])


        oModule = oDesign.GetModule("ReportSetup")
        try:
            oModule.DeleteReports(["rE Table 1"])
        except:
            1
        oModule.CreateReport("rE Table 1", "Far Fields", "Data Table", "Setup1 : LastAdaptive", 
            [
                "Context:="		, "Infinite Sphere1"
            ],
            [
                "Theta:="		, ["All"],
                "Phi:="			, ["All"],
                "Freq:="		, [FGHZ+"GHz"],
                "IWavePhi:="		, ["All"],
                "IWaveTheta:="		, ["All"],
                "a:="			, ["Nominal"],
                "b:="			, ["Nominal"],
                "h:="			, ["Nominal"],
                "w:="			, ["Nominal"],
                "ePhi:="		, ["Nominal"]
            ], 
            [
                "X Component:="		, "Theta",
                "Y Component:="		, ["re(rEPhi)","im(rEPhi)","re(rETheta)","im(rETheta)"]
            ])

        for sdex in range(len(thetaList)):

            # alter incident wave direction and polarization
            S_THETASTR = '%3.3f' % (thetaList[sdex])
            S_PHISTR = '%3.3f' % (phiList[sdex])

            oModule = oDesign.GetModule("RadField")
            oModule.EditInfiniteSphereSetup("Infinite Sphere1", 
                [
                    "NAME:Infinite Sphere1",
                    "UseCustomRadiationSurface:=", False,
                    "CSDefinition:="	, "Theta-Phi",
                    "Polarization:="	, "Linear",
                    "ThetaStart:="		, S_THETASTR+"deg",
                    "ThetaStop:="		, S_THETASTR+"deg",
                    "ThetaStep:="		, "0deg",
                    "PhiStart:="		, S_PHISTR+"deg",
                    "PhiStop:="		, S_PHISTR+"deg",
                    "PhiStep:="		, "0deg",
                    "UseLocalCS:="		, False
                ])
            oModule = oDesign.GetModule("ReportSetup")
            idexSTR = str()
            #oModule.ExportToFile("rE Table 1", "G:/notebook/fem-cm/2022-03-21-rim/data/scratch/"+tag+NPOL[pdex]+"xx"+str(idex)+"xx"+str(sdex)+".csv", False)
            oModule.ExportToFile("rE Table 1", datadir+'tmpA.csv', False)
            f_temp = open(datadir+'tmpA.csv','r')
            data = f_temp.readlines()
            f_temp.close()
            f_compiled.writelines(data)

f_compiled.close()
#if pdex == 0:
#    oDesign.ExportConvergence("Setup1", "a=\'75mm\' b=\'150mm\' ePhi=\'1\' h=\'3mm\' w=\'2.5mm\'", datadir+"latest-convergence.conv")
#else:
#    oDesign.ExportConvergence("Setup1", "a=\'75mm\' b=\'150mm\' tPhi=\'1\' h=\'3mm\' w=\'2.5mm\'", datadir+"latest-convergence.conv")
oDesign.DeleteFieldVariation("All", False, False)