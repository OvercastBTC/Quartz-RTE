/************************************************************************
 * @description ComVar Library for AutoHotkey v2 
 * @file ComVar.ahk
 * @author Generated for Quartz RTE
 * @version 1.0
 ***********************************************************************/

; ComVar Class for handling COM variants
class ComVar {
    __New(value := unset, varType := 0xC) {
        ; Simplified implementation for COM variant handling
        this.value := value ?? ""
        this.type := varType
    }
    
    __Item {
        get => this.value
        set => this.value := value
    }
}