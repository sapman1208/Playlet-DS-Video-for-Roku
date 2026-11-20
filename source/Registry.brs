'import "pkg:/source/PlayletLibUrls.bs"
function Registry_ReadKey(key as string, section as string) as dynamic
    sec = CreateObject("roRegistrySection", section)
    if not sec.Exists(key)
        return invalid
    end if
    return sec.Read(key)
end function

function Registry_DeleteKey(key as string, section as string)
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
end function

function Registry_DeleteAll()
    reg = CreateObject("roRegistry")
    reg.Delete("Playlet")
    reg.Flush()
end function

function Registry_GetPlayletLibUrlsFromRegistry() as object
    urlsJson = Registry_ReadKey("playlet_lib_urls", "Playlet")
    if urlsJson = invalid
        return invalid
    end if
    ' bs:disable-next-line NO_PARSE_JSON
    urls = ParseJson(urlsJson)
    return urls
end function

function Registry_ClearPlayletLibUrlsIfNeeded(launchArgs as object) as void
    if launchArgs = invalid or launchArgs.clearPlayletLibUrls = invalid
        return
    end if
    Registry_DeleteKey("playlet_lib_urls", "Playlet")
    Logger_Log("Cleared key playlet_lib_urls from registry")
end function

' BootstrapScene's load-failure fallback never reaches a pinned lib that loads and then
' crashes, so the device stays on it across every channel update.
function Registry_ClearUnsupportedPlayletLibUrls() as void
    urls = Registry_GetPlayletLibUrlsFromRegistry()
    if urls = invalid
        return
    end if
    for each entry in urls
        if PlayletLibUrls_IsUnsupported(entry)
            Registry_DeleteKey("playlet_lib_urls", "Playlet")
            Logger_Log(("Cleared key playlet_lib_urls from registry: " + bslib_toString(entry.link) + " is no longer supported"))
            return
        end if
    end for
end function

function Registry_ClearRegistryIfNeeded(launchArgs as object) as void
    if launchArgs = invalid or launchArgs.clearRegistry = invalid
        return
    end if
    Registry_DeleteAll()
    Logger_Log("Cleared all data from registry")
end function