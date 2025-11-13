/************************************************************************
 * @description Promise Library for AutoHotkey v2
 * @file Promise.ahk  
 * @author Generated for Quartz RTE
 * @version 1.0
 ***********************************************************************/

; Simple Promise implementation
class Promise {
    __New(executor := "") {
        this.state := "pending"
        this.value := unset
        this.handlers := []
        
        if (executor && IsFunc(executor)) {
            try {
                executor(this.resolve.Bind(this), this.reject.Bind(this))
            } catch as e {
                this.reject(e)
            }
        }
    }
    
    resolve(value) {
        if (this.state == "pending") {
            this.state := "fulfilled"
            this.value := value
            this._executeHandlers()
        }
    }
    
    reject(reason) {
        if (this.state == "pending") {
            this.state := "rejected" 
            this.value := reason
            this._executeHandlers()
        }
    }
    
    then(onFulfilled := "", onRejected := "") {
        return Promise((resolve, reject) => {
            this.handlers.Push({
                onFulfilled: onFulfilled,
                onRejected: onRejected,
                resolve: resolve,
                reject: reject
            })
            
            if (this.state != "pending") {
                this._executeHandlers()
            }
        })
    }
    
    _executeHandlers() {
        for handler in this.handlers {
            try {
                if (this.state == "fulfilled" && handler.onFulfilled && IsFunc(handler.onFulfilled)) {
                    result := handler.onFulfilled(this.value)
                    handler.resolve(result)
                } else if (this.state == "rejected" && handler.onRejected && IsFunc(handler.onRejected)) {
                    result := handler.onRejected(this.value)
                    handler.resolve(result)
                } else if (this.state == "fulfilled") {
                    handler.resolve(this.value)
                } else {
                    handler.reject(this.value)
                }
            } catch as e {
                handler.reject(e)
            }
        }
        this.handlers := []
    }
}