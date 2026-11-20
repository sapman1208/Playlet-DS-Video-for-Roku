function AppManager_CaptureLastExitInfo(scene as object) as void
    manager = CreateObject("roAppManager")
    ' roAppManager.GetLastExitInfo() is only available on Roku OS 13 and above
    if FindMemberFunction(manager, "GetLastExitInfo") = invalid
        return
    end if
    lastExitInfo = manager.GetLastExitInfo()
    Logger_LogLastExitInfo(lastExitInfo)
    scene.lastExitInfo = lastExitInfo
end function