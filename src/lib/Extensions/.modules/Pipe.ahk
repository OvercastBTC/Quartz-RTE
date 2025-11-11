#Requires AutoHotkey 2+

;? this is my lib file, for Quartz-RTE, use the one below
;! for the local lib files, comment out the below and uncomment the ones after
; #Include <Extensions\.formats\JSONS>

;? this the local lib files, for Quartz-RTE, use this one
;! for the local lib files, uncomment the ones below
#Include ../.formats/JSONS.ahk

Global A_Delay := DelayManager.Delay

/**
 * @class NamedPipeManager
 * @description Static, universal, two-way named pipe manager for cross-process variable sharing in AHK v2.
 * @version 1.0.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-04-19
 * @requires AutoHotkey v2.0+
 *
 * @property {String} PipeName The name of the pipe.
 * @method {Void} StartServer(callback) Start the server and handle requests.
 * @method {Any}  Request(data) Send data and get a response (client).
 * @method {Void} Send(data, hPipe) Send data to the pipe (internal).
 * @method {Any}  Read(hPipe) Read data from the pipe (internal).
 * @example
 * ; Start the server in one script:
 * NamedPipeManager.StartServer((data) => data == "delay" ? Clip.getdelayTime() : "unknown")
 * ; In any script, get the delay:
 * delay := NamedPipeManager.Request("delay")
 * Sleep(delay)
 */
class NamedPipeManager {

	#Requires AutoHotkey v2+

	static Version := "1.0.0"

    static PipeName := "\\.\pipe\AHK_UniversalPipe"
    static BufferSize := 4096

    /**
     * @description Start the server and handle requests with a callback.
     * @param {Func} callback Function to process incoming data and return a response.
     * @returns {Void}
     */
    static StartServer(callback) {
        if !IsSet(callback) || !HasMethod(callback, "Call")
            throw ValueError("A callback function is required", -1)
        Loop {
            hPipe := DllCall("CreateNamedPipe", "Str", this.PipeName, "UInt", 3, "UInt", 0, "UInt", 1, "UInt", this.BufferSize, "UInt", this.BufferSize, "Ptr", 0, "Ptr", 0, "Ptr")
            if hPipe = -1 {
                Sleep(1000)
                continue
            }
            if !DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {
                DllCall("CloseHandle", "Ptr", hPipe)
                continue
            }
            try {
                data := this.Read(hPipe)
                response := callback(data)
                this.Send(response, hPipe)
            } catch as err {
                ; Optionally log error
            }
            DllCall("DisconnectNamedPipe", "Ptr", hPipe)
            DllCall("CloseHandle", "Ptr", hPipe)
        }
    }

    /**
     * @description Send data to the server and get a response.
     * @param {Any} data Data to send.
     * @returns {Any} Response from the server.
     */
    static Request(data) {
        hPipe := DllCall("CreateFile", "Str", this.PipeName, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
        if hPipe = -1
            throw OSError("Could not connect to pipe", -1)
        try {
            this.Send(data, hPipe)
            response := this.Read(hPipe)
            return response
        } finally {
            DllCall("CloseHandle", "Ptr", hPipe)
        }
    }

    /**
     * @description Send data to the pipe (as JSON).
     * @param {Any} data Data to send.
     * @param {Ptr} hPipe Pipe handle.
     * @returns {Void}
     */
    static Send(data, hPipe) {
        ; json := cJson.Dump(data)
        json := JSONS.Stringify(data)
        buf := Buffer(StrPut(json, "UTF-8"))
        StrPut(json, buf, "UTF-8")
        DllCall("WriteFile", "Ptr", hPipe, "Ptr", buf, "UInt", buf.Size, "UInt*", 0, "Ptr", 0)
    }

    /**
     * @description Read data from the pipe (as JSON).
     * @param {Ptr} hPipe Pipe handle.
     * @returns {Any} Data read from the pipe.
     */
    static Read(hPipe) {
        buf := Buffer(this.BufferSize, 0)
        DllCall("ReadFile", "Ptr", hPipe, "Ptr", buf, "UInt", buf.Size, "UInt*", &bytesRead := 0, "Ptr", 0)
        if bytesRead = 0
            return ""
        json := StrGet(buf, bytesRead, "UTF-8")
		; try return cJson.Load(json)
        try return JSONS.Parse(json)
        catch
            return json
    }
}
;@endregion PipeManager
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region DelayManager

/**
 * @class DelayManager
 * @description Static delay manager for system-aware, cached delay values in AHK v2.
 * @version 1.0.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-04-19
 * @requires AutoHotkey v2.0+
 * @dependency Clip.getdelayTime()
 *
 * @property {Integer} Delay The current cached delay value in ms.
 * @property {Integer} Interval The update interval in ms.
 * @method {DelayManager} Recalculate() Force recalculation of delay (method chaining).
 * @method {DelayManager} SetInterval(ms) Set update interval (method chaining).
 * @example
 * delay := DelayManager.Delay
 * Sleep(delay)
 * DelayManager.SetInterval(10000).Recalculate()
 */
class DelayManager {

