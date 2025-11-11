#Requires AutoHotkey v2+


/**
 * @class key
 * @description Advanced keyboard key management for AHK v2
 * @author Updated
 * @version 1.2.0
 * @requires AutoHotkey v2+
 */
class keys {
	/**
	 * @class syntax
	 * @description Common key syntax elements
	 */
	class syntax extends keys {
		static down := " down"
		static up := " up"
		static lb := "{"
		static rb := "}"
	}

	;@region sc - Scan Code Constants
	/**
	 * @class sc
	 * @description Scan code constants for keyboard input
	 */
	class sc {
		static esc := 'sc01'
		static _1 := 'sc02'
		static _2 := 'sc03'
		static _3 := 'sc04'
		static _4 := 'sc05'
		static _5 := 'sc06'
		static _6 := 'sc07'
		static _7 := 'sc08'
		static _8 := 'sc09'
		static _9 := 'sc0A'
		static _0 := 'sc0B'
		static minus := 'sc0C'
		static equal := 'sc0D'
		static backspace := 'sc0E'
		static tab := 'sc0F'
		static q := 'sc10'
		static w := 'sc11'
		static e := 'sc12'
		static r := 'sc13'
		static t := 'sc14'
		static y := 'sc15'
		static u := 'sc16'
		static i := 'sc17'
		static o := 'sc18'
		static p := 'sc19'
		static lbracket := 'sc1A'
		static rbracket := 'sc1B'
		static enter := 'sc1C'
		static ctrl := 'sc1D'
		static control := 'sc1D'
		static lctrl := 'sc1D'
		static a := 'sc1E'
		static s := 'sc1F'
		static d := 'sc20'
		static f := 'sc21'
		static g := 'sc22'
		static h := 'sc23'
		static j := 'sc24'
		static k := 'sc25'
		static l := 'sc26'
		static semicolon := 'sc27'
		static quote := 'sc28'
		static backtick := 'sc29'
		static shift := 'sc2A'
		static lshift := 'sc2A'
		static backslash := 'sc2B'
		static z := 'sc2C'
		static x := 'sc2D'
		static c := 'sc2E'
		static v := 'sc2F'
		static b := 'sc30'
		static n := 'sc31'
		static m := 'sc32'
		static comma := 'sc33'
		static period := 'sc34'
		static slash := 'sc35'
		static rshift := 'sc36'
		static numpadMult := 'sc37'
		static alt := 'sc38'
		static lalt := 'sc38'
		static space := 'sc39'
		static capslock := 'sc3A'
		static f1 := 'sc3B'
		static f2 := 'sc3C'
		static f3 := 'sc3D'
		static f4 := 'sc3E'
		static f5 := 'sc3F'
		static f6 := 'sc40'
		static f7 := 'sc41'
		static f8 := 'sc42'
		static f9 := 'sc43'
		static f10 := 'sc44'
		static numlock := 'sc45'
		static scrolllock := 'sc46'
		static numpad7 := 'sc47'
		static numpad8 := 'sc48'
		static numpad9 := 'sc49'
		static numpadMinus := 'sc4A'
		static numpad4 := 'sc4B'
		static numpad5 := 'sc4C'
		static numpad6 := 'sc4D'
		static numpadPlus := 'sc4E'
		static numpad1 := 'sc4F'
		static numpad2 := 'sc50'
		static numpad3 := 'sc51'
		static numpad0 := 'sc52'
		static numpadDot := 'sc53'
		static f11 := 'sc57'
		static f12 := 'sc58'
		static rctrl := 'sc9D'
		static numpadDiv := 'sc135'
		static printscreen := 'sc137'
		static ralt := 'sc138'
		static pause := 'sc145'
		static home := 'sc147'
		static scUp := 'sc148'
		static SC_UP := 'sc148'
		static pageup := 'sc149'
		static left := 'sc14B'
		static right := 'sc14D'
		static end := 'sc14F'
		static scDown := 'sc150'
		static SC_DOWN := 'sc150'
		static pagedown := 'sc151'
		static insert := 'sc152'
		static delete := 'sc153'
		static win := 'sc15B'
		static lwin := 'sc15B'
		static rwin := 'sc15C'
		static appskey := 'sc15D'
		static menu := 'sc15D'
	}
	;@endregion sc

