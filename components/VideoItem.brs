sub init()
    DSVideoScaleFonts(m.top)
    m.top.observeField("itemContent", "onContentSet")
    m.top.observeField("focusPercent", "onFocusChange")
    m.top.findNode("poster").observeField("loadStatus", "onPosterLoadStatus")
    m.content = invalid
end sub

sub onContentSet(event as object)
    content = event.getData()
    if m.content <> invalid then m.content.unobserveFieldScoped("HDPosterUrl")
    m.content = content
    if content = invalid then return
    m.content.observeFieldScoped("HDPosterUrl", "updatePosterSource")
    mode = "portrait"
    if content.layoutMode <> invalid and content.layoutMode <> "" then mode = content.layoutMode
    applyLayoutMode(mode)
    m.top.findNode("titleLabel").text = content.title
    adjustSecondaryLine(mode, content.title)
    dateLabel = m.top.findNode("dateLabel")
    dateLabel.text = ""
    dateLabel.visible = false
    if content.playlistDate <> invalid and content.playlistDate <> ""
        dateLabel.text = content.playlistDate
        if mode = "playlistWide" or mode = "playlistHomeVideo" then dateLabel.visible = true
    end if
    updatePosterSource()
    if content.description <> invalid and content.description <> ""
        m.top.findNode("yearLabel").text = content.description
    else
        m.top.findNode("yearLabel").text = ""
    end if
end sub

sub updatePosterSource()
    if m.content = invalid then return
    poster = m.top.findNode("poster")
    iconPoster = m.top.findNode("iconPoster")
    uri = m.content.HDPosterUrl
    hasArtwork = uri <> invalid and uri <> ""
    poster.visible = hasArtwork
    iconPoster.visible = not hasArtwork and m.content.iconUrl <> invalid and m.content.iconUrl <> ""
    if iconPoster.visible then iconPoster.uri = m.content.iconUrl
    if not hasArtwork
        poster.uri = ""
        setContentArtworkState("false")
        return
    end if
    if poster.uri <> uri
        setArtworkStatus("loading")
        poster.uri = uri
    else if poster.loadStatus = "ready"
        setContentArtworkState("true")
        setArtworkStatus("ready")
    end if
end sub

sub onPosterLoadStatus(event as object)
    if m.content = invalid then return
    poster = m.top.findNode("poster")
    if not poster.visible or poster.uri <> m.content.HDPosterUrl then return
    status = event.getData()
    if status = "ready"
        setContentArtworkState("true")
        setArtworkStatus("ready")
    else if status = "failed" or status = "failure"
        setContentArtworkState("false")
        setArtworkStatus("failed")
    end if
end sub

sub setArtworkStatus(status as string)
    if m.content.hasField("artworkStatus") then m.content.artworkStatus = status
end sub

sub setContentArtworkState(value as string)
    if m.content = invalid then return
    if m.content.hasField("artworkLoaded")
        m.content.artworkLoaded = value
    else
        m.content.addFields({ artworkLoaded: value })
    end if
end sub

sub adjustSecondaryLine(mode as string, titleText as string)
    if mode = "playlistEpisode" then return
    if mode <> "compactPortrait" and mode <> "moviePortrait" and mode <> "playlistMovie" and mode <> "homeLandscape" then return
    year = m.top.findNode("yearLabel")
    if titleText = invalid then titleText = ""
    if mode = "homeLandscape"
        if len(titleText) <= 36
            year.translation = [0, 336]
        else if len(titleText) <= 72
            year.translation = [0, 358]
        else
            year.translation = [0, 380]
        end if
    else if mode = "playlistMovie"
        if len(titleText) <= 18
            year.translation = [0, 346]
        else if len(titleText) <= 36
            year.translation = [0, 368]
        else
            year.translation = [0, 374]
        end if
    else
        if len(titleText) <= 18
            year.translation = [0, 374]
        else if len(titleText) <= 36
            year.translation = [0, 394]
        else
            year.translation = [0, 412]
        end if
    end if
end sub