	#Requires AutoHotkey v2+

    static Version := "1.0.0"
    static _delay := 50
    static _lastUpdate := 0
    static _interval := 5000

    /**
     * @property {Integer} Delay
     * @description Gets the current delay, recalculates if interval elapsed.
     * @returns {Integer} Delay in ms.
     */
    static Delay {
        get {
            ; now := A_TickCount
            ; if (now - this._lastUpdate > this._interval) {
            ;     this.Recalculate()
            ; }
            ; return this._delay
			return 400
        }
    }

    /**
     * @property {Integer} Interval
     * @description Gets or sets the update interval in ms.
     */
    static Interval {
        get => this._interval
        ; set => this._interval := value
    }

	/**
	 * @description High-precision delay calibration using QueryPerformanceCounter.
	 * @param {Integer} iterations Number of iterations to run.
	 * @returns {Map} Map with keys: delay (ms), elapsed (ticks), freq (Hz)
	 * @throws {ValueError} If iterations is not a positive integer.
	 * @example
	 * result := DelayManager.QueryPerformanceTime(1000)
	 */
	static QueryPerformanceTime(iterations := 1000) {
		
		local freq := start := finish := num := 0

		if !IsSet(iterations) || iterations < 1{
			throw ValueError("Iterations must be a positive integer", -1)
		}
		DllCall("QueryPerformanceFrequency", "Int64*", &freq)
		DllCall("QueryPerformanceCounter", "Int64*", &start)

		Loop iterations {
			num := A_Index ** 2
			num /= 2
		}
		DllCall("QueryPerformanceCounter", "Int64*", &finish)
		local elapsed := finish - start
		local delay := Round((elapsed / freq) * 1000)
		return Map("delay", delay, "elapsed", elapsed, "freq", freq)
	}
	
	/**
	 * @description Calculate system delay time using specified method.
	 * @param {String} method Timing method ('query', 'tick', 'combined')
	 * @param {Integer} samples Number of samples to collect
	 * @param {Integer} iterations Iterations per sample
	 * @returns {Number} Calibrated delay time in milliseconds
	 * @throws {ValueError} If parameters are invalid.
	 * @example
	 * delay := DelayManager.GetDelayTime('query', 5, 1000)
	 */
	static GetDelayTime(method := 'combined', samples := 5, iterations := 1000) {
		
		local delays := []
		local delay := 0

		if !IsSet(method) {
			method := 'query'
		}
		if !IsSet(samples) || samples < 1 {
			samples := 5
		}
		if !IsSet(iterations) || iterations < 1{
			iterations := 1000
		}
		Loop samples {
			switch method {
				case "query":
					result := DelayManager.QueryPerformanceTime(iterations)
					delay := result["delay"]
				case "tick":
					tickBefore := A_TickCount
					Loop iterations {
						num := A_Index ** 2
						num /= 2
					}
					delay := A_TickCount - tickBefore
				case "combined":
					qpResult := DelayManager.QueryPerformanceTime(iterations)
					tickBefore := A_TickCount
					Loop iterations {
						num := A_Index ** 2
						num /= 2
					}
					tickDelay := A_TickCount - tickBefore
					delay := Round((qpResult["delay"] + tickDelay) / 2)
				default:
					throw ValueError("Unknown timing method: " method, -1)
			}
			delays.Push(delay)
		}
		; Return median value for stability
		delays.Sort()
		return delays[Floor(delays.Length / 2) + 1]
	}