	;@region hot - Common Hotkey Mappings
	/**
	 * @class hot
	 * @description Common hotkey mappings
	 */
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	class hot extends keys {
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Font Formatting
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static Italics      	:= '^' 	this.sc.i
		static Bold         	:= '^' 	this.sc.b
		static Underline    	:= '^' 	this.sc.u
		static Strike       	:= '^' 	this.sc.d
		static Strikethrough 	:= '^' 	this.sc.d
		static Norm      		:= '!' 	this.sc.n
		;@endregion Font Formatting
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Text Alignment
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static AlignLeft    	:= '^' 	this.sc.l
		static AlignRight   	:= '^' 	this.sc.r
		static AlignCenter  	:= '^' 	this.sc.e
		static Justified    	:= '^' 	this.sc.j
		;@endregion Text Alignment
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Editing Operations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static Cut          	:= '^' 	this.sc.x
		static Copy         	:= '^' 	this.sc.c
		static Paste        	:= '^' 	this.sc.v
		static Undo         	:= '^' 	this.sc.z
		static Redo         	:= '^' 	this.sc.y
		static PasteSpecial 	:= '^!' this.sc.v
		static SelectAll    	:= '^' 	this.sc.a
		static SelectHome   	:= '^' 	this.sc.Home
		static SelectEnd    	:= '^' 	this.sc.End
		;@endregion Editing Operations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Document Formatting
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static BulletedList 	:= '+' 	this.sc.f12
		static InsertTable  	:= '^' 	this.sc.F12
		static SuperScript  	:= '^'  this.sc.equal
		static wSupScript 		:= '^' 	this.sc.period
		static SubScript    	:= '^+' this.sc.equal
		static wSubScript    	:= '^' 	this.sc.comma
		;@endregion Document Formatting
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Special Operations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static Search       	:= 		this.sc.F5
		static Find         	:= '^' 	this.sc.f
		static Replace      	:= '^' 	this.sc.h
		static CtrlEnter    	:= '^' 	this.sc.enter
		;@endregion Special Operations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region File Operations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static Save         	:= '^' this.vk.KEY_S
		static SaveButton     	:= '^+' this.vk.KEY_S
		static bSaveButton     	:= '!s' ;this.vk.KEY_S
		static Open         	:= '^' 	this.sc.o
		static Return 			:= this.sc.enter
		static Enter 			:= this.sc.enter
		;@endregion File Operations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Navigation
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static Alt1 			:= '!' this.sc._1
		static Alt2 			:= '!' this.sc._2
		static Alt3 			:= '!' this.sc._3
		static Alt4 			:= '!' this.sc._4
		static Alt5 			:= '!' this.sc._5
		static Alt6 			:= '!' this.sc._6
		;@endregion Navigation
	}
	;@endregion hot
	; ---------------------------------------
	; ---------------------------------------
	; ---------------------------------------
	;@region vk - Virtual Key Constants
	; ---------------------------------------
	; ---------------------------------------
	; ---------------------------------------
	/**
	 * @class vk
	 * @description Virtual key constants and hotkey combinations
	 */
	class vk extends keys {
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Hotkey Combinations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static SelectAll    	:= '^' 	this.sc.a
		static SelectHome   	:= '^' 	this.sc.Home
		static SelectEnd    	:= '^' 	this.sc.End
		static Italics      	:= '^' 	this.sc.i
		static Bold         	:= '^' 	this.sc.b
		static Underline    	:= '^' 	this.sc.u
		static AlignLeft    	:= '^' 	this.sc.l
		static AlignRight   	:= '^' 	this.sc.r
		static AlignCenter  	:= '^' 	this.sc.e
		static Justified    	:= '^' 	this.sc.j
		static Cut          	:= '^' 	this.sc.x
		static Copy         	:= '^' 	this.sc.c
		static Paste        	:= '^' 	this.sc.v
		static Undo         	:= '^' 	this.sc.z
		static Redo         	:= '^' 	this.sc.y
		static PasteSpecial 	:= '^!' this.sc.v
		static BulletedList 	:= '+' 	this.sc.f12
		static InsertTable  	:= '^' 	this.sc.F12
		static SuperScript  	:= '^=' this.sc.equal
		static wSupScript 		:= '^' 	this.sc.period
		static SubScript    	:= '^+' this.sc.equal
		static wSubScript    	:= '^' 	this.sc.comma
		static Search       	:= 		this.sc.F5
		static Find         	:= '^' 	this.sc.f
		static Replace      	:= '^' 	this.sc.h
		static CtrlEnter    	:= '^' 	this.sc.enter
		static Save         	:= '^' 	this.sc.s
		static SaveButton     	:= '^+' this.sc.s
		static Open         	:= '^' 	this.sc.o
		static Strikethrough 	:= '^' 	this.sc.d
		static Strike        	:= '^' 	this.sc.d
		;@endregion Hotkey Combinations
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		;@region Virtual Key Constants
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
		static LBUTTON 				:= 'vk01' 		; Left mouse button
		static RBUTTON 				:= 'vk02' 		; Right mouse button
		static CANCEL 				:= 'vk03' 		; Control-break processing
		static MBUTTON 				:= 'vk04' 		; Middle mouse button
		static XBUTTON1 			:= 'vk05' 		; X1 mouse button
		static XBUTTON2 			:= 'vk06' 		; X2 mouse button
		static BACK 				:= 'vk08' 		; BACKSPACE key
		static TAB 					:= 'vk09' 		; TAB key
		static CLEAR 				:= 'vk0C' 		; CLEAR key
		static RETURN 				:= 'vkD' 		; ENTER key
		static ENTER 				:= 'vkD' 		; ENTER key
		static SHIFT 				:= 'vk10' 		; SHIFT key
		static CONTROL 				:= 'vk11' 		; CTRL key
		static MENU 				:= 'vk12' 		; ALT key
		static PAUSE 				:= 'vk13' 		; PAUSE key
		static CAPITAL 				:= 'vk14' 		; CAPS LOCK key
		static KANA 				:= 'vk15' 		; IME Kana mode
		static HANGUEL 				:= 'vk15' 		; IME Hanguel mode
		static HANGUL 				:= 'vk15' 		; IME Hangul mode
		static IME_ON 				:= 'vk16' 		; IME On
		static JUNJA 				:= 'vk17' 		; IME Junja mode
		static FINAL 				:= 'vk18' 		; IME final mode
		static HANJA 				:= 'vk19' 		; IME Hanja mode
		static KANJI 				:= 'vk19' 		; IME Kanji mode
		static IME_OFF 				:= 'vk1A' 		; IME Off
		static ESCAPE 				:= 'vk1B' 		; ESC key
		static CONVERT 				:= 'vk1C' 		; IME convert
		static NONCONVERT 			:= 'vk1D' 		; IME nonconvert
		static ACCEPT 				:= 'vk1E' 		; IME accept
		static MODECHANGE 			:= 'vk1F' 		; IME mode change request
		static SPACE 				:= 'vk20' 		; SPACEBAR
		static PRIOR 				:= 'vk21' 		; PAGE UP key
		static NEXT 				:= 'vk22' 		; PAGE DOWN key
		static END 					:= 'vk23' 		; END key
		static HOME 				:= 'vk24' 		; HOME key
		static LEFT 				:= 'vk25' 		; LEFT ARROW key
		static UP 					:= 'vk26' 		; UP ARROW key
		static RIGHT 				:= 'vk27' 		; RIGHT ARROW key
		static DOWN 				:= 'vk28' 		; DOWN ARROW key
		static SELECT 				:= 'vk29' 		; SELECT key
		static PRINT 				:= 'vk2A' 		; PRINT key
		static EXECUTE 				:= 'vk2B' 		; EXECUTE key
		static SNAPSHOT 			:= 'vk2C' 		; PRINT SCREEN key
		static INSERT 				:= 'vk2D' 		; INS key
		static DELETE 				:= 'vk2E' 		; DEL key
		static HELP 				:= 'vk2F' 		; HELP key
		static KEY_0 				:= 'vk30' 		; 0 key
		static KEY_1 				:= 'vk31' 		; 1 key
		static KEY_2 				:= 'vk32' 		; 2 key
		static KEY_3 				:= 'vk33' 		; 3 key
		static KEY_4 				:= 'vk34' 		; 4 key
		static KEY_5 				:= 'vk35' 		; 5 key
		static KEY_6 				:= 'vk36' 		; 6 key
		static KEY_7 				:= 'vk37' 		; 7 key
		static KEY_8 				:= 'vk38' 		; 8 key
		static KEY_9 				:= 'vk39' 		; 9 key
		static KEY_A 				:= 'vk41' 		; A key
		static KEY_B 				:= 'vk42' 		; B key
		static KEY_C 				:= 'vk43' 		; C key
		static KEY_D 				:= 'vk44' 		; D key
		static KEY_E 				:= 'vk45' 		; E key
		static KEY_F 				:= 'vk46' 		; F key
		static KEY_G 				:= 'vk47' 		; G key
		static KEY_H 				:= 'vk48' 		; H key
		static KEY_I 				:= 'vk49' 		; I key
		static KEY_J 				:= 'vk4A' 		; J key
		static KEY_K 				:= 'vk4B' 		; K key
		static KEY_L 				:= 'vk4C' 		; L key
		static KEY_M 				:= 'vk4D' 		; M key
		static KEY_N 				:= 'vk4E' 		; N key
		static KEY_O 				:= 'vk4F' 		; O key
		static KEY_P 				:= 'vk50' 		; P key
		static KEY_Q 				:= 'vk51' 		; Q key
		static KEY_R 				:= 'vk52' 		; R key
		static KEY_S 				:= 'vk53' 		; S key
		static KEY_T 				:= 'vk54' 		; T key
		static KEY_U 				:= 'vk55' 		; U key
		static KEY_V 				:= 'vk56' 		; V key
		static KEY_W 				:= 'vk57' 		; W key
		static KEY_X 				:= 'vk58' 		; X key
		static KEY_Y 				:= 'vk59' 		; Y key
		static KEY_Z 				:= 'vk5A' 		; Z key
		static LWIN 				:= 'vk5B' 		; Left Windows key
		static RWIN 				:= 'vk5C' 		; Right Windows key
		static APPS 				:= 'vk5D' 		; Applications key
		static SLEEP 				:= 'vk5F' 		; Computer Sleep key
		static NUMPAD0 				:= 'vk60' 		; Numeric keypad 0 key
		static NUMPAD1 				:= 'vk61' 		; Numeric keypad 1 key
		static NUMPAD2 				:= 'vk62' 		; Numeric keypad 2 key
		static NUMPAD3 				:= 'vk63' 		; Numeric keypad 3 key
		static NUMPAD4 				:= 'vk64' 		; Numeric keypad 4 key
		static NUMPAD5 				:= 'vk65' 		; Numeric keypad 5 key
		static NUMPAD6 				:= 'vk66' 		; Numeric keypad 6 key
		static NUMPAD7 				:= 'vk67' 		; Numeric keypad 7 key
		static NUMPAD8 				:= 'vk68' 		; Numeric keypad 8 key
		static NUMPAD9 				:= 'vk69' 		; Numeric keypad 9 key
		static MULTIPLY 			:= 'vk6A' 		; Multiply key
		static ADD 					:= 'vk6B' 		; Add key
		static SEPARATOR 			:= 'vk6C' 		; Separator key
		static SUBTRACT 			:= 'vk6D' 		; Subtract key
		static DECIMAL 				:= 'vk6E' 		; Decimal key
		static DIVIDE 				:= 'vk6F' 		; Divide key
		static F1 					:= 'vk70' 		; F1 key
		static F2 					:= 'vk71' 		; F2 key
		static F3 					:= 'vk72' 		; F3 key
		static F4 					:= 'vk73' 		; F4 key
		static F5 					:= 'vk74' 		; F5 key
		static F6 					:= 'vk75' 		; F6 key
		static F7 					:= 'vk76' 		; F7 key
		static F8 					:= 'vk77' 		; F8 key
		static F9 					:= 'vk78' 		; F9 key
		static F10 					:= 'vk79' 		; F10 key
		static F11 					:= 'vk7A' 		; F11 key
		static F12 					:= 'vk7B' 		; F12 key
		static F13 					:= 'vk7C' 		; F13 key
		static F14 					:= 'vk7D' 		; F14 key
		static F15 					:= 'vk7E' 		; F15 key
		static F16 					:= 'vk7F' 		; F16 key
		static F17 					:= 'vk80' 		; F17 key
		static F18 					:= 'vk81' 		; F18 key
		static F19 					:= 'vk82' 		; F19 key
		static F20 					:= 'vk83' 		; F20 key
		static F21 					:= 'vk84' 		; F21 key
		static F22 					:= 'vk85' 		; F22 key
		static F23 					:= 'vk86' 		; F23 key
		static F24 					:= 'vk87' 		; F24 key
		static NUMLOCK 				:= 'vk90' 		; NUM LOCK key
		static SCROLL 				:= 'vk91' 		; SCROLL LOCK key
		static LSHIFT 				:= 'vkA0' 		; Left SHIFT key
		static RSHIFT 				:= 'vkA1' 		; Right SHIFT key
		static LCONTROL 			:= 'vkA2' 		; Left CONTROL key
		static RCONTROL 			:= 'vkA3' 		; Right CONTROL key
		static LMENU 				:= 'vkA4' 		; Left MENU key
		static RMENU 				:= 'vkA5' 		; Right MENU key
		static BROWSER_BACK 		:= 'vkA6' 		; Browser Back key
		static BROWSER_FORWARD 		:= 'vkA7' 		; Browser Forward key
		static BROWSER_REFRESH 		:= 'vkA8' 		; Browser Refresh key
		static BROWSER_STOP 		:= 'vkA9' 		; Browser Stop key
		static BROWSER_SEARCH 		:= 'vkAA' 		; Browser Search key
		static BROWSER_FAVORITES 	:= 'vkAB' 		; Browser Favorites key
		static BROWSER_HOME 		:= 'vkAC' 		; Browser Start and Home key
		static VOLUME_MUTE 			:= 'vkAD' 		; Volume Mute key
		static VOLUME_DOWN 			:= 'vkAE' 		; Volume Down key
		static VOLUME_UP 			:= 'vkAF' 		; Volume Up key
		static MEDIA_NEXT_TRACK 	:= 'vkB0' 		; Next Track key
		static MEDIA_PREV_TRACK 	:= 'vkB1' 		; Previous Track key
		static MEDIA_STOP 			:= 'vkB2' 		; Stop Media key
		static MEDIA_PLAY_PAUSE 	:= 'vkB3' 		; Play/Pause Media key
		static LAUNCH_MAIL 			:= 'vkB4' 		; Start Mail key
		static LAUNCH_MEDIA_SELECT 	:= 'vkB5' 		; Select Media key
		static LAUNCH_APP1 			:= 'vkB6' 		; Start Application 1 key
		static LAUNCH_APP2 			:= 'vkB7' 		; Start Application 2 key
		static OEM_1 				:= 'vkBA' 		; Used for miscellaneous characters; US standard keyboard: ';:' key
		static OEM_PLUS     		:= 'vkBB' 		; For any country/region, the '+' key
		static OEM_EQUAL    		:= 'vkBB' 		; For any country/region, the '=' key
		static OEM_COMMA    		:= 'vkBC' 		; For any country/region, the ',' key
		static OEM_MINUS    		:= 'vkBD' 		; For any country/region, the '-' key
		static OEM_PERIOD   		:= 'vkBE' 		; For any country/region, the '.' key
		static OEM_2 				:= 'vkBF' 		; Used for miscellaneous characters; US keyboard: '/?' key
		static OEM_3 				:= 'vkC0' 		; Used for miscellaneous characters; US keyboard: '`~' key
		static OEM_4 				:= 'vkDB' 		; Used for miscellaneous characters; US keyboard: '[{' key
		static OEM_5 				:= 'vkDC' 		; Used for miscellaneous characters; US keyboard: '\|' key
		static OEM_6 				:= 'vkDD' 		; Used for miscellaneous characters; US keyboard: ']}' key
		static OEM_7 				:= 'vkDE' 		; Used for miscellaneous characters; US keyboard: 'single/double quote' key
		static OEM_8 				:= 'vkDF' 		; Used for miscellaneous characters
		static OEM_102 				:= 'vkE2' 		; Either angle bracket or backslash on RT 102-key keyboard
		static PROCESSKEY 			:= 'vkE5' 		; IME PROCESS key
		static PACKET 				:= 'vkE7' 		; Unicode character as keystrokes
		static ATTN 				:= 'vkF6' 		; Attn key
		static CRSEL 				:= 'vkF7' 		; CrSel key
		static EXSEL 				:= 'vkF8' 		; ExSel key
		static EREOF 				:= 'vkF9' 		; Erase EOF key
		static PLAY 				:= 'vkFA' 		; Play key
		static ZOOM 				:= 'vkFB' 		; Zoom key
		static NONAME 				:= 'vkFC' 		; Reserved
		static PA1 					:= 'vkFD' 		; PA1 key
		static OEM_CLEAR 			:= 'vkFE' 		; Clear key
		;@endregion Virtual Key Constants
		; ---------------------------------------
		; ---------------------------------------
		; ---------------------------------------
	}
	;@endregion vk
	; ---------------------------------------
	; ---------------------------------------
	; ---------------------------------------
	;@region Specialized Hotkey Classes
	; ---------------------------------------
	; ---------------------------------------
	; ---------------------------------------
	/**
	 * @class hotkeySC
	 * @description Hotkey combinations using scan codes
	 */
	; ---------------------------------------
	; ---------------------------------------
	; ---------------------------------------
	Class hotkeySC extends keys {
		static Find 	:= '^' this.sc.f
		static Search 	:= this.sc.f5
		static Replace 	:= '^' this.sc.h
	}
	; ---------------------------------------
	; ---------------------------------------
	; ---------------------------------------
	/**
	 * @class hotkeyVK
	 * @description Hotkey combinations using virtual key codes
	 */
	Class hotkeyVK extends keys {
		static Find 	:= '^' this.vk.KEY_F
		static Search 	:= this.vk.F5
		static Replace 	:= '^vk48'
	}
	;@endregion Specialized Hotkey Classes

