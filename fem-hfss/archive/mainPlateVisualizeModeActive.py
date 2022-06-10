# ----------------------------------------------
# Script Recorded by ANSYS Electronics Desktop Version 2021.1.0
# 0:31:37  Apr 22, 2022
# ----------------------------------------------
import ScriptEnv
ScriptEnv.Initialize("Ansoft.ElectronicsDesktop")
oDesktop.RestoreWindow()
oProject = oDesktop.SetActiveProject("plate-leb-multi-pml")
oDesign = oProject.SetActiveDesign("thin-pec-only")
oModule = oDesign.GetModule("BoundarySetup")
#oModule.DeleteAllExcitations()
oModule = oDesign.GetModule("Solutions")
oModule.EditSources(
	[
		[
			"FieldType:="		, "ScatteredFields",
			"IncludePortPostProcessing:=", False,
			"SpecifySystemPower:="	, False
		],		[
			"Name:="		, "IncPWave1",
			"Magnitude:="		, "0.000236V_per_meter",
			"Phase:="		, "-32.4802deg"
		],
		[
			"Name:="		, "IncPWave2",
			"Magnitude:="		, "0.00015867V_per_meter",
			"Phase:="		, "57.6554deg"
		],
		[
			"Name:="		, "IncPWave3",
			"Magnitude:="		, "9.6077e-05V_per_meter",
			"Phase:="		, "69.4654deg"
		],
		[
			"Name:="		, "IncPWave4",
			"Magnitude:="		, "9.2603e-05V_per_meter",
			"Phase:="		, "-154.8902deg"
		],
		[
			"Name:="		, "IncPWave5",
			"Magnitude:="		, "0.09658V_per_meter",
			"Phase:="		, "170.619deg"
		],
		[
			"Name:="		, "IncPWave6",
			"Magnitude:="		, "0.096956V_per_meter",
			"Phase:="		, "-9.2772deg"
		],
		[
			"Name:="		, "IncPWave7",
			"Magnitude:="		, "0.070603V_per_meter",
			"Phase:="		, "-177.9128deg"
		],
		[
			"Name:="		, "IncPWave8",
			"Magnitude:="		, "0.070611V_per_meter",
			"Phase:="		, "2.1468deg"
		],
		[
			"Name:="		, "IncPWave9",
			"Magnitude:="		, "0.059007V_per_meter",
			"Phase:="		, "-179.5742deg"
		],
		[
			"Name:="		, "IncPWave10",
			"Magnitude:="		, "0.059122V_per_meter",
			"Phase:="		, "1.0076deg"
		],
		[
			"Name:="		, "IncPWave11",
			"Magnitude:="		, "0.058897V_per_meter",
			"Phase:="		, "0.73056deg"
		],
		[
			"Name:="		, "IncPWave12",
			"Magnitude:="		, "0.070739V_per_meter",
			"Phase:="		, "1.1043deg"
		],
		[
			"Name:="		, "IncPWave13",
			"Magnitude:="		, "0.059066V_per_meter",
			"Phase:="		, "-178.9746deg"
		],
		[
			"Name:="		, "IncPWave14",
			"Magnitude:="		, "0.070829V_per_meter",
			"Phase:="		, "-178.7226deg"
		],
		[
			"Name:="		, "IncPWave15",
			"Magnitude:="		, "0.0050899V_per_meter",
			"Phase:="		, "-172.4367deg"
		],
		[
			"Name:="		, "IncPWave16",
			"Magnitude:="		, "0.0051214V_per_meter",
			"Phase:="		, "5.8151deg"
		],
		[
			"Name:="		, "IncPWave17",
			"Magnitude:="		, "0.0051286V_per_meter",
			"Phase:="		, "8.4942deg"
		],
		[
			"Name:="		, "IncPWave18",
			"Magnitude:="		, "0.005357V_per_meter",
			"Phase:="		, "-176.9386deg"
		],
		[
			"Name:="		, "IncPWave19",
			"Magnitude:="		, "0.0069739V_per_meter",
			"Phase:="		, "-172.2934deg"
		],
		[
			"Name:="		, "IncPWave20",
			"Magnitude:="		, "0.0071371V_per_meter",
			"Phase:="		, "8.6063deg"
		],
		[
			"Name:="		, "IncPWave21",
			"Magnitude:="		, "0.0072655V_per_meter",
			"Phase:="		, "4.3448deg"
		],
		[
			"Name:="		, "IncPWave22",
			"Magnitude:="		, "0.0073404V_per_meter",
			"Phase:="		, "-176.0428deg"
		],
		[
			"Name:="		, "IncPWave23",
			"Magnitude:="		, "0.14556V_per_meter",
			"Phase:="		, "-179.5907deg"
		],
		[
			"Name:="		, "IncPWave24",
			"Magnitude:="		, "0.1452V_per_meter",
			"Phase:="		, "0.34163deg"
		],
		[
			"Name:="		, "IncPWave25",
			"Magnitude:="		, "0.1456V_per_meter",
			"Phase:="		, "0.22093deg"
		],
		[
			"Name:="		, "IncPWave26",
			"Magnitude:="		, "0.14557V_per_meter",
			"Phase:="		, "-179.7162deg"
		],
		[
			"Name:="		, "IncPWave27",
			"Magnitude:="		, "0.084856V_per_meter",
			"Phase:="		, "-179.1661deg"
		],
		[
			"Name:="		, "IncPWave28",
			"Magnitude:="		, "0.085052V_per_meter",
			"Phase:="		, "0.81263deg"
		]
	])