# ----------------------------------------------
# Script Recorded by ANSYS Electronics Desktop Version 2021.1.0
# 1:26:37  Apr 22, 2022
# ----------------------------------------------
import ScriptEnv
ScriptEnv.Initialize("Ansoft.ElectronicsDesktop")
oDesktop.RestoreWindow()
oProject = oDesktop.SetActiveProject("plate-leb-multi")
oDesign = oProject.SetActiveDesign("thin-pec-only")
oModule = oDesign.GetModule("BoundarySetup")
oModule.AssignPlaneWave(
	[
		"NAME:IncPWave1",
		"IsCartesian:="		, False,
		"PhiStart:="		, "0deg",
		"PhiStop:="		, "0deg",
		"PhiPoints:="		, 1,
		"ThetaStart:="		, "0deg",
		"ThetaStop:="		, "0deg",
		"ThetaPoints:="		, 1,
		"EoPhi:="		, "1",
		"EoTheta:="		, "0",
		"OriginX:="		, "0mm",
		"OriginY:="		, "0mm",
		"OriginZ:="		, "0mm",
		"IsPropagating:="	, True,
		"IsEvanescent:="	, False,
		"IsEllipticallyPolarized:=", False
	])
oModule.AssignPlaneWave(
	[
		"NAME:IncPWave2",
		"IsCartesian:="		, False,
		"PhiStart:="		, "0deg",
		"PhiStop:="		, "0deg",
		"PhiPoints:="		, 1,
		"ThetaStart:="		, "0deg",
		"ThetaStop:="		, "0deg",
		"ThetaPoints:="		, 1,
		"EoPhi:="		, "1",
		"EoTheta:="		, "0",
		"OriginX:="		, "0mm",
		"OriginY:="		, "0mm",
		"OriginZ:="		, "0mm",
		"IsPropagating:="	, True,
		"IsEvanescent:="	, False,
		"IsEllipticallyPolarized:=", False
	])
oModule = oDesign.GetModule("Solutions")
oModule.EditSources(
	[
		[
			"FieldType:="		, "ScatteredFields",
			"IncludePortPostProcessing:=", False,
			"SpecifySystemPower:="	, False
		],
		[
			"Name:="		, "IncPWave1",
			"Magnitude:="		, "1V_per_meter",
			"Phase:="		, "0deg"
		],
		[
			"Name:="		, "IncPWave2",
			"Magnitude:="		, "2V_per_meter",
			"Phase:="		, "0deg"
		]
	])
