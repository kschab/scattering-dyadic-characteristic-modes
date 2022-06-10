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