    /**
     * @description Force recalculation of delay.
     * @returns {DelayManager} This instance for method chaining.
     */
    static Recalculate() {
        try {
            this._delay := this.GetDelayTime()
        } catch Error as err {
            this._delay := 50
        }
        this._lastUpdate := A_TickCount
        return this
    }

    /**
     * @description Set the update interval in ms.
     * @param {Integer} ms Interval in milliseconds.
     * @returns {DelayManager} This instance for method chaining.
     */
    static SetInterval(ms) {
        if (!IsSet(ms) || ms < 100) {
            throw ValueError("Interval must be >= 100 ms", -1)
		}
        this._interval := ms
        return this
    }

    /**
     * @description Clean up resources when object is destroyed.
     */
    __Delete() {
        ; No persistent resources, but included for standards.
    }
}
; ---------------------------------------------------------------------------
;@endregion DelayManager
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region SystemMetrics
/**
 * @class SystemMetrics
 * @description Provides static and instance access to system metrics.
 * @version 1.2.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-04-19
 * @requires AutoHotkey v2.0+
 *
 * @property {Number} CpuLoad Gets the current CPU load (static or instance).
 * @property {Number} MemLoad Gets the current memory load (static or instance).
 * @property {Number} ScaleFactor Gets the current scale factor (static or instance).
 * @method {Number} GetSystemLoad Gets system CPU load as a percentage.
 * @method {Number} GetMemoryLoad Gets system memory load as a percentage.
 * @example
 * cpu := SystemMetrics.CpuLoad
 * mem := SystemMetrics.MemLoad
 * scale := SystemMetrics.ScaleFactor
 */
class SystemMetrics {
    static _cpuLoad := 0
    static _memLoad := 0
    static _lastUpdate := 0
    static _interval := 5000
    static _cpuMethod := "default" ; "default" (GetSystemTimes) or "pdh"

    /**
     * @property {Number} CpuLoad
     * @description Gets the current CPU load (static or instance).
     */
    CpuLoad {
        get => SystemMetrics.GetCpuLoad()
        set => this._cpuLoad := value
    }

    /**
     * @property {Number} MemLoad
     * @description Gets the current memory load (static or instance).
     */
    MemLoad {
        get => SystemMetrics.GetMemLoad()
        set => this._memLoad := value
    }

    /**
     * @property {Number} ScaleFactor
     * @description Gets the current scale factor (static or instance).
     */
    ScaleFactor {
        get => this.CalcScaleFactor()
    }

    /**
     * @description Get system CPU load as a percentage (0-100).
     * @param {String} method Optional. "default" (GetSystemTimes) or "pdh" (PDH API).
     * @returns {Number} CPU load percentage.
     */
    static GetSystemLoad(method := unset) {
        if !IsSet(method)
            method := this._cpuMethod
        switch method {
            case "pdh":
                return this._GetSystemLoadPDH()
            default:
                return this._GetSystemLoadDefault()
        }
    }