	;@region Key Format Detection Methods
	/**
	 * @method isSCFormat
	 * @description Check if a key is in scan code format
	 * @param {String} key - Key to check
	 * @returns {Boolean} True if key is in scan code format
	 */
	static isSCFormat(key) {
		return RegExMatch(key, "i)^\{sc\w+\}$")
	}

	/**
	 * @method isVKFormat
	 * @description Check if a key is in virtual key format
	 * @param {String} key - Key to check
	 * @returns {Boolean} True if key is in virtual key format
	 */
	static isVKFormat(key) {
		return RegExMatch(key, 'i)^(\{vk[\w\d]+\}|[+!^#]|\{.+\})+$')
	}

	/**
	 * @method isVKSCFormat
	 * @description Check if a key is in combined VK+SC format
	 * @param {String} key - Key to check
	 * @returns {Boolean} True if key is in VK+SC format
	 */
	static isVKSCFormat(key) {
		return RegExMatch(key, "i)^\{VK_\w+ sc\w+\}$")
	}
	;@endregion Key Format Detection Methods

	;@region Key Parsing Method
	/**
	 * @method parseKeys
	 * @description Parse a key string into components
	 * @param {String} keys - Key string to parse
	 * @returns {Array} Array of key components
	 */
	static parseKeys(keys) {
		keyArray := []
		tempKey := ''
		inBraces := false

		Loop Parse, keys {
			if (A_LoopField = '{') {
				if (tempKey) {
					keyArray.Push(tempKey)
					tempKey := ''
				}
				inBraces := true
				tempKey .= A_LoopField
			} else if (A_LoopField = '}') {
				tempKey .= A_LoopField
				inBraces := false
				keyArray.Push(tempKey)
				tempKey := ''
			} else if (inBraces) {
				tempKey .= A_LoopField
			} else if (A_LoopField ~= '[+!^#]') {
				if (tempKey) {
					keyArray.Push(tempKey)
					tempKey := ''
				}
				keyArray.Push(A_LoopField)
			} else {
				tempKey .= A_LoopField
			}
		}

		if (tempKey) {
			keyArray.Push(tempKey)
		}

		return keyArray
	}
	;@endregion Key Parsing Method

