' Put the file at the root directry to avoid needing to create a folder


function Logger_Init()
    DeleteFile("cachefs:/playlet_startup_logs.txt")
end function

function Logger_Log(msg as string)
    msg = "[APP] " + msg
    print msg
    buffer = CreateObject("roByteArray")
    buffer.FromAsciiString(msg + (chr(10)))
    buffer.AppendFile("cachefs:/playlet_startup_logs.txt")
end function

function Logger_LogLastExitInfo(lastExitInfo as object) as void
    if lastExitInfo = invalid
        return
    end if
    msg = ("************ Last Exit Info ************" + chr(10))
    msg += ("exit_code: " + bslib_toString(lastExitInfo.exit_code) + chr(10))
    msg += ("timestamp: " + bslib_toString(lastExitInfo.timestamp) + chr(10))
    msg += ("app_state: " + bslib_toString(lastExitInfo.app_state) + chr(10))
    msg += ("media_player_state: " + bslib_toString(lastExitInfo.media_player_state) + chr(10))
    msg += ("mem_limit: " + bslib_toString(lastExitInfo.mem_limit) + chr(10))
    ' The echo is the PREVIOUS run's console — '| ' marks each line so consumers can skip it
    ' when scanning live output.
    consoleLog = (bslib_toString(lastExitInfo.console_log))
    msg += ("console_log:" + chr(10) + "| ") + consoleLog.Replace(chr(10), (chr(10) + "| ")) + (chr(10))
    msg += ("********** End Last Exit Info **********" + chr(10))
    print msg
    buffer = CreateObject("roByteArray")
    buffer.FromAsciiString(msg + (chr(10)))
    buffer.AppendFile("cachefs:/playlet_startup_logs.txt")
end function