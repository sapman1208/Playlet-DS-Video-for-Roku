
' v0.11.0 is the first release without HomeGridScreen, which still crashes on the devices
' pinned to v0.7.0 - v0.10.3.


function PlayletLibUrls_IsUnsupported(entry as object) as boolean
    matches = CreateObject("roRegex", "^https://github\.com/iBicha/playlet/releases/download/v(\d+\.\d+\.\d+)/", "").Match(entry.link)
    if matches.Count() <> 2
        return false
    end if
    return PlayletLibUrls_CompareVersions(matches[1], "0.11.0") < 0
end function

function PlayletLibUrls_CompareVersions(left as string, right as string) as integer
    leftParts = left.Tokenize(".")
    rightParts = right.Tokenize(".")
    for i = 0 to leftParts.Count() - 1
        leftPart = leftParts[i].ToInt()
        rightPart = rightParts[i].ToInt()
        if leftPart < rightPart
            return -1
        end if
        if leftPart > rightPart
            return 1
        end if
    end for
    return 0
end function