	;@region Key Translation Methods
	/**
	 * @method translateToVK
	 * @description Convert string key representation to Virtual Key format
	 * @param {String} keys - Keys to convert to VK format
	 * @returns {String} Keys in VK format
	 */
	static translateToVK(keys := '') {
		; Special keys mapping
		static specialKeys := Map(
			'Space', 'vk20',
			'Enter', 'vkD',
			'Tab', 'vk9',
			'Esc', 'vk1B',
			'Escape', 'vk1B',
			'Backspace', 'vk8',
			'BS', 'vk8',
			'Home', 'vk24',
			'End', 'vk23',
			'PgUp', 'vk21',
			'PgDn', 'vk22',
			'Del', 'vk2E',
			'Delete', 'vk2E',
			'Ins', 'vk2D',
			'Insert', 'vk2D',
			'Up', 'vk26',
			'Down', 'vk28',
			'Left', 'vk25',
			'Right', 'vk27',
			'PrintScreen', 'vk2C'
		)

		; Return early if already in VK format
		if (this.isVKFormat(keys)) {
			return keys
		}

		vkString := ''
		keyArray := this.parseKeys(keys)

		for keyName in keyArray {
			if (keyName ~= '[+!^#]') {
				; Modifiers (Shift, Alt, Ctrl, Win)
				vkString .= keyName
			} else if (SubStr(keyName, 1, 1) = '{' && SubStr(keyName, -1) = '}') {
				; Handle braced keys like {Home}, {F1}, etc.
				innerKey := SubStr(keyName, 2, StrLen(keyName) - 2)

				; Check for up/down suffix
				if (RegExMatch(innerKey, "^(.+)\s+(up|down)$", &match)) {
					suffix := " " match[2]
					innerKey := match[1]
				} else {
					suffix := ""
				}

				if (specialKeys.Has(innerKey)) {
					vkString .= '{' . specialKeys[innerKey] . suffix . '}'
				} else if (RegExMatch(innerKey, "^F(\d+)$", &match)) {
					; Function keys F1-F24
					fNum := Integer(match[1])
					if (fNum >= 1 && fNum <= 24) {
						vkString .= '{vk' . Format('{:X}', 111 + fNum) . suffix . '}'
					} else {
						vkString .= keyName  ; Keep original if invalid F-key
					}
				} else if (ObjHasOwnProp(this.vk, innerKey)) {
					vkString .= '{' . this.vk.%innerKey% . suffix . '}'
				} else {
					; Try to convert single character to VK code
					if (StrLen(innerKey) = 1) {
						vkString .= '{vk' . Format('{:X}', Ord(StrUpper(innerKey))) . suffix . '}'
					} else {
						vkString .= keyName  ; Keep as is if not recognized
					}
				}
			} else if (specialKeys.Has(keyName)) {
				; Handle special keys without braces
				vkString .= specialKeys[keyName]
			} else if (RegExMatch(keyName, "^F(\d+)$", &match)) {
				; Function keys F1-F24 without braces
				fNum := Integer(match[1])
				if (fNum >= 1 && fNum <= 24) {
					vkString .= 'vk' . Format('{:X}', 111 + fNum)
				} else {
					vkString .= keyName
				}
			} else if (ObjHasOwnProp(this.vk, "KEY_" . StrUpper(keyName))) {
				; Handle letter keys using the vk class
				vkString .= this.vk.%"KEY_" . StrUpper(keyName)%
			} else if (StrLen(keyName) = 1) {
				; Single characters
				vkString .= 'vk' . Format('{:X}', Ord(StrUpper(keyName)))
			} else {
				vkString .= keyName  ; Keep as is if not recognized
			}
		}
		return vkString
	}

	/**
	 * @method translateToSC
	 * @description Convert keys to Scan Code format
	 * @param {String} keys - Keys to convert
	 * @returns {String} Keys in Scan Code format
	 */
	static translateToSC(keys) {
		if (this.isSCFormat(keys)){
			return keys
		}

		scString := ""
		keyArray := StrSplit(keys, "+")
		for keyName in keyArray {
			if (this.isSCFormat(keyName))
				scString .= keyName
			else if (ObjHasOwnProp(this.sc, keyName))
				scString .= "{" . this.sc.%keyName% . "}"
			else
				scString .= keyName  ; Fallback to original key name if not found
		}
		return scString
	}

	/**
	 * @method translateToVKSC
	 * @description Convert keys to combined VK+SC format
	 * @param {String} keys - Keys to convert
	 * @returns {String} Keys in combined VK+SC format
	 */
	static translateToVKSC(keys) {
		if (this.isVKSCFormat(keys))
			return keys

		vkscString := ""
		keyArray := StrSplit(keys, "+")
		for keyName in keyArray {
			if (this.isVKSCFormat(keyName))
				vkscString .= keyName
			else if (ObjHasOwnProp(this.vk, keyName) && ObjHasOwnProp(this.sc, keyName))
				vkscString .= "{VK " . Format("0x{:X}", this.vk.%keyName%) this.sc.%keyName% . "}"
			else
				vkscString .= keyName  ; Fallback to original key name if not found
		}
		return vkscString
	}
	;@endregion Key Translation Methods

