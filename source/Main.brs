' Playlet (App to play videos from an Invidious server on Roku TVs)
' Copyright (C) 2025 Brahim Hadriche
' This program is free software: you can redistribute it and/or modify
' it under the terms of the GNU Affero General Public License as published by
' the Free Software Foundation, either version 3 of the License, or
' (at your option) any later version.
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Affero General Public License for more details.

' You should have received a copy of the GNU Affero General Public License
' along with this program.  If not, see <https://www.gnu.org/licenses/>.
sub Main(args as object)
    if args = invalid then args = {}
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.setMessagePort(port)
    m.global = screen.getGlobalNode()
    Logger_Init()
    Registry_ClearRegistryIfNeeded(args)
    scene = screen.CreateScene("BootstrapScene")
    AppManager_CaptureLastExitInfo(scene)
    scene.launchArgs = args
    input = CreateObject("roInput")
    input.setMessagePort(port)
    input.EnableTransportEvents()
    transportEventsHandler = invalid
    systemLog = CreateObject("roSystemLog")
    systemLog.SetMessagePort(port)
    screen.show()
    scene.observeField("libSceneCreated", port)
    scene.observeField("enableSystemLogType", port)
    waitMilliseconds = 0
    ' Some Roku builds reject the port observer. Check the latched exit request on timeout in that case.
    if not scene.observeField("shutdownRequested", port) then waitMilliseconds = 500
    scene.signalBeacon("AppLaunchComplete")
    scene.startPlaylet = true
    while true
        msg = wait(waitMilliseconds, port)
        if msg = invalid and scene.shutdownRequested then exit while
        msgType = type(msg)
        if msgType = "roSystemLogEvent"
            if scene.activeApp = "playlet"
                info = msg.GetInfo()
                info.DateTime = info.DateTime.ToISOString()
                scene.systemLogEvent = info
            end if
        else if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                exit while
            end if
        else if msgType = "roSGNodeEvent"
            field = msg.getField()
            data = msg.getData()
            if LCase(field) = "shutdownrequested" and data = true then exit while
            if field = "enableSystemLogType"
                systemLog.EnableType(data)
            end if
            if field = "libSceneCreated"
                transportEventsHandler = invalid
                if data and scene.activeApp = "playlet"
                    transportEventsHandler = scene.callfunc("CreateInputTransportEventsHandler", invalid)
                end if
            end if
        else if msgType = "roInputEvent"
            info = msg.getInfo()
            if info.type = "transport"
                status = "unhandled"
                if scene.activeApp = "playlet" and transportEventsHandler <> invalid
                    status = transportEventsHandler.callfunc("HandleTransportEvent", info)
                end if
                input.EventResponse({
                    id: info.id
                    status: status
                })
            else if scene.activeApp = "playlet"
                scene.inputArgs = info
            end if
        end if
    end while
    m.global = invalid
end sub