sub applyLayoutMode(mode as string)
    bg = m.top.findNode("bg")
    poster = m.top.findNode("poster")
    title = m.top.findNode("titleLabel")
    year = m.top.findNode("yearLabel")
    dateLabel = m.top.findNode("dateLabel")
    dateLabel.visible = false
    dateLabel.width = 220
    dateLabel.height = 24
    DSVideoSetFont(dateLabel, "font:TinySystemFont")
    dateLabel.color = "#8BAFD1"
    DSVideoSetFont(title, "font:SmallSystemFont")
    title.maxLines = 2
    title.lineSpacing = 0
    DSVideoSetFont(year, "font:SmallSystemFont")
    year.maxLines = 1
    year.wrap = false
    year.height = 34
    year.color = "#8BAFD1"

    if mode = "landscape" or mode = "homeLandscape" or mode = "showLandscape" or mode = "playlistWide" or mode = "playlistHomeVideo"
        bg.width = 520
        bg.height = 292
        poster.width = 520
        poster.height = 292
        poster.loadDisplayMode = "scaleToZoom"
        if mode = "showLandscape" or mode = "playlistWide" or mode = "playlistHomeVideo" then poster.loadDisplayMode = "scaleToFit"
        m.top.findNode("iconPoster").width = 132
        m.top.findNode("iconPoster").height = 132
        m.top.findNode("iconPoster").translation = [194, 80]
        title.translation = [0, 308]
        title.width = 520
        title.height = 48
        year.translation = [0, 360]
        year.width = 520
        if mode = "homeLandscape"
            DSVideoSetFont(title, "font:TinySystemFont")
            title.height = 78
            title.maxLines = 3
            title.lineSpacing = -1
            DSVideoSetFont(year, "font:TinySystemFont")
            year.translation = [0, 336]
        else if mode = "showLandscape"
            title.height = 76
            title.maxLines = 3
            year.translation = [0, 386]
        else if mode = "playlistWide" or mode = "playlistHomeVideo"
            bg.height = 260
            poster.height = 260
            poster.loadDisplayMode = "scaleToZoom"
            title.translation = [0, 274]
            title.height = 42
            DSVideoSetFont(title, "font:SmallBoldSystemFont")
            title.maxLines = 1
            year.translation = [0, 306]
            year.height = 58
            DSVideoSetFont(year, "font:TinySystemFont")
            year.maxLines = 2
            year.lineSpacing = 0
            year.wrap = true
            year.color = "#FFFFFF"
            dateLabel.translation = [0, 366]
            dateLabel.width = 520
            if mode = "playlistHomeVideo"
                title.height = 64
                title.maxLines = 2
                year.height = 0
                dateLabel.translation = [0, 334]
                dateLabel.height = 30
            end if
        end if
    else if mode = "playlistSelector"
        bg.width = 220
        bg.height = 220
        poster.width = 220
        poster.height = 220
        poster.loadDisplayMode = "scaleToFit"
        m.top.findNode("iconPoster").width = 118
        m.top.findNode("iconPoster").height = 118
        m.top.findNode("iconPoster").translation = [51, 51]
        title.translation = [0, 236]
        title.width = 220
        title.height = 34
        DSVideoSetFont(title, "font:TinySystemFont")
        title.maxLines = 1
        title.lineSpacing = 0
        year.translation = [0, 276]
        year.width = 220
        year.height = 0
        DSVideoSetFont(year, "font:TinySystemFont")
    else if mode = "playlistMovie"
        bg.width = 220
        bg.height = 300
        poster.width = 220
        poster.height = 300
        poster.loadDisplayMode = "scaleToFill"
        m.top.findNode("iconPoster").width = 100
        m.top.findNode("iconPoster").height = 100
        m.top.findNode("iconPoster").translation = [60, 100]
        title.translation = [0, 308]
        title.width = 220
        title.height = 58
        DSVideoSetFont(title, "font:TinySystemFont")
        title.maxLines = 2
        title.lineSpacing = 0
        year.translation = [0, 388]
        year.width = 220
        year.height = 26
        DSVideoSetFont(year, "font:TinySystemFont")
        year.maxLines = 1
        year.wrap = false
    else if mode = "playlistEpisode"
        bg.width = 220
        bg.height = 124
        poster.width = 220
        poster.height = 124
        poster.loadDisplayMode = "scaleToFit"
        m.top.findNode("iconPoster").width = 96
        m.top.findNode("iconPoster").height = 96
        m.top.findNode("iconPoster").translation = [62, 14]
        title.translation = [0, 142]
        title.width = 220
        title.height = 54
        DSVideoSetFont(title, "font:TinySystemFont")
        title.maxLines = 2
        title.lineSpacing = -1
        year.translation = [0, 202]
        year.width = 220
        year.height = 120
        DSVideoSetFont(year, "font:TinySystemFont")
        year.maxLines = 4
        year.wrap = true
    else if mode = "icon"
        bg.width = 220
        bg.height = 220
        poster.width = 220
        poster.height = 220
        poster.loadDisplayMode = "scaleToFit"
        m.top.findNode("iconPoster").width = 118
        m.top.findNode("iconPoster").height = 118
        m.top.findNode("iconPoster").translation = [51, 51]
        title.translation = [0, 236]
        title.width = 220
        title.height = 74
        DSVideoSetFont(title, "font:TinySystemFont")
        title.maxLines = 3
        title.lineSpacing = -1
        year.translation = [0, 316]
        year.width = 220
        DSVideoSetFont(year, "font:TinySystemFont")
    else
        bg.width = 220
        bg.height = 330
        poster.width = 220
        poster.height = 330
        poster.loadDisplayMode = "scaleToFill"
        m.top.findNode("iconPoster").width = 112
        m.top.findNode("iconPoster").height = 112
        m.top.findNode("iconPoster").translation = [54, 109]
        title.translation = [0, 334]
        title.width = 220
        title.height = 48
        year.translation = [0, 394]
        year.width = 220
        if mode = "compactPortrait" or mode = "moviePortrait"
            DSVideoSetFont(title, "font:TinySystemFont")
            title.height = 58
            title.maxLines = 2
            title.lineSpacing = 0
            year.translation = [0, 412]
            DSVideoSetFont(year, "font:TinySystemFont")
            year.height = 78
            year.maxLines = 3
            year.wrap = true
        end if
    end if
end sub

sub onFocusChange(event as object)
    if event = invalid then return
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    return false
end function