	;@region Code Translation Methods
	/**
	 * @method translateToVKCodes
	 * @description Convert keys to Virtual Key numeric codes
	 * @param {String} keys - Keys to convert
	 * @returns {Array} Array of VK numeric codes
	 */
	static translateToVKCodes(keys) {
		vkCodes := []
		keyArray := StrSplit(keys, "+")
		for keyName in keyArray {
			if (RegExMatch(keyName, "i)^VK_(\w+)$", &match))
				vkCodes.SafePush(this.vk.%match[1]%)
			else if (ObjHasOwnProp(this.vk, keyName))
				vkCodes.SafePush(this.vk.%keyName%)
			else if (RegExMatch(keyName, "i)^0x[\da-f]+$"))
				vkCodes.SafePush(Integer(keyName))
		}
		return vkCodes
	}

	/**
	 * @method translateToSCCodes
	 * @description Convert keys to Scan Code numeric codes
	 * @param {String} keys - Keys to convert
	 * @returns {Array} Array of SC numeric codes
	 */
	static translateToSCCodes(keys) {
		scCodes := []
		keyArray := StrSplit(keys, "+& ")
		for keyName in keyArray {
			if (RegExMatch(keyName, "i)^sc(\w+)$", &match))
				scCodes.SafePush(Integer("0x" . match[1]))
			else if (ObjHasOwnProp(this.sc, keyName))
				scCodes.SafePush(Integer("0x" . SubStr(this.sc.%keyName%, 3)))
			else if (RegExMatch(keyName, "i)^0x[\da-f]+$"))
				scCodes.SafePush(Integer(keyName))
		}
		return scCodes
	}

	/**
	 * @method translateToVKSCCodes
	 * @description Convert keys to paired VK+SC numeric codes
	 * @param {String} keys - Keys to convert
	 * @returns {Map} Map of VK codes to SC codes
	 */
	static translateToVKSCCodes(keys) {
		vkscCodes := Map()
		keyArray := StrSplit(keys, "+& ")
		for keyName in keyArray {
			if (RegExMatch(keyName, "i)^VK_(\w+)$", &matchVK) && RegExMatch(keyName, "i)^sc(\w+)$", &matchSC))
				vkscCodes[this.vk.%matchVK[1]%] := Integer("0x" . matchSC[1])
			else if (ObjHasOwnProp(this.vk, keyName) && ObjHasOwnProp(this.sc, keyName))
				vkscCodes[this.vk.%keyName%] := Integer("0x" . SubStr(this.sc.%keyName%, 3))
			else if (RegExMatch(keyName, "i)^0x[\da-f]+$"))
				vkscCodes[Integer(keyName)] := 0  ; Set SC to 0 if only VK is provided
		}
		return vkscCodes
	}
	;@endregion Code Translation Methods

	;@region Send Methods
	/**
	 * @method Send
	 * @description Send keys using virtual key codes
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static Send(keys) => this.SendVK(keys)

	/**
	 * @method SendVK
	 * @description Send keys using virtual key format
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static SendVK(keys) {
		vkString := this.translateToVK(keys)
		Send(vkString)
	}

	/**
	 * @method cSend
	 * @description Send keys using the clipboard
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static cSend(keys) => this.ClipSendVK(keys)

	/**
	 * @method ClipSendVK
	 * @description Send keys using the clipboard and virtual key format
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static ClipSendVK(keys) {
		vkString := this.translateToVK(keys)
		Clip.Send(vkString)
	}

	/**
	 * @method sSend
	 * @description Send keys using event mode
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static sSend(keys) {
		DetectHiddenText(1)
		DetectHiddenWindows(1)
		SendMode('Event')
		vkString := this.translateToVK(keys)
		Send(vkString)
	}

	/**
	 * @method ControlSendVK
	 * @description Send virtual key codes to a specific control
	 * @param {String} keys - Keys to send
	 * @param {String} control - Target control (default: focused control)
	 * @param {String} title - Target window title (default: active window)
	 * @returns {Void}
	 */
	static ControlSendVK(keys, control:=ControlGetFocus('A'), title:='A') {
		vkString := this.translateToVK(keys)
		ControlSend(vkString, control, title)
	}

	/**
	 * @method SendSC
	 * @description Send keys using scan code format
	 * @param {String} keys - Keys to send
	 * @returns {String} The scan code string that was sent
	 */
	static SendSC(keys) {
		scString := this.translateToSC(keys)
		Send(scString)
		return scString
	}

	/**
	 * @method SendVKSC
	 * @description Send keys using combined virtual key and scan code format
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static SendVKSC(keys) {
		vkscString := this.translateToVKSC(keys)
		Send(vkscString)
	}
	;@endregion Send Methods

	;@region DLL-Based Send Methods
	/**
	 * @method SendVKDll
	 * @description Send virtual keys using direct DLL calls
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static SendVKDll(keys) {
		vkCodes := this.translateToVKCodes(keys)
		for vkCode in vkCodes {
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", 0, "UInt", 0, "Ptr", 0)
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", 0, "UInt", 2, "Ptr", 0)
		}
	}

	/**
	 * @method SendSCDll
	 * @description Send scan codes using direct DLL calls
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static SendSCDll(keys) {
		scCodes := this.translateToSCCodes(keys)
		for scCode in scCodes {
			DllCall("user32.dll\keybd_event", "UChar", 0, "UChar", scCode, "UInt", 8, "Ptr", 0)
			DllCall("user32.dll\keybd_event", "UChar", 0, "UChar", scCode, "UInt", 10, "Ptr", 0)
		}
	}

	/**
	 * @method SendVKSCDll
	 * @description Send combined VK+SC codes using direct DLL calls
	 * @param {String} keys - Keys to send
	 * @returns {Void}
	 */
	static SendVKSCDll(keys) {
		vkscCodes := this.translateToVKSCCodes(keys)
		for vkCode, scCode in vkscCodes {
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", scCode, "UInt", 8, "Ptr", 0)
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", scCode, "UInt", 10, "Ptr", 0)
		}
	}
	;@endregion DLL-Based Send Methods

	;@region Shorthand Methods
	/**
	 * @method SCConvert
	 * @description Convert keys to Scan Code (shorthand)
	 * @param {String} keys - Keys to convert
	 * @returns {String} Keys in Scan Code format
	 */
	static SCConvert(keys) => this.translateToSC(keys)
	static xSC(keys) => this.translateToSC(keys)
	static SCx(keys) => this.translateToSC(keys)
	;@endregion Shorthand Methods

	static ctrl          := '{' this.sc.ctrl '}'
	static control       := '{' this.sc.ctrl '}'
	static controldown   := '{' this.sc.ctrl ' down}'
	static ctrldown      := '{' this.sc.ctrl ' down}'
	static controlup     := '{' this.sc.ctrl ' up}'
	static ctrlup        := '{' this.sc.ctrl ' up}'
	static lctrl         := '{' this.sc.lctrl '}'
	static lctrldown     := '{' this.sc.lctrl ' down}'
	static lctrlup       := '{' this.sc.lctrl ' up}'
	static rctrl         := '{' this.sc.rctrl '}'
	static rctrldown     := '{' this.sc.rctrl ' down}'
	static rctrlup       := '{' this.sc.rctrl ' up}'

