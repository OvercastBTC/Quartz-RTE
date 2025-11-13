#Include <Converters\Number>
#Include <Extensions\.ui\CleanInputBox>
#Include <Extensions\.primitives\String>
#Include <Apps\Browser>
#Include <Extensions\.ui\Infos>

class InternetSearch extends CleanInputBox {

	__New(searchEngine) {
		super.__New()
		this.SelectedSearchEngine := this.AvailableSearchEngines[searchEngine]
	}

	static FeedQuery(input) {
		restOfLink := this.SanitizeQuery(input)

				; This part of the script uses a site specific DuckDuckGo search for AHK documentation.
                if (this.SelectedSearchEngine == this.AvailableSearchEngines['AHK-V2-Docs']) {
                        Browser.RunLink("https://duckduckgo.com/?q=site:autohotkey.com/boards%20v2%20" restOfLink)
                        Browser.RunLink(this.SelectedSearchEngine restOfLink)
                }

				; This part of the script opens and searches Microsoft 365 Copilot.
                Else If (this.SelectedSearchEngine == this.AvailableSearchEngines['M365Copilot']) {
                    ; Check to see if Copilot is already open.
					If WinExist("Copilot | Microsoft 365 Copilot") {
						WinActivate("Copilot | Microsoft 365 Copilot")
						Send(input)
						Sleep(50)
						Send('{Enter}')
					}
					
					; Opens Copilot if not already open.
					Else {
						Browser.RunLink(this.SelectedSearchEngine)
						WinWaitActive("Copilot | Microsoft 365 Copilot",,10)
						Send(input)
						Sleep(2000) ;TODO This sleep does not seem to be long enough. Need to investigate.
						Send('{Enter}')
					}
                }

                Else {
                    Browser.RunLink(this.SelectedSearchEngine restOfLink)
                }
	}

	static DynamicallyReselectEngine(input) {
		for key, value in this.SearchEngineNicknames {
			if input.RegExMatch("^" key "* ") {
				this.SelectedSearchEngine := value
				input := input[3, -1]
				break
			}

			;@Ahk2Exe-IgnoreBegin ; This allows script maintainer to set a default search engine different from the compiled script.
			else {
				this.SelectedSearchEngine := this.AvailableSearchEngines['Google'] ; sets default search to Google if no RegexMatch occurs.
			}
			;@AHK2Exe-IgnoreEnd
			
			; Sets a default search engine if no RegexMatch occurs for the compiled script.
			/*@AHK2Exe-Keep
			else {
				this.SelectedSearchEngine := this.AvailableSearchEngines['Google'] ; sets default search to Google if no RegexMatch occurs.
			}
			*/

		}
		return input
	}

	static TriggerSearch(input) {
		query := this.DynamicallyReselectEngine(input)
		this.FeedQuery(query)
	}

	static AvailableSearchEngines := Map(
		"Google",  "https://www.google.com/search?udm=14&q=",
		"Youtube", "https://www.youtube.com/results?search_query=",
		"DuckDuckGo",  "https://duckduckgo.com/?q=",
		"Bing-FMGlobal",  "https://www.bing.com/work/search?q=",
		"Wikipedia",  "https://en.wikipedia.org/w/index.php?title=Special:Search&search=",
        "AHK-V2-Docs",  "https://duckduckgo.com/?q=site:autohotkey.com/docs/v2/%20",
        "M365Copilot",  "https://m365.cloud.microsoft/chat?auth=2",
        )

	static SearchEngineNicknames := Map(
		"g",  this.AvailableSearchEngines["Google"],
		"y",  this.AvailableSearchEngines["Youtube"],
		"d", this.AvailableSearchEngines["DuckDuckGo"], 
		"f", this.AvailableSearchEngines["Bing-FMGlobal"],
		"w",  this.AvailableSearchEngines["Wikipedia"],
        "a",  this.AvailableSearchEngines["AHK-V2-Docs"],
        "c",  this.AvailableSearchEngines["M365Copilot"],
        )

	;Rename suggestion by @Micha-ohne-el, used to be ConvertToLink()
	static SanitizeQuery(query) {
		SpecialCharacters := '%$&+,/:;=?@ "<>#{}|\^~[]``'.Split()
		for key, value in SpecialCharacters {
			query := query.Replace(value, "%" NumberConverter.DecToHex(Ord(value), false))
		}
		return query
	}
}
