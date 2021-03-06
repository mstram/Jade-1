"Filed out from Dolphin Smalltalk 7"!

JadeWorkspace subclass: #JadeTranscript
	instanceVariableNames: 'allSessionsPresenter historyPresenter mySessionPresenter stoneInfoPresenter toolbarPresenter transcriptPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeTranscript guid: (GUID fromString: '{7d871bc4-1338-4ba1-af6a-c1edd936d683}')!
JadeTranscript comment: ''!
!JadeTranscript categoriesForClass!Unclassified! !
!JadeTranscript methodsFor!

autocompletion

	JadeAutocompletationConfigurationShell show.
!

browseMonticelloRepositories

	self jadeBrowseMonticello.
!

createComponents

	super createComponents.
	allSessionsPresenter	:= self add: AllSessionsPresenter		new name: 'All Sessions'.
	historyPresenter	:= self add: TextPresenter				new name: 'history'.
	mySessionPresenter	:= self add: MySessionPresenter			new name: 'My Session'.
	stoneInfoPresenter	:= self add: StoneInfoPresenter			new name: 'Stone'.
	toolbarPresenter	:= self add: JadeToolsToolBarPresenter	new name: 'Toolbar'.
	transcriptPresenter	:= self add: TranscriptPresenter			new name: 'Transcript'.
!

createSchematicWiring

	super createSchematicWiring.
	(self view viewNamed: 'cardContainer') when: #'currentCardChanged' send: #'currentCardChanged' to: self.
!

currentCardChanged

	| currentCard |
	currentCard := (self view viewNamed: 'cardContainer') currentCard.
	(currentCard isKindOf: TextEdit) 	ifTrue: [currentCard setFocus].
	(currentCard name = 'codePane')		ifTrue: [[(currentCard viewNamed: 'document') setFocus] postToInputQueue. ^self].
	(currentCard name = 'history')		ifTrue: [historyPresenter value isEmpty ifTrue: [historyPresenter value: (gciSession executeString: 'DbfHistory')]. ^self].
	(currentCard name = 'My Session')	ifTrue: [mySessionPresenter fillSessionInfo. ^self].
	(currentCard name = 'Stone')		ifTrue: [stoneInfoPresenter fillSessionInfo. ^self].!

describeErrorNumber

	| string result |
	(string := Prompter prompt: 'Enter GemStoneError number:') isNil ifTrue: [^self].
	(string allSatisfy: [:each | each isDigit]) ifFalse: [
		MessageBox warning: 'Invalid number!!'.
		^self.
	].
	result := gciSession 
		serverPerform: #'descriptionOfErrorNumber:'
		with: string asNumber.
	MessageBox 
		notify: result
		caption: 'GemStoneError ' , string.
!

disableNativeCode

	gciSession executeString: 'System configurationAt: #GemNativeCodeEnabled put: false'.
!

gciSession: aGciSession

	super gciSession: aGciSession.
	mySessionPresenter	gciSession: aGciSession.
	allSessionsPresenter	gciSession: aGciSession.
	stoneInfoPresenter	gciSession: aGciSession.
	toolbarPresenter	gciSession: aGciSession.
	transcriptPresenter	gciSession: aGciSession.
!

hasClassSideSelected
	^false!

inspectOop

	| string result |
	(string := Prompter prompt: 'Enter OOP Number:') isNil ifTrue: [^self].
	(string allSatisfy: [:each | each isDigit]) ifFalse: [
		MessageBox warning: 'Invalid number!!'.
		^self.
	].
	result := gciSession executeString: 'Object _objectForOop: ' , string.
	JadeInspector showOn: result session: gciSession.
!

methodsChanged24

| string result |
	
	result := gciSession executeString: '| result methods|
		result := MethodVersionHistory uniqueInstance methodsNewerThan: (DateTime now subtractDays: 1 ).
		methods := IdentitySet new.
		result do: [:e | e asCompiledMethod ifNotNil: [:m | methods add: m]].
		methods asArray'.