	static shift         := '{' this.sc.shift '}'
	static shiftdown     := '{' this.sc.shift ' down}'
	static shiftup       := '{' this.sc.shift ' up}'
	static lshift        := '{' this.sc.lshift '}'
	static lshiftdown    := '{' this.sc.lshift ' down}'
	static lshiftup      := '{' this.sc.lshift ' up}'
	static rshift        := '{' this.sc.rshift '}'
	static rshiftdown    := '{' this.sc.rshift ' down}'
	static rshiftup      := '{' this.sc.rshift ' up}'

	static alt           := '{' this.sc.alt '}'
	static altup         := '{' this.sc.alt ' up}'
	static altdown       := '{' this.sc.alt ' down}'
	static lalt          := '{' this.sc.lalt '}'
	static laltup        := '{' this.sc.lalt ' up}'
	static laltdown      := '{' this.sc.lalt ' down}'
	static ralt          := '{' this.sc.ralt '}'
	static raltup        := '{' this.sc.ralt ' up}'
	static raltdown      := '{' this.sc.ralt ' down}'

	static win           := '{' this.sc.win '}'
	static winup         := '{' this.sc.win ' up}'
	static windown       := '{' this.sc.win ' down}'
	static lwin          := '{' this.sc.lwin '}'
	static lwinup        := '{' this.sc.lwin ' up}'
	static lwindown      := '{' this.sc.lwin ' down}'
	static rwin          := '{' this.sc.rwin '}'
	static rwinup        := '{' this.sc.rwin ' up}'
	static rwindown      := '{' this.sc.rwin ' down}'

	; Define individual key properties for all keys in sc class
	static esc 			:= '{' this.sc.esc '}'
	static escup 		:= '{' this.sc.esc ' up}'
	static escdown 		:= '{' this.sc.esc ' down}'

	static _1 			:= '{' this.sc._1 '}'
	static 1up 			:= '{' this.sc._1 ' up}'
	static 1down 		:= '{' this.sc._1 ' down}'

	static _2 			:= '{' this.sc._2 '}'
	static 2up 			:= '{' this.sc._2 ' up}'
	static 2down 		:= '{' this.sc._2 ' down}'

	static _3 			:= '{' this.sc._3 '}'
	static 3up 			:= '{' this.sc._3 ' up}'
	static 3down 		:= '{' this.sc._3 ' down}'

	static _4 			:= '{' this.sc._4 '}'
	static 4up 			:= '{' this.sc._4 ' up}'
	static 4down 		:= '{' this.sc._4 ' down}'

	static _5 			:= '{' this.sc._5 '}'
	static 5up 			:= '{' this.sc._5 ' up}'
	static 5down 		:= '{' this.sc._5 ' down}'

	static _6 			:= '{' this.sc._6 '}'
	static _6up 		:= '{' this.sc._6 ' up}'
	static _6down 		:= '{' this.sc._6 ' down}'

	static _7 			:= '{' this.sc._7 '}'
	static _7up 		:= '{' this.sc._7 ' up}'
	static _7down 		:= '{' this.sc._7 ' down}'

	static _8 			:= '{' this.sc._8 '}'
	static _8up 		:= '{' this.sc._8 ' up}'
	static _8down 		:= '{' this.sc._8 ' down}'

	static _9 			:= '{' this.sc._9 '}'
	static _9up 		:= '{' this.sc._9 ' up}'
	static _9down 		:= '{' this.sc._9 ' down}'

	static _0 			:= '{' this.sc._0 '}'
	static _0up 		:= '{' this.sc._0 ' up}'
	static _0down 		:= '{' this.sc._0 ' down}'

	static minus 		:= '{' this.sc.minus '}'
	static minusup 		:= '{' this.sc.minus ' up}'
	static minusdown 	:= '{' this.sc.minus ' down}'

	static equal 		:= '{' this.sc.equal '}'
	static equalup 		:= '{' this.sc.equal ' up}'
	static equaldown 	:= '{' this.sc.equal ' down}'

	static backspace 	:= '{' this.sc.backspace '}'
	static backspaceup 	:= '{' this.sc.backspace ' up}'
	static backspacedown:= '{' this.sc.backspace ' down}'

	static tab 			:= '{' this.sc.tab '}'
	static tabup 		:= '{' this.sc.tab ' up}'
	static tabdown 		:= '{' this.sc.tab ' down}'

	static q 			:= '{' this.sc.q '}'
	static qup 			:= '{' this.sc.q ' up}'
	static qdown 		:= '{' this.sc.q ' down}'

	static w 			:= '{' this.sc.w '}'
	static wup 			:= '{' this.sc.w ' up}'
	static wdown 		:= '{' this.sc.w ' down}'

	static e 			:= '{' this.sc.e '}'
	static eup := '{' this.sc.e ' up}'
	static edown := '{' this.sc.e ' down}'

	static r 			:= '{' this.sc.r '}'
	static rup := '{' this.sc.r ' up}'
	static rdown := '{' this.sc.r ' down}'

	static t 			:= '{' this.sc.t '}'
	static tup := '{' this.sc.t ' up}'
	static tdown := '{' this.sc.t ' down}'

	static y 			:= '{' this.sc.y '}'
	static yup := '{' this.sc.y ' up}'
	static ydown := '{' this.sc.y ' down}'

	static u := '{' this.sc.u '}'
	static uup := '{' this.sc.u ' up}'
	static udown := '{' this.sc.u ' down}'

	static i := '{' this.sc.i '}'
	static iup := '{' this.sc.i ' up}'
	static idown := '{' this.sc.i ' down}'

	static o := '{' this.sc.o '}'
	static oup := '{' this.sc.o ' up}'
	static odown := '{' this.sc.o ' down}'

	static p := '{' this.sc.p '}'
	static pup := '{' this.sc.p ' up}'
	static pdown := '{' this.sc.p ' down}'

	static lbracket := '{' this.sc.lbracket '}'
	static lbracketup := '{' this.sc.lbracket ' up}'
	static lbracketdown := '{' this.sc.lbracket ' down}'

	static rbracket := '{' this.sc.rbracket '}'
	static rbracketup := '{' this.sc.rbracket ' up}'
	static rbracketdown := '{' this.sc.rbracket ' down}'

	static enter := '{' this.sc.enter '}'
	static enterup := '{' this.sc.enter ' up}'
	static enterdown := '{' this.sc.enter ' down}'

	static a := '{' this.sc.a '}'
	static aup := '{' this.sc.a ' up}'
	static adown := '{' this.sc.a ' down}'

	static s := '{' this.sc.s '}'
	static sup := '{' this.sc.s ' up}'
	static sdown := '{' this.sc.s ' down}'

	static d := '{' this.sc.d '}'
	static dup := '{' this.sc.d ' up}'
	static ddown := '{' this.sc.d ' down}'

	static f := '{' this.sc.f '}'
	static fup := '{' this.sc.f ' up}'
	static fdown := '{' this.sc.f ' down}'

	static g := '{' this.sc.g '}'
	static gup := '{' this.sc.g ' up}'
	static gdown := '{' this.sc.g ' down}'

	static h := '{' this.sc.h '}'
	static hup := '{' this.sc.h ' up}'
	static hdown := '{' this.sc.h ' down}'

