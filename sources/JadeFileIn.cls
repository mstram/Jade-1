"Filed out from Dolphin Smalltalk 7"!

Object subclass: #JadeFileIn
	instanceVariableNames: 'stream line words text category browser packageName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeFileIn guid: (GUID fromString: '{5eb74a05-1227-4d91-9750-01548085fa61}')!
JadeFileIn comment: ''!
!JadeFileIn categoriesForClass!Unclassified! !
!JadeFileIn methodsFor!

defineClass

	browser
		defineClass: text trimBlanks
		inPackageNamed: packageName.
!

defineClassMethod

	| className |
	className := ((line subStrings: $:) at: 2) subStrings first.
	browser
		defineClassMethod: self readUpToPercent
		inClassNamed: className
		inPackageNamed: packageName
		inCategory: category.
!

defineInstanceMethod

	browser
		defineMethod: self readUpToPercent
		inClassNamed: ((line subStrings: $:) at: 2) trimBlanks
		inPackageNamed: packageName
		inCategory: category.
!

doIt

	browser doIt: text.
!

fileInPath: aString forBrowser: aBrowser

	packageName := (aString subStrings: $\) last.
	stream := FileStream read: aString.
	[
		self
			fileInStream: stream 
			forBrowser: aBrowser.
	] ensure: [
		stream close.
	].
!

fileInStream: aStream forBrowser: aBrowser

	browser := aBrowser.
	browser fileInStart: packageName.
	[
		stream := aStream.
		self read.
	] ensure: [
		browser fileInEnd: packageName.
	].
!

fileInString: aString forBrowser: aBrowser

	(aString beginsWith: '<?xml version="1.0"?>') ifTrue: [
		self fileInXML: aString forBrowser: aBrowser.
		^self.
	].
	self
		fileInStream: (ReadStream on: aString) 
		forBrowser: aBrowser.

!

fileInXML: aString forBrowser: aBrowser

	| source |
	source := VWSourceFile fromString: aString.
	source removeSPort.
	source := source asTopazFileIn.
	(JadeWorkspace showOnSession: aBrowser gciSession)
		caption: 'Jade Workspace - GemStone File-In';
		fileIn: source;
		yourself.
!

isDefineClass

	^(words size > 5 and: [
		(words at: 2) = 'subclass:' and: [
		(words at: 4) = 'instVarNames:']]) or: [
	(words size > 5 and: [
		(words at: 2) = 'byteSubclass:' and: [
		(words at: 4) = 'classVars:']])].
!