(JadeMethodListBrowser showOnSession: self gciSession) primaryPresenter
		browseMethods: result;
		yourself.
	"JadeInspector showOn: result session: gciSession."
!

methodsChangedDays

| string result |
	(string := Prompter prompt: 'Enter number of days:') isNil ifTrue: [^self].	
	result := gciSession executeString: '| result methods|
		result := MethodVersionHistory uniqueInstance methodsNewerThan: (DateTime now subtractDays: ' , string , ' ).
		methods := IdentitySet new.
		result do: [:e | e asCompiledMethod ifNotNil: [:m | methods add: m]].
		methods asArray'.
	(JadeMethodListBrowser showOnSession: self gciSession) primaryPresenter
		browseMethods: result;
		yourself.

!

onCloseRequested: boolValueHolder
 
	| answer |
	super onCloseRequested: boolValueHolder.
	boolValueHolder value ifFalse: [^self].
	gciSession isNil ifTrue: [^self].
	gciSession isValidSession ifFalse: [^self].
	gciSession logoutRequested ifFalse: [
		boolValueHolder value: false.
		^self.
	].
	answer := MessageBox new
		caption: 'Close Requested';
		confirmOrCancel: 'Commit current transaction?'.
	boolValueHolder value: (#(#yes #no) includes: answer).
	answer = #yes ifTrue: [gciSession commit].
	boolValueHolder value ifFalse: [^self].

	"We are going to close, so do some things first..."
	"self view hide."
	allSessionsPresenter aboutToClose.
	gciSession notNil ifTrue: [
		| temp |
		temp := gciSession.		"A logout will trigger closing all open windows, including this one."
		gciSession := nil.
		temp forceLogout.
	].
!

onViewOpened

	super onViewOpened.
	self view position: 95 @ 35.
	codePane view ensureVisible.!

queryCommand: query

	(#(#'turnAutoMigrateOff' #'turnAutoMigrateOn') includes: query commandSymbol) ifTrue: [
		query isEnabled: true.
		^true.
	].
	^super queryCommand: query.

!

resetCursor

	[Cursor current: nil] forkAt: Processor userBackgroundPriority.
!

sleepAndCommit

	[
		gciSession serverPerform: #'sleepAndCommit'.
	] on: GsSoftBreak , GsHardBreak do: [:ex | 
		ex terminateProcess.
	].
!

turnAutoMigrateOff

	gciSession executeString: 'MCPlatformSupport autoMigrate: false'.
!

turnAutoMigrateOn

	gciSession executeString: 'MCPlatformSupport autoMigrate: true'.
!

updateCaption

	self caption: (gciSession titleBarFor: 'Transcript').
! !
!JadeTranscript categoriesFor: #autocompletion!event handling!public! !
!JadeTranscript categoriesFor: #browseMonticelloRepositories!event handling!public! !
!JadeTranscript categoriesFor: #createComponents!public! !
!JadeTranscript categoriesFor: #createSchematicWiring!public! !
!JadeTranscript categoriesFor: #currentCardChanged!public! !
!JadeTranscript categoriesFor: #describeErrorNumber!event handling!public! !
!JadeTranscript categoriesFor: #disableNativeCode!event handling!public! !
!JadeTranscript categoriesFor: #gciSession:!private! !
!JadeTranscript categoriesFor: #hasClassSideSelected!public! !
!JadeTranscript categoriesFor: #inspectOop!event handling!public! !
!JadeTranscript categoriesFor: #methodsChanged24!event handling!public! !
!JadeTranscript categoriesFor: #methodsChangedDays!event handling!public! !
!JadeTranscript categoriesFor: #onCloseRequested:!event handling!public! !
!JadeTranscript categoriesFor: #onViewOpened!public!updating! !
!JadeTranscript categoriesFor: #queryCommand:!public!updating! !
!JadeTranscript categoriesFor: #resetCursor!event handling!public! !
!JadeTranscript categoriesFor: #sleepAndCommit!event handling!public! !
!JadeTranscript categoriesFor: #turnAutoMigrateOff!event handling!public! !
!JadeTranscript categoriesFor: #turnAutoMigrateOn!event handling!public! !
!JadeTranscript categoriesFor: #updateCaption!public! !

!JadeTranscript class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 0 0 8 #(13565952 65536) 416 0 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 801 551 0 0 0 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 0 416 34 2 8 1140850688 131073 608 0 0 0 7 0 0 0 608 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view 0 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 51 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 514 193 193 0 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 962 #fixedParentRight 1 962 #fixedParentTop 1 962 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 0 416 34 2 8 1140850688 131073 1040 0 466 496 0 7 0 0 0 1040 655878 ##(Smalltalk.CardLayout) 138 144 34 6 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 0 1040 34 2 8 1140850688 131073 1232 0 466 8 4278190080 0 5 0 0 0 1232 674 ##(Smalltalk.TranscriptPresenter) #resource_Default_view 0 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 1232 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 0 27 1186 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 0 1040 34 2 8 1140850688 131073 1520 0 0 0 5 0 0 0 1520 674 ##(Smalltalk.MySessionPresenter) #resource_Default_view 0 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 1520 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 0 27 1186 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 0 1040 34 2 8 1140850688 131073 1776 0 0 0 5 0 0 0 1776 674 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view 0 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 1776 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 0 27 1186 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 0 1040 34 2 8 1140916224 131073 2032 0 466 8 4278190080 0 5 0 0 0 2032 674 ##(Smalltalk.TranscriptPresenter) #resource_Default_view 0 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 2032 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 0 27 1186 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 0 1040 34 2 8 1143017796 1025 2320 0 466 8 4278190080 0 5 0 0 0 2320 0 8 4294903121 852486 ##(Smalltalk.NullConverter) 0 0 11 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 2320 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 8 #() 912 0 27 1186 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 0 1040 34 2 8 1140850688 131073 2640 0 0 0 7 0 0 0 2640 674 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view 0 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 2640 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 0 27 2640 170 192 34 12 2640 8 'Stone' 2032 8 'Transcript' 1776 8 'All Sessions' 1520 8 'My Session' 1232 8 'codePane' 2320 8 'history' 0 410 ##(Smalltalk.TabView) 34 23 0 1040 34 2 8 1140916736 1 2992 590662 2 ##(Smalltalk.ListModel) 138 144 34 6 2016 2304 ##(Smalltalk.Stone) 1504 1760 1216 0 1310726 ##(Smalltalk.IdentitySearchPolicy) 721158 ##(Smalltalk.SystemColor) 31 0 1 0 0 0 2992 0 8 4294903941 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) 0 0 0 0 0 #noIcons 706 138 144 34 3 770 #createAt:extent: 34 2 514 1 1 514 1169 633 2992 770 #basicSelectionsByIndex: 34 1 8 #(3) 2992 770 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2992 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 60 1 0 0] 8 #() 912 0 27 706 138 144 34 1 770 #createAt:extent: 34 2 514 1 51 514 1169 633 1040 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 85 1 0 0] 34 7 2032 2320 2640 1520 1776 1232 2992 912 0 27 930 976 1 992 1 1008 51 962 #fixedParentBottom 1 170 192 34 4 608 8 'Toolbar' 1040 8 'cardContainer' 0 461638 4 ##(Smalltalk.MenuBar) 0 true 34 4 265030 4 ##(Smalltalk.Menu) 0 true 34 9 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #fileNew 8 '&New Workspace' 9373 1 0 0 0 3826 1 3858 #fileOpen 8 '&Open Workspace...' 9375 1 0 0 0 3826 1 3858 #fileSave 8 '&Save' 9383 1 0 0 0 3826 1 3858 #fileSaveAs 8 'Save &As...' 1 1 0 0 0 3826 1 3858 #fileRevert 8 '&Revert' 1025 1 0 0 0 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3826 1 3858 #resetCursor 8 'Reset &Cursor' 1025 1 0 0 0 4098 4097 3826 1 3858 #exit 8 'E&xit Jade' 17639 1 0 0 0 8 '&File' 0 1 0 0 19043 0 0 3778 0 true 34 15 3826 1 3858 #undo 8 '&Undo' 9397 1 0 0 0 3826 1 3858 #redo 8 'R&edo' 9395 1 0 0 0 4098 4097 3826 1 3858 #editCut 8 'Cu&t' 9393 1 0 0 0 3826 1 3858 #editCopy 8 '&Copy' 9351 1 0 0 0 3826 1 3858 #editPaste 8 '&Paste' 9389 1 0 0 0 3826 1 3858 #editSelectAll 8 'Select &All' 9347 1 0 0 0 3826 1 3858 #editDelete 8 '&Delete' 1629 1 0 0 0 4098 4097 3826 1 3858 #editFind 8 '&Find...' 9357 1 0 0 0 3826 1 3858 #editFindNext 8 'Find &Next' 9359 1 0 0 0 3826 1 3858 #editReplace 8 '&Replace...' 9361 1 0 0 0 4098 4097 3826 1 3858 #addQuotesToSelection 8 'Add &Quotes' 1 1 0 0 0 3826 1 3858 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 0 0 0 8 '&Edit' 0 1 0 0 19069 0 0 3778 0 true 34 22 3826 1 3858 #sleepAndCommit 8 '&Sleep and Commit' 1 1 0 0 0 3826 1 3858 #abortTransaction 8 '&Abort Transaction' 1 1 0 0 0 3826 1 3858 #commitTransaction 8 '&Commit Transaction' 1 1 0 0 0 3826 1 3858 #disableNativeCode 8 'Disable Naitive Code' 1 1 0 0 0 4098 4097 3826 1 3858 #jadeInspect 8 '&Inspect' 9379 1 0 0 0 3826 1 3858 #jadeDisplay 8 '&Display' 9353 1 0 0 0 3826 1 3858 #jadeExecute 8 '&Execute' 9355 1 0 0 0 3826 1 3858 #fileIn 8 'Fi&le In' 1 1 0 0 0 4098 4097 3826 1 3858 #jadeBrowseClasses 8 '&Browse Classes' 9349 1 0 0 0 3826 1 3858 #browseMonticelloRepositories 8 'Browser &Monticello Repositories' 9371 1 0 0 0 3826 1 3858 #jadeBrowseObjectLog 8 'Browse &Object Log' 9369 1 0 0 0 3826 1 3858 #browseProcesses 8 'Browse &Processes' 9377 1 0 0 0 3826 1 3858 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 0 0 0 3826 1 3858 #autocompletion 8 'Configure Autocompletion' 1 1 0 0 0 4098 4097 3826 1 3858 #inspectOop 8 'Inspect Oop ...' 1 1 0 0 0 3826 1 3858 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 0 0 0 4098 4097 3826 1025 3858 #turnAutoMigrateOff 8 'Turn Auto Migrate Off' 1 1 0 0 0 3826 1025 3858 #turnAutoMigrateOn 8 'Turn Auto Migrate On' 1 1 0 0 0 8 '&Jade' 0 1 0 0 19107 0 0 3778 0 true 34 1 3826 1 3858 #aboutJade 8 '&About Jade' 1 1 0 0 0 8 '&Help' 0 1 0 0 19111 0 0 8 '' 0 1 0 0 0 0 0 0 0 0 1 263494 3 ##(Smalltalk.Icon) 0 true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' 0 6018 0 true 6064 8 'icons\GS16.ico' 0 0 0 1 0 0 706 138 144 34 3 770 #createAt:extent: 34 2 514 5119 21 514 1201 801 416 770 #text: 34 1 8 'Jade Session' 416 770 #updateMenuBar 896 416 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 9 0 0 10 0 0 0 87 12 0 0 154 1 0 0] 34 2 608 1040 912 0 27 )! !
!JadeTranscript class categoriesFor: #resource_Default_view!public!resources-views! !