	static j := '{' this.sc.j '}'
	static jup := '{' this.sc.j ' up}'
	static jdown := '{' this.sc.j ' down}'

	static k := '{' this.sc.k '}'
	static kup := '{' this.sc.k ' up}'
	static kdown := '{' this.sc.k ' down}'

	static l := '{' this.sc.l '}'
	static lup := '{' this.sc.l ' up}'
	static ldown := '{' this.sc.l ' down}'

	static semicolon := '{' this.sc.semicolon '}'
	static semicolonup := '{' this.sc.semicolon ' up}'
	static semicolondown := '{' this.sc.semicolon ' down}'

	static quote := '{' this.sc.quote '}'
	static quoteup := '{' this.sc.quote ' up}'
	static quotedown := '{' this.sc.quote ' down}'

	static backtick := '{' this.sc.backtick '}'
	static backtickup := '{' this.sc.backtick ' up}'
	static backtickdown := '{' this.sc.backtick ' down}'

	static backslash := '{' this.sc.backslash '}'
	static backslashup := '{' this.sc.backslash ' up}'
	static backslashdown := '{' this.sc.backslash ' down}'

	static z := '{' this.sc.z '}'
	static zup := '{' this.sc.z ' up}'
	static zdown := '{' this.sc.z ' down}'

	static x := '{' this.sc.x '}'
	static xup := '{' this.sc.x ' up}'
	static xdown := '{' this.sc.x ' down}'

	static c := '{' this.sc.c '}'
	static cup := '{' this.sc.c ' up}'
	static cdown := '{' this.sc.c ' down}'

	static v := '{' this.sc.v '}'
	static vup := '{' this.sc.v ' up}'
	static vdown := '{' this.sc.v ' down}'

	static b := '{' this.sc.b '}'
	static bup := '{' this.sc.b ' up}'
	static bdown := '{' this.sc.b ' down}'

	static n := '{' this.sc.n '}'
	static nup := '{' this.sc.n ' up}'
	static ndown := '{' this.sc.n ' down}'

	static m := '{' this.sc.m '}'
	static mup := '{' this.sc.m ' up}'
	static mdown := '{' this.sc.m ' down}'

	static comma := '{' this.sc.comma '}'
	static commaup := '{' this.sc.comma ' up}'
	static commadown := '{' this.sc.comma ' down}'

	static period := '{' this.sc.period '}'
	static periodup := '{' this.sc.period ' up}'
	static perioddown := '{' this.sc.period ' down}'

	static slash := '{' this.sc.slash '}'
	static slashup := '{' this.sc.slash ' up}'
	static slashdown := '{' this.sc.slash ' down}'

	static numpadMult := '{' this.sc.numpadMult '}'
	static numpadMultup := '{' this.sc.numpadMult ' up}'
	static numpadMultdown := '{' this.sc.numpadMult ' down}'

	static space := '{' this.sc.space '}'
	static spaceup := '{' this.sc.space ' up}'
	static spacedown := '{' this.sc.space ' down}'

	static capslock := '{' this.sc.capslock '}'
	static capslockup := '{' this.sc.capslock ' up}'
	static capslockdown := '{' this.sc.capslock ' down}'

	static f1 := '{' this.sc.f1 '}'
	static f1up := '{' this.sc.f1 ' up}'
	static f1down := '{' this.sc.f1 ' down}'

	static f2 := '{' this.sc.f2 '}'
	static f2up := '{' this.sc.f2 ' up}'
	static f2down := '{' this.sc.f2 ' down}'

	static f3 := '{' this.sc.f3 '}'
	static f3up := '{' this.sc.f3 ' up}'
	static f3down := '{' this.sc.f3 ' down}'

	static f4 := '{' this.sc.f4 '}'
	static f4up := '{' this.sc.f4 ' up}'
	static f4down := '{' this.sc.f4 ' down}'

	static f5 := '{' this.sc.f5 '}'
	static f5up := '{' this.sc.f5 ' up}'
	static f5down := '{' this.sc.f5 ' down}'

	static f6 := '{' this.sc.f6 '}'
	static f6up := '{' this.sc.f6 ' up}'
	static f6down := '{' this.sc.f6 ' down}'

	static f7 := '{' this.sc.f7 '}'
	static f7up := '{' this.sc.f7 ' up}'
	static f7down := '{' this.sc.f7 ' down}'

	static f8 := '{' this.sc.f8 '}'
	static f8up := '{' this.sc.f8 ' up}'
	static f8down := '{' this.sc.f8 ' down}'

	static f9 := '{' this.sc.f9 '}'
	static f9up := '{' this.sc.f9 ' up}'
	static f9down := '{' this.sc.f9 ' down}'

	static f10 := '{' this.sc.f10 '}'
	static f10up := '{' this.sc.f10 ' up}'
	static f10down := '{' this.sc.f10 ' down}'

	static numlock := '{' this.sc.numlock '}'
	static numlockup := '{' this.sc.numlock ' up}'
	static numlockdown := '{' this.sc.numlock ' down}'

	static scrolllock := '{' this.sc.scrolllock '}'
	static scrolllockup := '{' this.sc.scrolllock ' up}'
	static scrolllockdown := '{' this.sc.scrolllock ' down}'

	static numpad7 := '{' this.sc.numpad7 '}'
	static numpad7up := '{' this.sc.numpad7 ' up}'
	static numpad7down := '{' this.sc.numpad7 ' down}'

	static numpad8 := '{' this.sc.numpad8 '}'
	static numpad8up := '{' this.sc.numpad8 ' up}'
	static numpad8down := '{' this.sc.numpad8 ' down}'

	static numpad9 := '{' this.sc.numpad9 '}'
	static numpad9up := '{' this.sc.numpad9 ' up}'
	static numpad9down := '{' this.sc.numpad9 ' down}'

	static numpadMinus := '{' this.sc.numpadMinus '}'
	static numpadMinusup := '{' this.sc.numpadMinus ' up}'
	static numpadMinusdown := '{' this.sc.numpadMinus ' down}'

	static numpad4 := '{' this.sc.numpad4 '}'
	static numpad4up := '{' this.sc.numpad4 ' up}'
	static numpad4down := '{' this.sc.numpad4 ' down}'

	static numpad5 := '{' this.sc.numpad5 '}'
	static numpad5up := '{' this.sc.numpad5 ' up}'
	static numpad5down := '{' this.sc.numpad5 ' down}'

	static numpad6 := '{' this.sc.numpad6 '}'
	static numpad6up := '{' this.sc.numpad6 ' up}'
	static numpad6down := '{' this.sc.numpad6 ' down}'

	static numpadPlus := '{' this.sc.numpadPlus '}'
	static numpadPlusup := '{' this.sc.numpadPlus ' up}'
	static numpadPlusdown := '{' this.sc.numpadPlus ' down}'

	static numpad1 := '{' this.sc.numpad1 '}'
	static numpad1up := '{' this.sc.numpad1 ' up}'
	static numpad1down := '{' this.sc.numpad1 ' down}'

	static numpad2 := '{' this.sc.numpad2 '}'
	static numpad2up := '{' this.sc.numpad2 ' up}'
	static numpad2down := '{' this.sc.numpad2 ' down}'

	static numpad3 := '{' this.sc.numpad3 '}'
	static numpad3up := '{' this.sc.numpad3 ' up}'
	static numpad3down := '{' this.sc.numpad3 ' down}'

