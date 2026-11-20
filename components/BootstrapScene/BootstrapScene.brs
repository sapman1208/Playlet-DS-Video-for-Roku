'import "LoadingMessages.bs"
'import "pkg:/source/Dialog.bs"
'import "pkg:/source/Logger.bs"
'import "pkg:/source/Manifest.bs"
'import "pkg:/source/Registry.bs"

function Init() as void
    m.scene = m.top
    m.top.backgroundURI = ""
    m.top.backgroundColor = "#141B28FF"
    m.loadingIndicator = m.top.findNode("LoadingIndicator")
    m.loadingIndicator.visible = false
    m.global.addFields({
        loadingIndicator: m.loadingIndicator
    })
    m.top.observeField("appShortcut", "onAppShortcut")
    m.top.observeField("exitChannel", "onPlayletExit")
    m.top.observeField("startPlaylet", "showPlaylet")
    m.top.setFocus(true)
end function

sub showPlaylet()
    if m.dsVideo <> invalid
        m.dsVideo.unobserveField("returnToLauncher")
        m.top.removeChild(m.dsVideo)
        m.dsVideo = invalid
    end if
    m.top.dialog = invalid
    m.top.activeApp = "playlet"
    m.top.backgroundColor = "#242424FF"
    m.top.exitChannel = false
    if m.playlet <> invalid
        m.playlet.getParent().visible = true
        m.playlet.findNode("AppController").callFunc("FocusTopScreen", invalid)
        return
    end if
    m.loadingIndicator.visible = true
    m.loadingIndicator.message = GetLoadingMessage()
    m.playletLibUrls = GetPlayletLibUrls()
    m.playletLibUrlIndex = 0
    LoadPlayletLib()
end sub

function GetPlayletLibUrls() as object
    return [{
        type: "embedded-zip"
        link: Manifest_ReadValue("playlet_lib_zip_embedded_url")
    }]
end function

function LoadPlayletLib() as void
    if m.playletLibUrlIndex >= m.playletLibUrls.Count()
        m.loadingIndicator.visible = false
        ShowPlayletLibLoadErrorDialog()
        return
    end if
    RemoveComponentLibrary()
    uri = m.playletLibUrls[m.playletLibUrlIndex].link
    LoadComponentLibrary(uri)
end function

function OnLoadStatusChanged() as void
    libUrl = m.playletLibUrls[m.playletLibUrlIndex]
    if m.lib.loadStatus = "ready"
        RemoveComponentLibrary()
        Logger_Log(("Playlet lib loaded from " + bslib_toString(libUrl.link) + " in " + bslib_toString(m.timer.TotalMilliseconds()) + " ms"))
        m.timer = invalid
        m.scene.playletLibLoadedUrl = libUrl
        container = m.scene.findNode("MainSceneContainer")
        m.playlet = container.createChild("PlayletLib:MainScene")
        m.scene.libSceneCreated = true
        return
    end if
    if m.lib.loadStatus = "failed"
        Logger_Log(("Playlet lib failed to load from " + bslib_toString(libUrl.link) + " in " + bslib_toString(m.timer.TotalMilliseconds()) + " ms"))
        ' Try next url
        m.playletLibUrlIndex += 1
        LoadPlayletLib()
    end if
end function

function CreateInputTransportEventsHandler(_unused as dynamic) as object
    return CreateObject("roSGNode", "PlayletLib:InputTransportEventsHandler")
end function

function RemoveComponentLibrary() as void
    if m.lib = invalid
        return
    end if
    m.lib.unobserveField("loadStatus")
    m.scene.removeChild(m.lib)
    m.lib = invalid
end function

function LoadComponentLibrary(uri as string)
    m.timer = CreateObject("roTimespan")
    m.timer.mark()
    m.lib = m.scene.createChild("ComponentLibrary")
    ' bs:disable-next-line NO_OBSERVE_STRING_CALLBACK
    m.lib.observeField("loadStatus", "OnLoadStatusChanged")
    Logger_Log(("Loading Playlet lib from " + bslib_toString(uri)))
    m.lib.uri = uri
end function

function ShowPlayletLibLoadErrorDialog()
    message = [
        "Could not load Playlet component library from any of the following urls:"
    ]
    bulletText = []
    for each url in m.playletLibUrls
        bulletText.push("[" + url.type + "] " + url.link)
    end for
    bottomText = [
        "Please restart Playlet."
        "If the problem persist, contact Playlet authors."
    ]
    DialogShowError(message, bulletText, bottomText)
end function

sub onAppShortcut(event as object)
    target = event.getData()
    if target = "ds" and m.top.activeApp = "playlet" and m.playlet <> invalid
        m.top.activeApp = "ds"
        m.top.dialog = invalid
        queue = m.playlet.findNode("VideoQueue")
        if queue <> invalid then queue.closePlayer = true
        m.playlet.getParent().visible = false
        m.dsVideo = m.top.createChild("DSVideoView")
        m.dsVideo.observeField("returnToLauncher", "showPlaylet")
        m.dsVideo.callFunc("startDSVideo")
    else if target = "playlet" and m.top.activeApp = "ds"
        showPlaylet()
    end if
end sub

sub onPlayletExit(event as object)
    if event.getData() and m.top.activeApp = "playlet" then m.top.shutdownRequested = true
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press and key = "back" and m.top.activeApp = "playlet"
        m.top.exitChannel = true
        return true
    end if
    return false
end function