    /**
     * @private
     * @description Get system CPU load using GetSystemTimes (default).
     * @returns {Number} CPU load percentage.
     */
    static _GetSystemLoadDefault() {
        static prevIdle := 0, prevKernel := 0, prevUser := 0
        buf := Buffer(24, 0)
        if !DllCall("GetSystemTimes", "Ptr", buf, "Ptr", buf.Ptr + 8, "Ptr", buf.Ptr + 16)
            return 0
        idle := NumGet(buf, 0, "Int64")
        kernel := NumGet(buf, 8, "Int64")
        user := NumGet(buf, 16, "Int64")
        if !prevIdle
            prevIdle := idle, prevKernel := kernel, prevUser := user
        sys := (kernel - prevKernel) + (user - prevUser)
        idleDelta := idle - prevIdle
        prevIdle := idle, prevKernel := kernel, prevUser := user
        if sys = 0
            return 0
        cpuLoad := 100 - Round((idleDelta * 100) / sys)
        return cpuLoad < 0 ? 0 : (cpuLoad > 100 ? 100 : cpuLoad)
    }

    /**
     * @private
     * @description Get system CPU load using PDH API.
     * @returns {Number} CPU load percentage.
     */
    static _GetSystemLoadPDH() {
        static pdh := DllCall("LoadLibrary", "Str", "pdh.dll", "Ptr")
        static query := 0
        static counter := 0
        if !query {
            if DllCall("pdh\PdhOpenQuery", "Ptr", 0, "Ptr", 0, "Ptr*", &query := 0) != 0
                return 50
            if DllCall("pdh\PdhAddCounter", "Ptr", query, "Str", "\Processor(_Total)\% Processor Time", "Ptr", 0, "Ptr*", &counter := 0) != 0
                return 50
        }
        DllCall("pdh\PdhCollectQueryData", "Ptr", query)
        Sleep(100)
        DllCall("pdh\PdhCollectQueryData", "Ptr", query)
        static PDH_FMT_DOUBLE := 0x00000200
        value := Buffer(16, 0)
        if DllCall("pdh\PdhGetFormattedCounterValue", "Ptr", counter, "UInt", PDH_FMT_DOUBLE, "Ptr", 0, "Ptr", value) = 0
            return Round(NumGet(value, 8, "Double"))
        return 50
    }

    /**
     * @description Get system memory load as a percentage (0-100).
     * @returns {Number} Memory load percentage.
     */
    static GetMemoryLoad() {
        buf := Buffer(64, 0)
        NumPut("UInt", 64, buf, 0)
        if !DllCall("GlobalMemoryStatusEx", "Ptr", buf)
            return 0
        total := NumGet(buf, 8, "Int64")
        avail := NumGet(buf, 16, "Int64")
        if total = 0
            return 0
        memLoad := 100 - Round((avail * 100) / total)
        return memLoad < 0 ? 0 : (memLoad > 100 ? 100 : memLoad)
    }

    /**
     * @description Static getter for CPU load (cached).
     */
    static GetCpuLoad() {
        now := A_TickCount
        if (now - this._lastUpdate > this._interval) {
            this._cpuLoad := this.GetSystemLoad()
            this._memLoad := this.GetMemoryLoad()
            this._lastUpdate := now
        }
        return this._cpuLoad
    }

    /**
     * @description Static getter for memory load (cached).
     */
    static GetMemLoad() {
        this.GetCpuLoad()
        return this._memLoad
    }

    /**
     * @description Calculates scale factor based on system metrics.
     * @returns {Number} Scale factor.
     */
    CalcScaleFactor() {
        cpu := this.CpuLoad
        mem := this.MemLoad
        factor := 1.0
        if (cpu > 80)
            factor *= 1.5
        else if (cpu < 20)
            factor *= 0.8
        if (mem > 90)
            factor *= 1.3
        return factor
    }

    /**
     * @description Set the CPU load method ("default" or "pdh").
     * @param {String} method Method to use ("default" or "pdh").
     * @returns {SystemMetrics} This instance for method chaining.
     */
    static SetCpuMethod(method) {
        if !IsSet(method) || (method != "default" && method != "pdh")
            throw ValueError("Method must be 'default' or 'pdh'", -1)
        this._cpuMethod := method
        return this
    }
}
