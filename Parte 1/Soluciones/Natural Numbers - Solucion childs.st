!classDefinition: #I category: 'PeanoChildsAndRoman'!
DenotativeObject subclass: #I
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'PeanoChildsAndRoman'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'I class' category: 'PeanoChildsAndRoman'!
I class
	instanceVariableNames: ''!

!I class methodsFor: 'next & previous' stamp: 'JFGO 3/25/2023 19:00:37'!
next
	^II.! !

!I class methodsFor: 'next & previous' stamp: 'JFGO 3/28/2023 18:14:50'!
previous
	self error: self oneDontHavePrevErrorDescription.! !


!I class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/28/2023 17:46:07'!
divideWithDividendGreaterEqualThanDivisor: aDividend and: aDivisor
	"Caso 'Equal' del GreaterEqual"
	^self! !

!I class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/25/2023 20:49:28'!
multiplyByBiggerThanOne: aNaturalNumberBiggerThanOne
	^aNaturalNumberBiggerThanOne! !

!I class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/25/2023 19:59:30'!
subtractFrom: aNaturalNumber
	^aNaturalNumber previous.! !

!I class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/28/2023 17:30:14'!
timesDivideTo: aDividend
	^aDividend.
	! !


!I class methodsFor: 'error description' stamp: 'JFGO 3/28/2023 18:12:03'!
negativeNumbersNotSupportedErrorDescription

	^ 'In natural numbers, can not substract a number minus a bigger or equal number'! !

!I class methodsFor: 'error description' stamp: 'JFGO 3/28/2023 18:14:50'!
oneDontHavePrevErrorDescription

	^ 'El I no tiene previo'! !


!I class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/25/2023 20:48:03'!
* aNaturalNumber
	^aNaturalNumber.! !

!I class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/25/2023 19:13:50'!
+ aNaturalNumber
	^aNaturalNumber next.! !

!I class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/28/2023 18:12:03'!
- aNaturalNumber
	self error: self negativeNumbersNotSupportedErrorDescription.
	! !

!I class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/28/2023 17:31:47'!
/ aDivisor
	^aDivisor timesDivideTo: self
	! !


!classDefinition: #II category: 'PeanoChildsAndRoman'!
DenotativeObject subclass: #II
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'PeanoChildsAndRoman'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'II class' category: 'PeanoChildsAndRoman'!
II class
	instanceVariableNames: 'next previous'!

!II class methodsFor: 'next & previous' stamp: 'JFGO 3/29/2023 20:25:36'!
nameOfNext
	"Si termino en 999, poner M (1000)"
	(self name endsWith: 'CMXCIX') ifTrue:[^(self name withoutSuffix: 'CMXCIX'), 'M'].
	
	"Si termino en 899, poner CM (900)"
	(self name endsWith: 'DCCCXCIX') ifTrue:[^(self name withoutSuffix: 'DCCCXCIX'), 'CM'].
	
	"Si termino en 499, poner D (500)"
	(self name endsWith: 'CDXCIX') ifTrue:[^(self name withoutSuffix: 'CDXCIX'), 'D'].
	
	"Si termino en 399, poner CD (400)"
	(self name endsWith: 'CCCXCIX') ifTrue:[^(self name withoutSuffix: 'CCCXCIX'), 'CD'].
	
	"Si termino en 99, poner C (100)"
	(self name endsWith: 'XCIX') ifTrue:[^(self name withoutSuffix: 'XCIX'), 'C'].
	
	"Si termino en 89, poner XC (90)"
	(self name endsWith: 'LXXXIX') ifTrue:[^(self name withoutSuffix: 'LXXXIX'), 'XC'].
	
	"Si termino en 49, poner L (50)"
	(self name endsWith: 'XLIX') ifTrue:[^(self name withoutSuffix: 'XLIX'), 'L'].
	
	"Si termino en 39, poner XL (40)"
	(self name endsWith: 'XXXIX') ifTrue:[^(self name withoutSuffix: 'XXXIX'), 'XL'].
	
	"Si termino en 9, poner X (10)"
	(self name endsWith: 'IX') ifTrue:[^(self name withoutSuffix: 'IX'), 'X'].
	
	"Si termino en 8, poner IX (9)"
	(self name endsWith: 'VIII') ifTrue:[^(self name withoutSuffix: 'VIII'), 'IX'].
	
	"Si termino en 4, poner V (5)"
	(self name endsWith: 'IV') ifTrue:[^(self name withoutSuffix: 'IV'), 'V'].
	
	"Si termino en 3, poner IV (4)"
	(self name endsWith: 'III') ifTrue:[^(self name withoutSuffix: 'III'), 'IV'].
	
	"Si no, poner I (1)"
	^ self name, 'I'! !

!II class methodsFor: 'next & previous' stamp: 'JFGO 3/29/2023 20:01:27'!
next
	next ifNil: [
		next := II createChildNamed: self nameOfNext. 
		next previous: self.		
		].
	
	^next.! !

!II class methodsFor: 'next & previous' stamp: 'JFGO 3/25/2023 19:25:46'!
previous
	^previous.! !

!II class methodsFor: 'next & previous' stamp: 'JFGO 3/25/2023 19:36:52'!
previous: aNaturalNumber
	previous:=aNaturalNumber.! !


!II class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/25/2023 20:48:33'!
* aNaturalNumber
	^aNaturalNumber multiplyByBiggerThanOne: self.! !

!II class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/25/2023 19:27:09'!
+ aNaturalNumber
	^self previous + aNaturalNumber next.! !

!II class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/25/2023 19:58:08'!
- aNaturalNumber
	^aNaturalNumber subtractFrom: self.! !

!II class methodsFor: 'arithmetic operations' stamp: 'JFGO 3/28/2023 17:18:45'!
/ aDivisor
	
	^aDivisor timesDivideTo: self.! !


!II class methodsFor: 'clone removing' stamp: 'JFGO 3/27/2023 17:34:19'!
removeAllNext

	next ifNotNil:
	[
		next removeAllNext.
		next removeFromSystem.
		next := nil.
	]! !


!II class methodsFor: 'error descriptions' stamp: 'JFGO 3/28/2023 17:37:08'!
canNotDivideByBiggerNumberErrorDescription

	^ 'No se puede dividir'! !


!II class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/28/2023 17:55:18'!
divideWithDividendGreaterEqualThanDivisor: aDividend and: aDivisor
	^[(aDividend - aDivisor) / aDivisor + I
		] on:Error do: [I]! !

!II class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/25/2023 20:49:11'!
multiplyByBiggerThanOne: aNaturalNumberBiggerThanOne
	^aNaturalNumberBiggerThanOne + (self previous * aNaturalNumberBiggerThanOne)! !

!II class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/25/2023 20:54:19'!
subtractFrom: aNaturalNumber
	^aNaturalNumber previous - self previous.! !

!II class methodsFor: 'private auxiliary operations' stamp: 'JFGO 3/28/2023 17:54:59'!
timesDivideTo: aDividend

"No tenemos comparacion disponible para saber si divisor es mas grande que dividendo, habra que ver si falla"
"El + I es para salvar el caso de division entre iguales"

	^ [(aDividend + I - self) divideWithDividendGreaterEqualThanDivisor:  aDividend and: self		] 
		on: Error 
		do: [self error: self canNotDivideByBiggerNumberErrorDescription]! !


!II class methodsFor: '--** private fileout/in **--' stamp: 'JFGO 3/26/2025 16:28:34'!
initializeCollaboratorsFromFile
	"Auto generated method for loading purposes - Do not modify it"

	next := nil.
	previous := I.! !

II initializeAfterFileIn!
