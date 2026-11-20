' bslib: BrightScript runtime functions for the BrighterScript language
' v0.1.1

'
' Convert a value into a string. For non-primitive values, this will return the type instead of its value in most cases.
' @param dynamic value - the value to be turned into a string.
' @return string - the string representation of `value`
'
function bslib_toString(value)
    valueType = type(value)
    'if the var supports `toStr()`
    if valueType = "<uninitialized>" then
        return valueType
    else if value = invalid then
        return "<invalid>"
    else if GetInterface(value, "ifToStr") <> invalid then
        return value.toStr()
    else if valueType = "roSGNode"
        return "Node(" + value.subType() + ")"
    end if
    'TODO add class name for objects once we have reflection implemented

    'when all else fails, just return the type
    return "<" + valueType + ">"
end function

'
' Simple ternary function. Given a condition, return the
' consequent if true, and the alternate if false
'
function bslib_ternary(condition, consequent, alternate)
    if condition then
        return consequent
    else
        return alternate
    end if
end function

'
' Return consequent if consequent is not invalid, otherwise return alternate
'
function bslib_coalesce(consequent, alternate)
    if consequent <> invalid then
        return consequent
    else
        return alternate
    end if
end function


sub DSVideoScaleFonts(parent as object)
    if parent.isSubtype("Label") and parent.font <> invalid
        parent.font.size = Int(parent.font.size * 1.5 + 0.5)
    end if
    for each child in parent.getChildren(-1, 0)
        DSVideoScaleFonts(child)
    end for
end sub

sub DSVideoSetFont(label as object, fontName as string)
    label.font = fontName
    DSVideoScaleFonts(label)
end sub