isPostloadScript

	^words size > 3 and: [
		(words copyFrom: 1 to: 3) = #('"' 'postload' 'script')].
!

isPreloadScript

	^words size > 3 and: [
		(words copyFrom: 1 to: 3) = #('"' 'preload' 'script')].
!

isRemoveAllMethods

	^words size = 4 and: [
		((words at: 2) beginsWith: 'removeAllMethods.') and: [
		(words at: 3) = 'class' and: [
		(words at: 4) beginsWith: 'removeAllMethods.']]].
!

processLine

	| ucLine |
	(line isEmpty or: [line first = $!!]) ifTrue: [^self].
	ucLine := line asUppercase.
	(ucLine beginsWith: 'CATEGORY:'		) ifTrue: [^self setCategory		].
	(ucLine beginsWith: 'CLASSMETHOD:'	) ifTrue: [^self defineClassMethod	].
	(ucLine beginsWith: 'DOIT'			) ifTrue: [^self readDoIt			].
	(ucLine beginsWith: 'INPUT'			) ifTrue: [^self readInput			].
	(ucLine beginsWith: 'METHOD:'		) ifTrue: [^self defineInstanceMethod	].
	(ucLine beginsWith: 'RUN'			) ifTrue: [^self readDoIt			].
	(ucLine beginsWith: 'EXPECTVALUE'	) ifTrue: [^self readExpectValue		].
	(ucLine beginsWith: 'REMOVEALLMETHODS'	) ifTrue: [^self readRemoveAllMethods	].
	(ucLine beginsWith: 'REMOVEALLCLASSMETHODS'	) ifTrue: [^self readRemoveAllClassMethods	].
	(ucLine beginsWith: 'ERRORCOUNT'	) ifTrue: [^self readErrorCount	].
	(ucLine beginsWith: 'COMMIT'	) ifTrue: [^self readCommit	].
	(ucLine beginsWith: 'SEND') ifTrue: [^self readSend ].
	(ucLine beginsWith: 'SET COMPILE_ENV:') ifTrue: [^self readSetCompileEnv].

	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , ucLine printString , ' during file-in!!'.
	SessionManager current pause.
!

read

	stream reset.
	ProgressDialog showModalWhile: [:progress |
		self readWithProgress: progress.
	].
!

readCommit

	browser doIt: 'System commitTransaction'.
!

readDoIt

	text := self readUpToPercent.
	words := (text subStrings: Character space) reject: [:each | each isEmpty].
	self isDefineClass 			ifTrue: [^self defineClass			].
	self isRemoveAllMethods 	ifTrue: [^self removeMethods	].
	self doIt.
!

readErrorCount
!

readExpectValue
!

readInput

	| path |
	path := line copyFrom: 7 to: line size.
	path := path 
		copyReplaceAll: '$l2tests'
		with: '\\samba\denile2\users\jfoster\checkouts\gss64bit11\tests'.
	path := path
		copyReplaceAll: '/'
		with: '\'.
	browser fileInPath: path.
!

readRemoveAllClassMethods

	| string |
	string := line copyFrom: 22 to: line size.
	browser doIt: string , ' class removeAllMethods'.
!

readRemoveAllMethods

	| string |
	string := line copyFrom: 18 to: line size.
	browser doIt: string , ' removeAllMethods'.
!

readSend

	text := line copyFrom: 6 to: line size.
	self doIt.
!

readSetCompileEnv

	line asUppercase = 'SET COMPILE_ENV: 0' ifTrue: [^self].
	self error: 'Non-zero compile environment not supported!!'.
!

readUpToPercent

	| nextLine writeStream string |
	writeStream := WriteStream on: String new.
	[
		stream atEnd not and: [
			nextLine := stream nextLine.
			(nextLine beginsWith: '%') not.
		].
	] whileTrue: [
		writeStream nextPutAll: nextLine; lf.
	].
	string := writeStream contents.
	^string.
!

readWithProgress: progress

	[
		self readWithProgressA: progress.
	] on: Error do: [:ex | 
		| myStream |
		SessionManager current logError: ex.
		myStream := WriteStream on: String new.
		ex printTraceOn: myStream.
		(JadeWorkspace showOnSession: browser gciSession) showText: myStream contents.
		MessageBox notify: ex description.
		SessionManager current pause.
	].
!

readWithProgressA: progress

	[
		stream atEnd not.
	] whileTrue: [
		line := stream nextLine.
		progress 
			value: stream position * 100 // stream size;
			text: line;
			yourself.
		[
			self processLine.
		] on: TerminateProcess do: [:ex | 
			stream setToEnd.
			ex return.		"No need to terminate this Dolphin process (which is the default behavior)"
		].
	].
!

removeMethods

	self doIt.
!

reportCompileFailure: anIXMLDOMElement 

	| errors readStream writeStream begin |
	errors := (anIXMLDOMElement getElementsByTagName: 'error') collect: [:each | 
		(each getAttribute: 'offset') asNumber -> (each text , ' (#' , (each getAttribute: 'number') , ')').
	].
	readStream := ReadStream on: text.
	writeStream := WriteStream on: String new.
	begin := 1.
	errors asSortedCollection do: [:each |
		writeStream 
			nextPutAll: (readStream next: each key - begin);
			nextPutAll: '{';
			nextPutAll: each value;
			nextPutAll: '}';
			yourself.
		begin := each key.
	].
	writeStream nextPutAll: readStream upToEnd.	
	MessageBox notify: writeStream contents.
!

setCategory

	category := (line subStrings: $') at: 2.
!

stream: aStream

	stream := aStream.
! !
!JadeFileIn categoriesFor: #defineClass!public! !
!JadeFileIn categoriesFor: #defineClassMethod!public! !
!JadeFileIn categoriesFor: #defineInstanceMethod!public! !
!JadeFileIn categoriesFor: #doIt!public! !
!JadeFileIn categoriesFor: #fileInPath:forBrowser:!public! !
!JadeFileIn categoriesFor: #fileInStream:forBrowser:!public! !
!JadeFileIn categoriesFor: #fileInString:forBrowser:!public! !
!JadeFileIn categoriesFor: #fileInXML:forBrowser:!public! !
!JadeFileIn categoriesFor: #isDefineClass!public! !
!JadeFileIn categoriesFor: #isPostloadScript!public! !
!JadeFileIn categoriesFor: #isPreloadScript!public! !
!JadeFileIn categoriesFor: #isRemoveAllMethods!public! !
!JadeFileIn categoriesFor: #processLine!public! !
!JadeFileIn categoriesFor: #read!public! !
!JadeFileIn categoriesFor: #readCommit!public! !
!JadeFileIn categoriesFor: #readDoIt!public! !
!JadeFileIn categoriesFor: #readErrorCount!public! !
!JadeFileIn categoriesFor: #readExpectValue!public! !
!JadeFileIn categoriesFor: #readInput!public! !
!JadeFileIn categoriesFor: #readRemoveAllClassMethods!public! !
!JadeFileIn categoriesFor: #readRemoveAllMethods!public! !
!JadeFileIn categoriesFor: #readSend!public! !
!JadeFileIn categoriesFor: #readSetCompileEnv!public! !
!JadeFileIn categoriesFor: #readUpToPercent!public! !
!JadeFileIn categoriesFor: #readWithProgress:!public! !
!JadeFileIn categoriesFor: #readWithProgressA:!public! !
!JadeFileIn categoriesFor: #removeMethods!public! !
!JadeFileIn categoriesFor: #reportCompileFailure:!public! !
!JadeFileIn categoriesFor: #setCategory!packages!public! !
!JadeFileIn categoriesFor: #stream:!public! !

