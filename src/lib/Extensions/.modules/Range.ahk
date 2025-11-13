#Requires AutoHotkey v2+
/**
 * @class Range
 * @description A utility class for generating number sequences and ranges, similar to Python's range() and JavaScript patterns
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025/09/17
 * @example
 * Static method usage (recommended)
 * Range.Generate(5)          ; [1,2,3,4,5]
 * Range.Generate(2, 8)       ; [2,3,4,5,6,7,8]
 * Range.Generate(2, 10, 2)   ; [2,4,6,8,10]
 * Range.Generate(10, 1, -2)  ; [10,8,6,4,2]
 *
 * Constructor usage (creates iterable object)
 * rng := Range(5)          ; Creates Range object
 * for num in rng {         ; Can be used in for loops
 *     MsgBox(num)
 * }
 * rng.ToArray()            ; Convert to array: [1,2,3,4,5]
 * rng.Length               ; Get length without creating array: 5
 * 
 */

class Range {
	; Instance properties for constructor-created objects
	start := 0
	end := 0
	step := 1
	
	/**
	 * Constructor - creates an iterable Range object
	 * @param start The starting number of the sequence
	 * @param end The ending number of the sequence (exclusive)
	 * @param step The increment between each number in the sequence
	 * @returns {Range} A Range object that can be iterated
	 */
	__New(start, end := "", step := 1) {
		if (end == "") {
			this.end := start
			this.start := 1
		} else {
			this.start := start
			this.end := end
		}
		this.step := step
	}
	
	/**
	 * Makes Range objects iterable in for loops
	 * @param numberOfVars Number of variables (1 for single value iteration)
	 * @returns {Func} A function that can be called to enumerate the range
	 */
	__Enum(numberOfVars) {
		current := this.start
		end := this.end
		step := this.step
		
		return (&value) => (
			(step > 0 && current >= end) || (step < 0 && current <= end)
			? false
			: (value := current, current += step, true)
		)
	}
	
	/**
	 * Static method - generates an array containing a sequence of numbers within a specified range
	 * Similar to Python's range() function
	 * @param start The starting number of the sequence
	 * @param end The ending number of the sequence (exclusive)
	 * @param step The increment between each number in the sequence
	 * @returns {Array} An array containing the sequence of numbers
	 * @example
	 * Range.Generate(5) ; Returns [1, 2, 3, 4, 5]
	 * Range.Generate(2, 8) ; Returns [2, 3, 4, 5, 6, 7, 8]
	 * Range.Generate(2, 10, 2) ; Returns [2, 4, 6, 8, 10]
	 * Range.Generate(10, 1, -2) ; Returns [10, 8, 6, 4, 2]
	 */
	static Generate(start, end := "", step := 1) {
		result := []
		
		if (end == "") {
			end := start
			start := 1
		}
		
		if (step > 0) {
			loop {
				if (start >= end){
					break
				}
				result.Push(start)
				start += step
			}
		} else if (step < 0) {
			loop {
				if (start <= end){
					break
				}
				result.Push(start)
				start += step
			}
		}
		
		return result
	}
	
	/**
	 * Converts the range to an array (useful for constructor-created ranges)
	 * @returns {Array} Array representation of the range
	 */
	ToArray() {
		return Range.Generate(this.start, this.end, this.step)
	}
	
	/**
	 * Gets the length of the range without creating the full array
	 * @returns {Integer} The number of elements in the range
	 */
	Length {
		get {
			if (this.step == 0) {
				return 0
			}
			return Abs(Ceil((this.end - this.start) / this.step))
		}
	}
}

; Example usage:
; 
; Static method usage (recommended for simple cases):
; MsgBox(Range.Generate(5).Join(", "))            ; Output: 1, 2, 3, 4, 5
; MsgBox(Range.Generate(2, 8).Join(", "))         ; Output: 2, 3, 4, 5, 6, 7, 8
; MsgBox(Range.Generate(2, 10, 2).Join(", "))     ; Output: 2, 4, 6, 8, 10
; MsgBox(Range.Generate(10, 1, -2).Join(", "))    ; Output: 10, 8, 6, 4, 2
; 
; Constructor usage (creates iterable objects):
; range := Range(5)                               ; Creates Range object
; for num in range {                              ; Can be used in for loops
;     MsgBox(num)                                 ; Outputs: 1, 2, 3, 4, 5
; }
; 
; range.ToArray()                                 ; Convert to array: [1, 2, 3, 4, 5]
; range.Length                                   ; Get length without creating array: 5


