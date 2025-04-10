!classDefinition: #PowerStatus category: #'3.Replace-if-Type+State-Solucion'!
Object subclass: #PowerStatus
	instanceVariableNames: 'vehicleToPower'
	classVariableNames: ''
	poolDictionaries: ''
	category: '3.Replace-if-Type+State-Solucion'!

!PowerStatus methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:19:26'!
accelerate

	self subclassResponsibility! !

!PowerStatus methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:19:38'!
initializePowerStatusOf: vehicle

	vehicleToPower := vehicle ! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'PowerStatus class' category: #'3.Replace-if-Type+State-Solucion'!
PowerStatus class
	instanceVariableNames: ''!

!PowerStatus class methodsFor: 'instance creation' stamp: 'NR 4/3/2025 19:19:07'!
on: vehicle

	^ self new initializePowerStatusOf: vehicle! !


!classDefinition: #PowerOff category: #'3.Replace-if-Type+State-Solucion'!
PowerStatus subclass: #PowerOff
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: '3.Replace-if-Type+State-Solucion'!

!PowerOff methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:19:38'!
accelerate

	vehicleToPower accelerateWhenTurnedOff! !


!classDefinition: #PowerOn category: #'3.Replace-if-Type+State-Solucion'!
PowerStatus subclass: #PowerOn
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: '3.Replace-if-Type+State-Solucion'!

!PowerOn methodsFor: 'accelerate' stamp: 'NR 4/3/2025 19:19:38'!
accelerate

	vehicleToPower accelerateWhenTurnedOn! !


!classDefinition: #Vehicle category: #'3.Replace-if-Type+State-Solucion'!
Object subclass: #Vehicle
	instanceVariableNames: 'powerStatus speed'
	classVariableNames: ''
	poolDictionaries: ''
	category: '3.Replace-if-Type+State-Solucion'!

!Vehicle methodsFor: 'initialization' stamp: 'NR 4/3/2025 19:20:28'!
initialize

	self turnOff.
	speed := 0 * kilometer / hour.! !


!Vehicle methodsFor: 'move' stamp: 'NR 4/3/2025 19:20:20'!
accelerate

	powerStatus accelerate! !

!Vehicle methodsFor: 'move' stamp: 'ARM 9/6/2024 14:51:44'!
accelerateWhenTurnedOff

	self error: self canNotAccelerateErrorMessage! !

!Vehicle methodsFor: 'move' stamp: 'ARM 9/6/2024 14:53:56'!
accelerateWhenTurnedOn

	self subclassResponsibility! !


!Vehicle methodsFor: 'on/off' stamp: 'NR 4/3/2025 19:20:33'!
turnOff

	powerStatus := PowerOff on: self! !

!Vehicle methodsFor: 'on/off' stamp: 'NR 4/3/2025 19:20:36'!
turnOn

	powerStatus := PowerOn on: self! !


!Vehicle methodsFor: 'error messages' stamp: 'ARM 9/6/2024 14:52:47'!
canNotAccelerateErrorMessage

	self subclassResponsibility! !


!classDefinition: #Helicopter category: #'3.Replace-if-Type+State-Solucion'!
Vehicle subclass: #Helicopter
	instanceVariableNames: 'altitude'
	classVariableNames: ''
	poolDictionaries: ''
	category: '3.Replace-if-Type+State-Solucion'!

!Helicopter methodsFor: 'initialization' stamp: 'ARM 9/6/2024 14:55:45'!
initialize

	super initialize.
	altitude := 0 * meter.! !


!Helicopter methodsFor: 'error messages' stamp: 'ARM 9/6/2024 14:53:01'!
canNotAccelerateErrorMessage

	^'Can not fly when turned off'.! !


!Helicopter methodsFor: 'move' stamp: 'ARM 9/6/2024 14:54:16'!
accelerateWhenTurnedOn

	speed := speed + (10 * kilometer / hour).
	altitude := altitude + (5 * meter).! !


!classDefinition: #Motorcycle category: #'3.Replace-if-Type+State-Solucion'!
Vehicle subclass: #Motorcycle
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: '3.Replace-if-Type+State-Solucion'!

!Motorcycle methodsFor: 'error messages' stamp: 'ARM 9/6/2024 14:53:08'!
canNotAccelerateErrorMessage

	^'Can not run when turned off'! !


!Motorcycle methodsFor: 'move' stamp: 'ARM 9/6/2024 14:54:27'!
accelerateWhenTurnedOn

	speed := speed + (20 * kilometer / hour).! !
