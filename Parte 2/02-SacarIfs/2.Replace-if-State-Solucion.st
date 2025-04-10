!classDefinition: #Automobile category: #'2.Replace-if-State-Solucion'!
Object subclass: #Automobile
	instanceVariableNames: 'powerStatus speed'
	classVariableNames: ''
	poolDictionaries: ''
	category: '2.Replace-if-State-Solucion'!

!Automobile methodsFor: 'initialization' stamp: 'NR 4/3/2025 19:16:38'!
initialize

	self turnOff.
	speed := 0 * kilometer / hour! !


!Automobile methodsFor: 'on/off' stamp: 'NR 4/3/2025 19:16:48'!
turnOff

	powerStatus := PowerOff on: self! !

!Automobile methodsFor: 'on/off' stamp: 'NR 4/3/2025 19:16:51'!
turnOn

	powerStatus := PowerOn on: self! !


!Automobile methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:15:55'!
accelerate

	powerStatus accelerate! !

!Automobile methodsFor: 'accelerate' stamp: 'ARM 9/6/2024 14:41:29'!
accelerateWhenTurnedOff

	self error: 'Can not accelerate when turned off'! !

!Automobile methodsFor: 'accelerate' stamp: 'ARM 9/6/2024 14:41:16'!
accelerateWhenTurnedOn

	speed := speed + (10 * kilometer / hour)! !


!classDefinition: #PowerStatus category: #'2.Replace-if-State-Solucion'!
Object subclass: #PowerStatus
	instanceVariableNames: 'vehicleToPower'
	classVariableNames: ''
	poolDictionaries: ''
	category: '2.Replace-if-State-Solucion'!

!PowerStatus methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:16:07'!
accelerate

	self subclassResponsibility! !

!PowerStatus methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:15:31'!
initializePowerStatusOf: vehicle

	vehicleToPower := vehicle! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'PowerStatus class' category: #'2.Replace-if-State-Solucion'!
PowerStatus class
	instanceVariableNames: ''!

!PowerStatus class methodsFor: 'instance creation' stamp: 'NR 4/3/2025 19:15:31'!
on: vehicle

	^ self new initializePowerStatusOf: vehicle! !


!classDefinition: #PowerOff category: #'2.Replace-if-State-Solucion'!
PowerStatus subclass: #PowerOff
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: '2.Replace-if-State-Solucion'!

!PowerOff methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:16:16'!
accelerate

	vehicleToPower accelerateWhenTurnedOff! !


!classDefinition: #PowerOn category: #'2.Replace-if-State-Solucion'!
PowerStatus subclass: #PowerOn
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: '2.Replace-if-State-Solucion'!

!PowerOn methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:13:50'!
accelerate

	vehicleToPower accelerateWhenTurnedOn! !