	static numpad0 := '{' this.sc.numpad0 '}'
	static numpad0up := '{' this.sc.numpad0 ' up}'
	static numpad0down := '{' this.sc.numpad0 ' down}'

	static numpadDot := '{' this.sc.numpadDot '}'
	static numpadDotup := '{' this.sc.numpadDot ' up}'
	static numpadDotdown := '{' this.sc.numpadDot ' down}'

	static f11 := '{' this.sc.f11 '}'
	static f11up := '{' this.sc.f11 ' up}'
	static f11down := '{' this.sc.f11 ' down}'

	static f12 := '{' this.sc.f12 '}'
	static f12up := '{' this.sc.f12 ' up}'
	static f12down := '{' this.sc.f12 ' down}'

	static numpadDiv := '{' this.sc.numpadDiv '}'
	static numpadDivup := '{' this.sc.numpadDiv ' up}'
	static numpadDivdown := '{' this.sc.numpadDiv ' down}'

	static printscreen := '{' this.sc.printscreen '}'
	static printscreenup := '{' this.sc.printscreen ' up}'
	static printscreendown := '{' this.sc.printscreen ' down}'

	static pause := '{' this.sc.pause '}'
	static pauseup := '{' this.sc.pause ' up}'
	static pausedown := '{' this.sc.pause ' down}'

	static home := '{' this.sc.home '}'
	static homeup := '{' this.sc.home ' up}'
	static homedown := '{' this.sc.home ' down}'

	static Up := '{' this.sc.scup '}'
	static Upup := '{' this.sc.scup ' up}'
	static Updown := '{' this.sc.scup ' down}'

	static pageup := '{' this.sc.pageup '}'
	static pageupup := '{' this.sc.pageup ' up}'
	static pageupdown := '{' this.sc.pageup ' down}'

	static left := '{' this.sc.left '}'
	static leftup := '{' this.sc.left ' up}'
	static leftdown := '{' this.sc.left ' down}'

	static right := '{' this.sc.right '}'
	static rightup := '{' this.sc.right ' up}'
	static rightdown := '{' this.sc.right ' down}'

	static end := '{' this.sc.end '}'
	static endup := '{' this.sc.end ' up}'
	static enddown := '{' this.sc.end ' down}'

	static scdown := '{' this.sc.scdown '}'
	static scdownup := '{' this.sc.scdown ' up}'
	static scdropdown := '{' this.sc.scdown ' down}'

	static pagedown := '{' this.sc.pagedown '}'
	static pagedownup := '{' this.sc.pagedown ' up}'
	static pagedowndown := '{' this.sc.pagedown ' down}'

	static insert := '{' this.sc.insert '}'
	static insertup := '{' this.sc.insert ' up}'
	static insertdown := '{' this.sc.insert ' down}'

	static delete := '{' this.sc.delete '}'
	static deleteup := '{' this.sc.delete ' up}'
	static deletedown := '{' this.sc.delete ' down}'

	static appskey := '{' this.sc.appskey '}'
	static appskeyup := '{' this.sc.appskey ' up}'
	static appskeydown := '{' this.sc.appskey ' down}'

	static menu := '{' this.sc.menu '}'
	static menuup := '{' this.sc.menu ' up}'
	static menudown := '{' this.sc.menu ' down}'

	; static hznsave := this.altdown this.f this.s this.altup
	static hznsave := '{alt down}{f}{s}{alt up}'
	static hznOpenRTF := this.ctrldown this.shiftdown this.c this.shiftup this.ctrlup

	static find := this.ctrldown this.f this.ctrlup
	static replace := this.ctrldown this.h this.ctrlup
	static bold := this.ctrldown this.b this.ctrlup
	static italics := this.ctrldown this.i this.ctrlup
	/** SC('^u') */
	static underline := this.ctrldown this.u this.ctrlup
	static strikethrough := this.ctrldown this.shiftdown this.s this.shiftup this.ctrlup
	static resetFormat := this.altdown this.n this.altup

	/**
	 * @property paste
	 * @param {sc1D} 	; Simulates {control} using scan codes
	 * @param {sc2F} 	; Simulates {v} using scan codes
	 */
	static paste := this.ctrldown this.v this.ctrlup
	/**
	 * @property shiftinsert
	 * @param {sc2A} 	; Simulates {shift} using scan codes
	 * @param {sc152} 	; Simulates {insert} using scan codes
	 */
	static shiftinsert := this.shiftdown this.insert this.shiftup
	static copy := this.ctrldown this.c this.ctrlup
	static cut := this.ctrldown this.x this.ctrlup
	static selectall := this.ctrldown this.a this.ctrlup
	static undo := this.ctrldown this.z this.ctrlup
	static redo := this.ctrldown this.y this.ctrlup
	static newfile := this.ctrldown this.n this.ctrlup
	static openfile := this.ctrldown this.o this.ctrlup
	static saveas := this.ctrldown this.shiftdown this.s this.shiftup this.ctrlup
	static print := this.ctrldown this.p this.ctrlup
	static close := this.ctrldown this.w this.ctrlup
	static quit := this.altdown this.f4 this.altup
	static selectLine := this.home this.shiftdown this.end this.shiftup
	static selectSeperator := this.shiftdown this.controldown this.leftdown this.leftup this.controlup this.shiftup
	static selectSeperator2 := this.shiftdown this.controldown this.leftdown this.leftup this.leftdown this.leftup this.controlup this.shiftup
	static moveupdown := this.selectLine this.cut this.delete
	static moveup := this.up this.enter this.Up
	static movedown := this.end this.enter
	static dupLine := this.selectLine this.copy
	static duplicateLine := this.selectLine this.copy

	; Navigation and window management
	static nextTab := this.ctrldown this.tab this.ctrlup
	static prevTab := this.ctrldown this.shiftdown this.tab this.shiftup this.ctrlup
	static nextWindow := this.altdown this.tab this.altup
	static prevWindow := this.altdown this.shiftdown this.tab this.shiftup this.altup
	static minimize := this.windown this.syntax.down this.winup
	static maximize := this.windown this.syntax.up this.winup
	static showDesktop := this.windown this.d this.winup
	static lockScreen := this.windown this.l this.winup

	; Text editing
	static lineStart 		 := this.home
	static lineEnd 			 := this.end
	static wordLeft 		 := this.ctrldown this.left this.ctrlup
	static wordRight 		 := this.ctrldown this.right this.ctrlup
	static selectwordLeft  	 := this.ctrldown this.shiftdown this.left  this.shiftup this.ctrlup
	static selectwordRight 	 := this.ctrldown this.shiftdown this.right this.shiftup this.ctrlup
	static deleteWord 		 := this.ctrldown this.delete this.ctrlup
	static deleteWordforward := this.ctrldown this.delete this.ctrlup
	static backspaceWord 	 := this.ctrldown this.backspace this.ctrlup
	static deleteWordback 	 := this.ctrldown this.backspace this.ctrlup

	; System commands
	static taskManager := this.ctrldown this.shiftdown this.esc this.shiftup this.ctrlup
	; static run := this.windown this.r this.winup
	static explorer := this.windown this.e this.winup

	class Run extends keys {
		static CommandPrompt := this.windown this.r this.winup
		static TaskManger := this.ctrldown this.shiftdown this.esc this.shiftup this.ctrlup
		static Explorer := this.windown this.e this.winup
	}

}
