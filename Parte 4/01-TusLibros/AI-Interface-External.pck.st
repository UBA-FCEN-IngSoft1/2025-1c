'From Cuis6.3 [latest update: #6350] on 22 June 2025 at 9:30:42 pm'!
'Description '!
!provides: 'AI-Interface-External' 1 3!
!requires: 'WebClient' 1 33 nil!
SystemOrganization addCategory: #'AI-Interface-External'!


!classDefinition: #PNGReadWriter category: #'AI-Interface-External'!
ImageReadWriter subclass: #PNGReadWriter
	instanceVariableNames: 'chunk form width height depth backColor bitsPerChannel colorType interlaceMethod bitsPerPixel bytesPerScanline thisScanline prevScanline rowSize globalDataChunk unknownChunks palette transparentPixelValue filtersSeen cachedDecoderMap bigEndian auxBitBlt auxSource auxDest auxCMap'
	classVariableNames: 'BPP BlockHeight BlockWidth Debugging StandardSwizzleMaps'
	poolDictionaries: ''
	category: 'AI-Interface-External'!
!classDefinition: 'PNGReadWriter class' category: #'AI-Interface-External'!
PNGReadWriter class
	instanceVariableNames: ''!

!classDefinition: #AiChatTesterWindow category: #'AI-Interface-External'!
SystemWindow subclass: #AiChatTesterWindow
	instanceVariableNames: 'conversationTextSpace inputLayout inputTextSpace apiConnector'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AI-Interface-External'!
!classDefinition: 'AiChatTesterWindow class' category: #'AI-Interface-External'!
AiChatTesterWindow class
	instanceVariableNames: ''!

!classDefinition: #AiApiTest category: #'AI-Interface-External'!
TestCase subclass: #AiApiTest
	instanceVariableNames: 'predefinedResponse'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AI-Interface-External'!
!classDefinition: 'AiApiTest class' category: #'AI-Interface-External'!
AiApiTest class
	instanceVariableNames: ''!

!classDefinition: #AiApiConnector category: #'AI-Interface-External'!
Object subclass: #AiApiConnector
	instanceVariableNames: 'apiRequestMaker apiResponseReader webClientClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AI-Interface-External'!
!classDefinition: 'AiApiConnector class' category: #'AI-Interface-External'!
AiApiConnector class
	instanceVariableNames: ''!

!classDefinition: #AiApiRequestMaker category: #'AI-Interface-External'!
Object subclass: #AiApiRequestMaker
	instanceVariableNames: 'apiUrl requestContents requestType apiKey'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AI-Interface-External'!
!classDefinition: 'AiApiRequestMaker class' category: #'AI-Interface-External'!
AiApiRequestMaker class
	instanceVariableNames: ''!

!classDefinition: #AiApiResponseReader category: #'AI-Interface-External'!
Object subclass: #AiApiResponseReader
	instanceVariableNames: 'generatedImage answeredText imageReaderMethod textReaderMethod'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AI-Interface-External'!
!classDefinition: 'AiApiResponseReader class' category: #'AI-Interface-External'!
AiApiResponseReader class
	instanceVariableNames: ''!

!classDefinition: #AiChatTesterModel category: #'AI-Interface-External'!
Object subclass: #AiChatTesterModel
	instanceVariableNames: 'conversationText inputText modelName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AI-Interface-External'!
!classDefinition: 'AiChatTesterModel class' category: #'AI-Interface-External'!
AiChatTesterModel class
	instanceVariableNames: ''!


!PNGReadWriter commentStamp: '<historical>' prior: 0!
I am a subclass of ImageReadWriter that decodes Portable Network Graphics
(PNG) images.

Submitted by Duane Maxwell!

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'DSM 3/26/2000 21:32'!
copyPixels: y
	"Handle non-interlaced pixels of supported colorTypes"

	| s |
	s _ #(copyPixelsGray: nil copyPixelsRGB: copyPixelsIndexed:
		  copyPixelsGrayAlpha: nil copyPixelsRGBA:) at: colorType+1.
	self perform: s asSymbol with: y
! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'RAA 11/4/2000 16:08'!
copyPixels: y at: startX by: incX
	"Handle interlaced pixels of supported colorTypes"

	| s |
	s _ #(copyPixelsGray:at:by: nil copyPixelsRGB:at:by: copyPixelsIndexed:at:by:
		  copyPixelsGrayAlpha:at:by: nil copyPixelsRGBA:at:by:) at: colorType+1.
	self perform: s asSymbol with: y with: startX with: incX
! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 6/7/2016 10:36'!
copyPixelsGray: y
	"Handle non-interlaced grayscale color mode (colorType = 0)"

	| blitter high low value base bits bytesLeft word |

	bitsPerChannel = 16 ifTrue: [
		"Warning: This is extremely slow. Besides we are downsampling to 8 bits!!"
		blitter := BitBlt bitPokerToForm: form.
		0 to: width - 1 do: [ :x |
 			high := thisScanline at: x * 2 + 1.
 			low := thisScanline at: x * 2 + 2.
 			value := (high * 256 + low = transparentPixelValue)
 				ifTrue: [0 "transparent"]
 				ifFalse: [high max: 1].
 			blitter pixelAt: x @ y put: value ].
  			^self ].

	"Just copy the bits"
	"This interesting technique (By Andreas Raab) is a bit obscure, but it is so fast that we leave it active
	Note that currently it only works on 1bpp PNG, building a BigEndian form."
	(bitsPerChannel = 1 and: [ form isBigEndian ]) ifTrue: [ ^self copyPixelsGrayWeirdBitBltHack: y ].

	"This interesting technique  (By Yoshiki Ohshima) is very fast, although only works with whole word image width"
	(thisScanline size bitAnd: 3) = 0 ifTrue: [
		^form copyFromByteArray2: thisScanline to: y * (form width* bitsPerChannel // 32) ].

	"This Smalltalk version might be easier to understand and is quite fast too."
	"This somewhat weird mixture of (#* and #+) with (#bitShift: and #bitOr:) 
	is to make use of faster arithmetic bytecodes, but not of slow largeintegers."
	"This works for GrayForms of any endianness and width"
	base _ y * (form width * bitsPerChannel + 31 // 32) + 1.
	bits _ form bits.
	form isBigEndian ifTrue: [
		0 to: thisScanline size // 4 - 1 do: [ :i |
			| ii |
			ii _ i * 4.
			word _
		           ((thisScanline at: ii+1) *256 + 
		           (thisScanline at: ii+2) *256 + 
		           ((thisScanline at: ii+3)) bitShift: 8) bitOr: 
		           (thisScanline at: ii+4).
			bits at: base + i put: word.].
		(bytesLeft := thisScanline size bitAnd: 3) = 0 ifFalse: [
			word := 0.
			thisScanline size - bytesLeft + 1 to: thisScanline size do: [ :ii |
				word := word * 256 + (thisScanline at: ii) ].
			word := word bitShift: 8 * (4 - bytesLeft).
			bits at: base + (thisScanline size // 4) put: word ].
	] ifFalse: [
		0 to: thisScanline size // 4 - 1 do: [ :i |
			| ii |
			ii _ i * 4.
			word _
		           ((thisScanline at: ii+4) *256 + 
		           (thisScanline at: ii+3) *256 + 
		           ((thisScanline at: ii+2)) bitShift: 8) bitOr: 
		           (thisScanline at: ii+1).
			bits at: base + i put: word ].
		(bytesLeft := thisScanline size bitAnd: 3) = 0 ifFalse: [
			word := 0.
			thisScanline size to: thisScanline size - bytesLeft + 1 by: -1 do: [ :ii |
				word := word * 256 + (thisScanline at: ii) ].
			bits at: base + (thisScanline size // 4) put: word ].
	]! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'nice 5/10/2014 20:14'!
copyPixelsGray: y at: startX by: incX
	"Handle interlaced grayscale color mode (colorType = 0)"

	| offset bits blitter pixPerByte shifts b pixel mask pixelNumber |
	bitsPerChannel = 16
		ifTrue: [
			"Warning: This is extremely slow. Besides we are downsampling to 8 bits!!!!"
			blitter := BitBlt bitPokerToForm: form.
			startX to: width-1 by: incX do: [ :x |
				| high low value |
				high := thisScanline at: x//incX<<1 + 1.
				low := thisScanline at: x//incX<<1 + 2.
				value := (high * 256 + low = transparentPixelValue)
					ifTrue: [0 "transparent"]
					ifFalse: [high max: 1].
				blitter pixelAt: x @ y put: value ].
			^self ].
	offset := y*rowSize+1.
	bits := form bits.
	bitsPerChannel = 8 ifTrue: [
		startX to: width-1 by: incX do: [ :x | | w |
			w := offset + (x>>2).
			b := 3- (x \\ 4) * 8.
			pixel := (thisScanline at: x // incX + 1)<<b.
			mask := (255<<b) bitInvert32.
			bits at: w put: (((bits at: w) bitAnd: mask) bitOr: pixel)
		].
		^ self
	].
	bitsPerChannel = 1 ifTrue: [
		pixPerByte := 8.
		mask := 1.
		shifts := #(7 6 5 4 3 2 1 0).
	].
	bitsPerChannel = 2 ifTrue: [
		pixPerByte := 4.
		mask := 3.
		shifts := #(6 4 2 0).
	].
	bitsPerChannel = 4 ifTrue: [
		pixPerByte := 2.
		mask := 15.
		shifts := #(4 0).
	].

	blitter := BitBlt bitPokerToForm: form.
	pixelNumber := 0.
	startX to: width-1 by: incX do: [ :x | | rawByte |
		rawByte := thisScanline at: (pixelNumber // pixPerByte) + 1.
		pixel := (rawByte >> (shifts at: (pixelNumber \\ pixPerByte) + 1)) bitAnd: mask.
		blitter pixelAt: (x@y) put: pixel.
		pixelNumber := pixelNumber + 1.
	].
! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 9/23/2012 21:45'!
copyPixelsGrayAlpha: y
	"Handle non-interlaced grayscale with alpha color mode (colorType = 4)"

	| i pixel gray b |
	b _ BitBlt bitPokerToForm: form.
	bitsPerChannel = 8
		ifTrue: [
			0 to: width-1 do: [ :x |
				i _ (x << 1) + 1.
				gray _ thisScanline at: i.
				pixel _ ((thisScanline at: i+1)<<24) + (gray<<16) + (gray<<8) + gray.
				b pixelAt: x@y put: pixel.
				]
			]
		ifFalse: [
			0 to: width-1 do: [ :x |
				i _ (x << 2) + 1.
				gray _ thisScanline at: i.
				pixel _ ((thisScanline at: i+2)<<24) + (gray<<16) + (gray<<8) + gray.
				b pixelAt: x@y put: pixel.
				]
			]
! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 9/23/2012 21:45'!
copyPixelsGrayAlpha: y at: startX by: incX
	"Handle interlaced grayscale with alpha color mode (colorType = 4)"

	| i pixel gray b |
	b _ BitBlt bitPokerToForm: form.
	bitsPerChannel = 8
		ifTrue: [
			startX to: width-1 by: incX do: [ :x |
				i _ (x // incX << 1) + 1.
				gray _ thisScanline at: i.
				pixel _ ((thisScanline at: i+1)<<24) + (gray<<16) + (gray<<8) + gray.
				b pixelAt: x@y put: pixel.
				]
			]
		ifFalse: [
			startX to: width-1 by: incX do: [ :x |
				i _ (x // incX << 2) + 1.
				gray _ thisScanline at: i.
				pixel _ ((thisScanline at: i+2)<<24) + (gray<<16) + (gray<<8) + gray.
				b pixelAt: x@y put: pixel.
				]
			]
! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 1/15/2013 18:24'!
copyPixelsGrayWeirdBitBltHack: y 
	"Handle non-interlaced black and white color mode (colorType = 0)
	By Andreas Raab
	
	Currently enabled only for 1bpp, otherwise the comment at the bottom displays an incorrect image"

	auxBitBlt
		destX: 0 destY: (y * form width*bitsPerChannel//32) width: 1 height: (form width+31*bitsPerChannel//32);
		copyBits.
"
(Form fromBinaryStream: 
		'iVBORw0KGgoAAAANSUhEUgAAAGwAAACHCAAAAADWjuNQAAAAB3RJTUUH2QMFAAEAkIBc5AAA
GadJREFUaIHte2l4lUXS9t39nC052UPCZpCdAIKgEJVFBhUV3EBQB0ERFXfFccOZQUXlehVl
lEsdBUVGEEEERRREENk3gQAqWwghEAgkJCHbOTnr0/f341nOCeDMOJ8z1/dd7/SPnO7qpbqq
q6qrqp8I4j9X5H8Q13+R/cbIziUoNkydC2hUyHNO57mqjhgo7A/4hdmqD8PlOj/J3tKeZfuP
EIKugaNb2XNDGxFp3cmoi/0H/eIGewKEvm7LrnLh7dl3QJLSNZMmmkVxWvPmHqfL5XK5XG6H
lA7Msfr4RqK9StZLNvRkKnA/ldGYALj2213cO8Sa0PkLFdSNQXHIngMgEFemGQspzgcAuJo3
dwHAe9b6J1OBh63GX4GEn8y1dC7LtJYSwLuMGINsNiot0eavK0IIItscHpoC4bz99y0ytPJ5
rwFT7vDa68R2pwBhLSYP310F2ebKC1KOrlkj+PTFebTPjBCgxHWJCdKRQFeqZ8FbEEx97VZl
sPpgAXjvXwGg2YXpBd4W8dTbp18MOFOtxqRyqR6dlArguanPwD89zxpN6qQyuUqSfDURErn5
dnunB+i7+1hlTW0kyrhSlgo8ZjXGA6llZv1YBjDMPBze12zyEeo2G+WRoh6Z9l7rHp4LqNtm
pCpLLTpdsENuuiTVpYkEZvQd3T2estKtDVE6ooL748g8XA08bnBayVdeagolbMrUob8VGYQp
xbL+kBCTFG1SFb9xxS3vmWN1laXFoxVIPWnO+BpIO2wLC5UyJ4Bk1aZ1P4ZNwdueC4nMxfHc
UlGuHXdhkltCAJBocsJiY6ajkfSmWchWCXj2mZMj4di2HQAyasv7GISKL8fWaHruvJ4qzo5R
w4ABkeO1dSHBw+8Uhivzr7ckMIpsVzUIQISiYMSEt0z0B3d1NiY76uszYkuR3L7x6HFSkS9p
ELi2wtyLKTRq9ZsfvF9uCQ+A18z6ycwWyU/XHy0pKSkpKR8PJBdZrOsNdDhmyAdHt/+ScUod
JZVOsm40hNAejjBKRqPRqMXqdwAMPkqSLOwFYLnFxnQ3xlss+iOQcsRqzIZA128CJA+NBvAI
Y0otCQrg9E0bhVCuw8MjDQm6T0Rbzk42iL/hpVNyeY8+GY5o5eZawUuuoCVcYeigfW7Urdqd
Sxdqe4d07ZxYtaFOUFwWz0ZDar5C45JdZaif4jxA2CY7Y7OpNSxLi22az8RRprNySGwd7X0L
hy0HAtEzkBFANApQH7n0MuFs1iQBQOL1ay/TLcICQDg2Hw0hq65nLnnPvA6cA1eOs8dYikix
/c3EZIfuSRJwQbqEcI5KMHhEAX3nifLTp31tWnfvBFoGsWFm8HSfG0025u+QzmG2vaKAf/vP
xTyvZW6P2PZjyHjWpc3Gl8C5u5UQ5ur/uMSQGRiFAIUNjFuBIAVEI4iBT9jzGyOkuZ0YVPzX
b/wvsr9XYq5cTPQpLFGOB9pVBSGsJoXhOQphaKQtegqCBiXKcDoaIYNoqIs0cwIATwW184wp
Ws22/Lr6pPT+vZ00llOIahogRK1SKlMAIAWjglIAmr01XbktvBKgqYb2Fcm/pLc4RJKs6pI4
2oQu62DOGFhiGsGn215aQkX/I+e36LCAilTccMWAi/K6devapc+4DdZy4dFX3XaQimTDn242
fcJ4v3Ei5AGSZEUqRhnAfenQ+j7yzIO9gYERA3QrUorJw5cDrVeYU9fETkVbYq6rcoGuJxgl
Q11wI8/wGwUkNGEdpOl0LKrGtEcA4PHtnqqmZl+SG6vuPIlr5mSbllMKDm8Ld9QV+LjsjevN
NZwQe0cuagLADcsrdwDgicMXJUIICDcAwKNZkYQTqNzr0jze151QBt8lpOO1P0cx4WWnARDQ
iCf6AACOzz9cm26ctguOyLqRn6eAtOXGARD+410TAQLvZjrCynHUZzll174QfnGKRzodroue
voQmft/vVwPo6rQlzy24OhhSIe3kZrTymrKgMPzip1eNmZdAIMGWG/Lgpu+21ZAvpVjCreEu
8zg+bGUJWDPTNxsHCW1oEhI2W6fNDTFbqy2i4cfq3TCWrwncznBPjDMHOgC0O+bL81JIIZMN
dPWwLvi779xVqIuQf9GGstX3AAD8UJnv/P7VPwbGfJ9j3SsiUXMw7Efm1fdcaYm/gMDT1a/M
805tsJ1XBwAZDDkkEK51L+8UBWTF5ZVm78Lj+u29ASBzAyotqhM+uwLP7p9TeP+XphiFGZh+
a/T4DcfUkxdbJBrbmFz1/geBetiFttP6AlyFhp5lYYxB9wSgz8Kdhbs/7wKsMUB3otkJKtZ0
A54zubMO+JLk1xpaFdqa1B3jqMhxgMS9JjBOz56Hs4AkeSoDYw3gie4APEkewJ5wO5ocIcl8
L7T5huuzBlhMKr4E9PFbetbNPKlxEPbcOEOsI2LGxwmWfW6+4vH2aUFf0JP7l+lm8ByE2wGA
F70JfVy+BIAI4AOAiTdj811h8xwjCAIg3h9FWJ5y3E196ICznxcAwgfpbWugFfAdO6ajZUeP
5WUU1GjdXQCg1oYjXdoBQNmWUN8cgKJiu1CXm87mppNtLgZAUfN1TVfT0/yt3IJzOTwxmOkV
Oc4e82uLEsDZrhl4xi9+A8rUr7h//29vauqRfzzIKmdT9k+5m7HRf9+R/UfI/o2lsYCEdhfJ
nF7GRWP4GgAoziA25DLgjYjSYz7BLzOHpNJ1XSfJzy8AgF5rqUidd7X+miT5aLcvScX8G8eH
Sc4YMmhKmCTX9MwbMPCaG4c/sZeK5Imru60nqfhdv9trSHLNTTcPGzb03j8tDtrXgxl5RnWS
nwLd7hrVAcnbSRXlYMwmSQ7GB6TiJvSN8vRI4MWgIslFgNAkgKZ7SOr8A+4gqXgTniBJfmyR
87vj8cjUzm/9umJFazwVIX2DHTNJ6rwZC0iSN2AWSW7BIO7pjXbfGDExv8C1xUWHig7cgEkk
dR7NcO2m4lbZqoIkOQuD87f+sOqDPPS3aHMAEKgBKH440muKBLwzqrvTiD6+qQ2nOVlgHIMD
oU8fqnZ/2ssOZZKaBkAtFWEAEq3ue/XNj4Cp6qEmAACJFhcBwPX9NqweHHPlDsx/d31U58e2
ddZJpfMW+1xnkTp/cDrRrB1utXjyBTxpqZlNm8CzyQCUNHXu5DaZYxDGj2D6g8Pxl7h0UsdC
XiiJRBwAFGSdnk4hgDJc1EJBcEs1AF26HYGeS+ou+6zTS6QEBZHcMbK/ynPbA30MLyvn5vfe
+fAN9VgT05tGBCSE8MNlyS1JtXp5va54LAuv6WR4bIfvSJL98AVJcpBxZhtETin5GWDeYgtx
O/m9W1vEqBnDF2VmzHK1qzMpn4PbSJKfOsQ2xudBVERXitOAyx59pCfwSQyZUtGBBrJ16B5U
is8iYydJci5GUfF1eNdZORo+Bjfettg8F91fnvyn8UPdGEN1hkdMku80BYBWs0lSMc9AGuhu
5G9Xo0OAZHggcstIcjpuIclhaHnAmn84Ce1qrMZ888ATHw5YoHhzRVG2tVK1vCxDlwIUX50a
2A5kePGxmzoBOLI8ZYQbFCeX1l7VAxQFm8+/AsCpj+ovHmqtsLT44j6W+di/LES4s9IuaG8j
iEdm3RakjBkjoyEII46yHQkzrrJyFzZM/Z2kw7/LEEfoOhv4G9zU5yznvCcbAxl3m8e/RCiA
OmmOUIwNiQ23RwIANQ2MLWh2xrExVNikGVBT1NaIQ7Bydfl5119i1PPLfuelKCy51Asoob79
viqx+4gsCiB0FIgirYV1cOVLd+udRzYBiEiBty2AvUuGdomZK0UqRe4U80kuw1qSpP8OZLf1
ipcNob0V95L8s+cwSZ3j0bx7R1xQQZLFTaTURPIYM/N9oDVyctD5EEnqQ3IqSd7gPBQfef60
3Bcld+BLkitgmLrnMc0fLRuKjVQk7wLGk39yF5NkecrlYXLJw3tJ8rBnxPfrVjyDWxSpU12d
+F0kMrO9YYPWYwr5IyZaegaSavsH5STzcfl9Dz5yldhEkqEOw0iySD5Pkryl8/OYwonJJ0iq
hi7OobfdNamAOskjCX8kyXscJaTicdcEkgybq49MOswHPVYinA4AvpLE0mwAYn+lQq0d4gGA
7jbOVHe+qCYkRdwuAEj47L2dNdqCGfnNAUQNn71lNGyELk4A8JnH/sIXbz4186E2MQEkuWa2
TynmYxYVl5hsHIu54UjFMGwkSQ5v18BnkNr8JEldXzC1jnwc+SRZmvYUI/rmrJxqkuTvkrcw
OitrIUlS53PeoXaa2mTj5u8COrkDH5L8GutIkmV90Kp9CiYYJv66NgHySaSWklSchrbXd8cV
DSRZ3jShXdvW8JhZ6h+y0bYV2u8lSSqWZ+NBK8trZguMhHHypdkAmvRPAQA2/faTjSXXDhls
aOLtxQRebXbcDUBgfLdVJzs8NDIBAJy3+smknMHdDOnO2/LJIXnhSCOzIJD99rZ7Y7rcyFyR
oDQdt0Y2TknQyA6d6aXZ3rcVt0ucNdsujZFBRV0UlldIY3cwDLHdgGk3zOyWMJJWcQnVxiPj
dve/I5NqWFrSNLEEoOIIp91koxn2j2mNTYtMxNVjz5DWTIHy2tR0FwGgWiZL/RSyBaBOe5Kg
VyUmAWjwS8p0Y4cnDl3q4unNl2QByh8i6EklBSjqV+zLvqq9EgBE6KfTWR2T4h7rrFI2KjUz
4ykfScXr72bNdTmLqEhfx5lkTe6bJPmWJzklPW8ZSfJDjFHcK9aSiq97m7ds1nQGSfLIhQl5
LVJWkSSLL81qkd1pb5ye+XcndydEeETNxzl7HsTrAFCXve9WtSgPAhCVAkjS6wGgLnGmC18M
+74fBbxiPmdTSgAobbGYjr88PSIDwMS6n9v57tt+JUDxyc8bOlW9eti8YhwAXPVBAti+Kb8n
ehyb9bIHSstZtqL0HuMRlokfbosGjhtJ1oxhwNVLl/UDoGfNGJUzWghAwFk6AYk/dvYCCG+9
sR2S5hmKd7F2T7L7/G7mQTkAlNR5TrYggtIDIBw2HoBqFzcMH3CH4ec01EOFYvrSEEqCAERw
8De37DHVy5X348Lb3nUrCVebXQDWdmwBgH2Xnyw/NUWfZQsU69+eS5KVrXtuPPi+9zmSOgfe
Qv4Za6mTvrSZZDTnRZKc7H3zrdd7tjxMRU53n+YaL9aRig/mkqOzjEtnnbvXayPxHknFqZ0X
/Phl2j1xhrjm6x0kyd2XJSVmPhogqXP0A2Ro6KBqkg29PyWD17xDkh+0bH1+79t+ok5y6Wgf
ufKBQlJx+j1Blg+5vU6RiptH9R/8foSk4onbWp/fbOhJ86aOsyAUemFNuyyjGhEOAH6PBiCs
aRQRqQHQdcApzrKQFCAEAi7tLHjQF3uY/99hrv7Jwn+ZGf8Csui/jE3CspO0DWbMlT3rMx2S
cELE9585zIbaf+1fQSCiOxwgosoJGXBLwhdNE9V6E4DH/Uw+j5RQP3Xw+vde6KaoPNYzvL51
ewBLO7er/m6oC8CRd2o73ZeihMBPn9T1HuUGsOdgJNqrk5LAgrnZf/WYSMnjX+whyT2Dqrh2
cIDk3LHkG4+R1Pv2vDpvbINOBjtfr4rbnyS59pLKETeVkOSl81jQsZ5kVe/73x44JESyusvk
BcM3keQTfZ4a3aGM5IoOs7/yxzk8ifWEQNekj56YOsADILx3tb7TA0DVv9endvBnYwDVTD38
rFcASDg6qLQoiQJIdMHhAYAN3ukY1+lAd8B7weYj6akAhTudHqcCsPiBO2OvHVBHTjVEAGDi
khXHHgQAV8HU11e5AUBLQ2qiHwDdM1MeUcZb8VvX3AcBwH0QRwISQMvS9cFvmAGA1z81+sA7
ABBKS5n5P811oMdn+T9FY/dZ6btmOP+I628kyek3kU/eSTKSe/mofgMrSJ7uVcC7mp0iueZy
1vR4myS3XjSgqxGv/61XbtdFVKT+QP8b8taQ5NPT+crgCpLBx3vc7I/ZxrIfzA8wDr4eUCRZ
sIbcuplkdMmHCzf6qcjw9lo2bAtQsb5IZ8V2nVSsKyg1Tayv2ArcS4uqqUhVWc3QEQNJfcB0
U+Nto+4AKUFKKEhQmO4fIazwmYTdaYXZiKvZYbWSUEJYw0xbKmgNRuMFYEPQqCkaAc7Ko1oe
ZRyKf38Af87yK80Vf7HxSwPjB2mT4vkOKJN4BYryY8kOXeinPRAgKxNY6HEAJ0rraumhXucR
tf4EssyhHXE5Kao2l2VLiPJjR0NpQgm1Zl2zZIKy9MdWMbaTkcoKUnHPg6OHrafipBHDn/Qr
xVVXjrjmFHlojJHFfSD//sdqqTh9XH/XMir9wbUc8w2VurmQI7eRp65+8c7pVJx4y7N9N5Hq
Dw/8+doT1HXe09r6Xo8SgLZ7Jyhw6NA1cguA/U++VTtDAFNeXPiCg1AhCBCouvv7l1N08P5H
HLOHKMihswv8VwPi9ITxWx2As0VZOAqFUGi/5gWO//ze5G5rIOS2olvnWLyUgH7YGagRgBao
aFIMgO4UrQFA83U/ro8KuGq3rzwhBEJv/uGugKSYeWkP90EpcHX6nXdrAMK/G9U5CITS89JW
QaDhziu8nYDmzce/mt8LxKzzHSv2mWKoTYLwlznaaxDHNjvK+vWCWDt3cdrTXorLVy5p31cT
3L91V/scINKvf3F6c2B9B09B6/Mp0Kp2nAQYHNpFtstkQnB3kwlpFFrPQa6UdGpXnZYP5SrR
oE24MjczA/Yrk1pZeg8FQn7N7aGAHhHuM5P5jVTvzLaSMZWyc6YifmycUkeroi1/3aNIfIkq
51mq/QtF0AhiEZfKM7J7jT6DOHsvNoRmqvwX6ImfKRjXVsbXQoKksL/AUIKmkaOEEhBQkqC0
DKWEopA2IiPINiNwA2gH2NokIFJWmwpARbQwJKPaEekht5Y2l6j/6bgjiVDrDrR0AlyengRx
qKDVlkyXKP1wxwUuWfK3i3bM6auVf7attIPE0hT3960cFVPW7e7hEp8v/ambQ6z8aEPieRZl
EoBWcAgEdn4gph4X1ZNnzHZAe3/x4hXAymkLnlVCvrN0XT4gdr07E8TP969fVovQlLyk1wVK
5n318TdRlHx+6uUSQCxcfsCFihW+FDeji47tbQB2nyz6AvHISmW0nkR0wcRvJRwblrXxEpuf
bH8ACDaEKsPAnrEPZQCY6/6kSALPfLfBiYjPjSAQuvfNNp2iCGrZE88DriucfRegpSbVhiB6
NN97FKjJK7nGRqZNAiK1eiuHRElk8v4LsuoPfjgjtTVSPy5rdyFOHHBmDXKiyfRVvZrj9Ik/
5EZao7blTcE8l6vd55GHvVAtL+nXqo0m+w3J1QDktO2mhNuV7Mn1SG/ZjX0kHEP6h+xvqgUB
biy7BYDfn12d5FR1aao+FQiFkwEVpfufEGmerVzxUmhXBQEViKaeOeDfUgTjlMmQe3FGwsZq
k8IwyTBua+IXlfAXipmPIgEIS4+UoKACoJQQQukQQuhKSCodEIoUIkoKIZQCoFPRrxjUoxGg
rkQBerUCfCUno1Any8BonemZSwD69j0CQGTfvqisKN9ZIX07G3YJsW1JvtS2jJ9HrWTOoiot
MP2FIq3h05pZUv6waE5AlEz541554uHDY49KKWZFxfcrPz4I37RZh4Dv7/cDhU+O9GHrpKm7
xNEpIkaZ8JXoBPa+MnEnjj+xIB2+r8JfQXy6yo/wR4/lH0bp8rk74O3Quh2SI5ObCFzw3vEU
BE4fUAi43mAAVasqJIK7f65GrecGILoi8CmQqj+ahFM9ehyFtL4J1SYhWlBYltAMOBYZcaGr
TMtObuLd/UOnrthanNlTc+9IH+jw73H3awnhaQWcV3CHFAU9HC0Sa7vkNk9XrVMGNE0VO3u0
Qerl3bKSU8IHu3l97camZKM4JamVy1uaMcjp7ZAau2JC37kHKYk6kUxG6AgniFBdlhKBsDOR
UtdIRuG2pcb4MZ5ojPyfEgJK2HeSbqUsEXJKG2Qh0zfK/r9Ohv/JcqaYCgK6du6xv3mRAIRu
ZPwafWRDReutxQpHz4ws7TBVEdCJ2EtM/CgF3ZqpTQLqVkWyAQohlBSCQkCpqA5AqqCmM+wI
QxL+sKvspFcrPprkLtb93gpR6wnt0w60OLqkoaXcFsz0H6z1pW/7Nkf/4Hhu4IsjraPbS5MS
Ni1Kzd7+fqCjHZ+BoXIAcsP0nbJ42VeyaPqKav2liTrn/3XOz/LL8nnihyJQbNgs3n2yQDz/
P/twYkwFTs1Yrp167pWv8fP82VrgjanQ33jxANalBSo+qZU/1mwp9GxemYaSdRK7E9ebLHFQ
1O3zqEACRYH7k4uK516Hir0ru3sukR7ou0JDEXq1DyIfjLx4x+q70eaEW/W9riUwsLhL12/z
4B0d6Iy2r1Sg/I6G0+6RmRr6/aglT+uNbnt75mJEAODFPtyyoavlpChF37QodZ2b3vqZR0o3
BCvK9tfzVCWV//QppYd2hdhQVKWCVSoSCem6ooqGGYrqxqlSp/GtvVIkjYSV8cW4Tuo6GfvX
AFIoIFLY0akACdQnx+4J0lAf0wGCUIAgISBs50zQqijThCtpR13GUEA0umL+Y+X/9dzV/yfI
HGEJBU0J848QyqGUAKWSSkJpikaHQxcKAtB0mr2aoiMKIRVo9EpC0ymVAMC4XmH9R5ijOE3V
yfSA9LOJXwsohzuQ3VDrcgSTfN76VNRk+4Jaml82oGmVxwe30LNOBxKU7gl6fBnBhmaVuisp
wKDMqvL4kBhxZJRHkoKaVCKcUR/NOsUETygScWYlGNb3/wA9AhmM+SowxQAAAABJRU5ErkJg
gg=='
				base64Decoded asByteArray readStream) display
"! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 6/30/2011 10:22'!
copyPixelsIndexed: y
	"Handle non-interlaced indexed color mode (colorType = 3)"
	| hack hackBlt swizzleHack swizzleBlt scanline hackDepth |
	scanline := ByteArray new: bytesPerScanline + 3 // 4 * 4.
	scanline replaceFrom: 1 to: thisScanline size with: thisScanline startingAt: 1.
	hackDepth := bigEndian ifTrue:[form depth] ifFalse:[form depth negated].
	hack := Form extent: width@1 depth: hackDepth bits: scanline.
	hackBlt := BitBlt toForm: form.
	hackBlt sourceForm: hack.
	hackBlt combinationRule: Form over.
	hackBlt destOrigin: 0@y.
	hackBlt width: width; height: 1.

	(form depth < 8 and:[bigEndian not]) ifTrue:[
		swizzleHack := Form new hackBits: scanline.
		swizzleBlt := BitBlt toForm: swizzleHack.
		swizzleBlt sourceForm: swizzleHack.
		swizzleBlt combinationRule: Form over.
		swizzleBlt colorMap: (StandardSwizzleMaps at: form depth).
		swizzleBlt copyBits.
	].

	hackBlt copyBits! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 9/23/2012 21:45'!
copyPixelsIndexed: y at: startX by: incX
	"Handle interlaced indexed color mode (colorType = 3)"

	| offset bits pixPerByte shifts blitter pixel mask pixelNumber |
	offset := y*rowSize+1.
	bits := form bits.
	bitsPerChannel = 8
		ifTrue: [
			startX to: width-1 by: incX do: [ :x | | b w |
				w := offset + (x>>2).
				b := 3 - (x \\ 4) * 8.
				pixel := (thisScanline at: x // incX + 1)<<b.
				mask := (255<<b) bitInvert32.
				bits at: w put: (((bits at: w) bitAnd: mask) bitOr: pixel)].
			^ self ].
	bitsPerChannel = 1 ifTrue: [
		pixPerByte := 8.
		mask := 1.
		shifts := #(7 6 5 4 3 2 1 0).
	].
	bitsPerChannel = 2 ifTrue: [
		pixPerByte := 4.
		mask := 3.
		shifts := #(6 4 2 0).
	].
	bitsPerChannel = 4 ifTrue: [
		pixPerByte := 2.
		mask := 15.
		shifts := #(4 0).
	].

	blitter := BitBlt bitPokerToForm: form.
	pixelNumber := 0.
	startX to: width-1 by: incX do: [ :x | | rawByte |
		rawByte := thisScanline at: (pixelNumber // pixPerByte) + 1.
		pixel := (rawByte >> (shifts at: (pixelNumber \\ pixPerByte) + 1)) bitAnd: mask.
		blitter pixelAt: (x@y) put: pixel.
		pixelNumber := pixelNumber + 1.
	].
! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 1/24/2017 11:22:33'!
copyPixelsRGB: y
	"Handle non-interlaced RGB color mode (colorType = 2)"

	| i pixel tempForm tempBits |
	tempForm _ Form extent: width @ 1 depth: 32.
	tempBits _ tempForm bits.
	pixel _ LargePositiveInteger new: 4.
	pixel at: 4 put: 255.
	bitsPerChannel = 8
		ifTrue: [
			i _ 1.
			1 to: width do: [ :x |
				pixel
					at: 3 put: (thisScanline at: i);
					at: 2 put: (thisScanline at: i + 1);
					at: 1 put: (thisScanline at: i + 2).
				tempBits at: x put: pixel normalize.
				i _ i + 3 ].
			transparentPixelValue ifNotNil: [
				1 to: width do: [ :x |
					(tempBits at: x) = transparentPixelValue ifTrue: [
						tempBits at: x put: 0 ]]]]
		ifFalse: [
			i _ 1.
			1 to: width do: [ :x |
				(transparentPixelValue == nil or: [
					(1 to: 6) anySatisfy: [ :k |
						(transparentPixelValue digitAt: k) ~= (thisScanline at: i + 6 - k) ]])
					ifTrue: [
						pixel
							at: 3 put: (thisScanline at: i);
							at: 2 put: (thisScanline at: i + 2);
							at: 1 put: (thisScanline at: i + 4).
						tempBits at: x put: pixel normalize ]
					ifFalse: [
						tempBits at: x put: 0 ].
					i _ i + 6 ]].
	tempForm displayOn: form at: 0 @ y rule: Form over! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 1/24/2017 11:22:49'!
copyPixelsRGB: y at: startX by: incX
	"Handle interlaced RGB color mode (colorType = 2)"
	| i pixel tempForm tempBits xx loopsToDo |
	tempForm _ Form
		extent: width @ 1
		depth: 32.
	tempBits _ tempForm bits.
	pixel _ LargePositiveInteger new: 4.
	pixel
		at: 4
		put: 255.
	loopsToDo _ width - startX + incX - 1 // incX.
	bitsPerChannel = 8
		ifTrue: [
			i _ startX // incX * 3 + 1.
			xx _ startX + 1.
			1 to: loopsToDo do: [ :j |
				pixel
					at: 3 put: (thisScanline at: i);
					at: 2 put: (thisScanline at: i + 1);
					at: 1 put: (thisScanline at: i + 2).
				tempBits at: xx put: pixel normalize.
				i _ i + 3.
				xx _ xx + incX ].
			transparentPixelValue ifNotNil: [
				startX to: width - 1 by: incX do: [ :x |
					(tempBits at: x + 1) = transparentPixelValue ifTrue: [
						tempBits at: x + 1 put: 0 ]]]]
		ifFalse: [
			i _ startX // incX * 6 + 1.
			xx _ startX + 1.
			1 to: loopsToDo do: [ :j |
				(transparentPixelValue == nil or: [
					(1 to: 6) anySatisfy: [ :k |
						(transparentPixelValue digitAt: k) ~= (thisScanline at: i + 6 - k) ]])
					ifTrue: [
						pixel
							at: 3 put: (thisScanline at: i);
							at: 2 put: (thisScanline at: i + 2);
							at: 1 put: (thisScanline at: i + 4).
						tempBits at: xx put: pixel normalize ]
					ifFalse: [
						tempBits at: xx put: 0 ].
					i _ i + 6.
					xx _ xx + incX ]].
	tempForm displayOn: form at: 0 @ y rule: Form over! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 1/24/2017 11:23:10'!
copyPixelsRGBA: y
	"Handle non-interlaced RGBA color modes (colorType = 6)"

	| i pixel tempForm tempBits ff |
	bitsPerChannel = 8 ifTrue: [
		ff := Form extent: width@1 depth: 32 bits: thisScanline.
		cachedDecoderMap 
			ifNil:[cachedDecoderMap := self rgbaDecoderMapForDepth: depth].
		(BitBlt toForm: form)
			sourceForm: ff;
			destOrigin: 0@y;
			combinationRule: Form over;
			colorMap: cachedDecoderMap;
			copyBits.
		^self.
	].
	tempForm _ Form extent: width@1 depth: 32.
	tempBits _ tempForm bits.
	pixel := LargePositiveInteger new: 4.
	i := -7.
	0 to: width-1 do: [ :x |
			i := i + 8.
			pixel at: 4 put: (thisScanline at: i+6);
				at: 3 put: (thisScanline at: i);
				at: 2 put: (thisScanline at: i+2);
				at: 1 put: (thisScanline at: i+4).
			tempBits at: x+1 put: pixel normalize.
	].
	tempForm displayOn: form at: 0@y rule: Form over.
! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'jmv 1/24/2017 11:23:39'!
copyPixelsRGBA: y at: startX by: incX
	"Handle interlaced RGBA color modes (colorType = 6)"

	| i pixel tempForm tempBits |

	tempForm := Form extent: width@1 depth: 32.
	tempBits := tempForm bits.
	pixel := LargePositiveInteger new: 4.
	bitsPerChannel = 8 ifTrue: [
		i := (startX // incX << 2) + 1.
		startX to: width-1 by: incX do: [ :x |
			pixel at: 4 put: (thisScanline at: i+3);
				at: 3 put: (thisScanline at: i);
				at: 2 put: (thisScanline at: i+1);
				at: 1 put: (thisScanline at: i+2).
			tempBits at: x+1 put: pixel normalize.
			i := i + 4.
		]
	] ifFalse: [
		i := (startX // incX << 3) +1.
		startX to: width-1 by: incX do: [ :x |
			pixel at: 4 put: (thisScanline at: i+6);
				at: 3 put: (thisScanline at: i);
				at: 2 put: (thisScanline at: i+2);
				at: 1 put: (thisScanline at: i+4).
			tempBits at: x+1 put: pixel normalize.
			i := i + 8.
		].
	].
	tempForm displayOn: form at: 0@y rule: Form paintAlpha.

! !

!PNGReadWriter methodsFor: 'pixel copies' stamp: 'ar 2/19/2004 00:10'!
rgbaDecoderMapForDepth: decoderDepth
	bigEndian ifTrue:[
		depth = 16 ifTrue:[
			"Big endian, 32 -> 16 color mapping."
			^ColorMap
				shifts: #(-17 -14 -11 0)
				masks: #(16rF8000000 16rF80000 16rF800 16r00)
		] ifFalse:[
			"Big endian, 32 -> 32 color mapping"
			^ColorMap 
				shifts: #(-8 -8 -8 24) 
				masks: #(16rFF000000 16rFF0000 16rFF00 16rFF).
		].
	].
	depth = 16 ifTrue:[
		"Little endian, 32 -> 16 color mapping."
		^ColorMap
			shifts: #(7 -6 -19 0)
			masks: #(16rF8 16rF800 16rF80000 0)
	] ifFalse:[
		"Little endian, 32 -> 32 color mapping"
		^ColorMap 
			shifts: #(-16 0 16 0) 
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000).
	].! !

!PNGReadWriter methodsFor: 'accessing' stamp: 'RAA 11/7/2000 09:20'!
debugging

	^Debugging == true! !

!PNGReadWriter methodsFor: 'accessing' stamp: 'jmv 12/8/2020 16:33:59'!
nextImage
	bigEndian := Smalltalk isBigEndian.
	filtersSeen _ Bag new.
	globalDataChunk _ nil.
	transparentPixelValue _ nil.
	unknownChunks _ Set new.
	stream reset.
	stream skip: 8.
	[stream atEnd] whileFalse: [self processNextChunk].

	"Set up our form"
	(depth = 8 and: [ palette isNil ]) ifTrue: [
		form _ GrayForm extent: width@height
	] ifFalse: [
		(depth <= 8 and: [ palette notNil ]) ifTrue: [
			form := ColorForm extent: width@height nativeDepthFrom: depth.
			form colors: palette.
		] ifFalse:[
			form := Form extent: width@height depth: depth.
		]
	].

	backColor ifNotNil:[form fillColor: backColor].
	chunk _ globalDataChunk ifNil:[self error: 'image data is missing'].
	chunk ifNotNil: [self processIDATChunk].
	unknownChunks isEmpty ifFalse: [
		"Transcript show: ' ',unknownChunks asSortedCollection asArray printString."
	].
	self debugging ifTrue: [
		Transcript newLine; show: 'form = ',form printString.
		Transcript newLine; show: 'colorType = ',colorType printString.
		Transcript newLine; show: 'interlaceMethod = ',interlaceMethod printString.
		Transcript newLine; show: 'filters = ',filtersSeen sortedCounts asArray printString.
	].
	^ form
! !

!PNGReadWriter methodsFor: 'accessing' stamp: 'DSM 3/24/2000 01:12'!
understandsImageFormat
	#(137 80 78 71 13 10 26 10) do: [ :byte |
		stream next = byte ifFalse: [^ false]].
	^ true
! !

!PNGReadWriter methodsFor: 'miscellaneous' stamp: 'DSM 4/27/2000 13:09'!
doPass: pass
	"Certain interlace passes are skipped with certain small image
dimensions"

	pass = 1 ifTrue: [ ^ true ].
	((width = 1) and: [height = 1]) ifTrue: [ ^ false ].
	pass = 2 ifTrue: [ ^ width >= 5 ].
	pass = 3 ifTrue: [ ^ height >= 5 ].
	pass = 4 ifTrue: [ ^ (width >=3 ) or: [height >= 5] ].
	pass = 5 ifTrue: [ ^ height >=3 ].
	pass = 6 ifTrue: [ ^ width >=2 ].
	pass = 7 ifTrue: [ ^ height >=2 ].

! !

!PNGReadWriter methodsFor: 'miscellaneous' stamp: 'jmv 4/15/2010 10:19'!
grayColorsFor: d
	"return a color table for a gray image"

	palette _ Array new: 1<<d.
	d = 1 ifTrue: [
		palette at: 1 put: Color black.
		palette at: 2 put: Color white.
		^  palette
		].
	d = 2 ifTrue: [
		palette at: 1 put: Color black.
		palette at: 2 put: (Color gray: 85.0 / 255.0).
		palette at: 3 put: (Color gray: 170.0 / 255.0).
		palette at: 4 put: Color white.
		^ palette
		].
	d = 4 ifTrue: [
		0 to: 15 do: [ :g |
			palette at: g+1 put: (Color gray: (g/15) asFloat) ].
		^ palette
		].
	d = 8 ifTrue: [
		0 to: 255 do: [ :g |
			palette at: g+1 put: (Color gray: (g/255) asFloat) ].
		^ palette
		].
! !

!PNGReadWriter methodsFor: 'filtering' stamp: 'RAA 11/7/2000 09:43'!
filterAverage: count
	"Use the average of the pixel to the left and the pixel above as a predictor"

	| delta |
	delta _ bitsPerPixel // 8 max: 1.
	1 to: delta do: [:i |
		thisScanline at: i put: ((thisScanline at: i) + ((prevScanline at: i) // 2) bitAnd: 255)].
	delta + 1 to: count do: [:i |
		thisScanline at: i put:
			((thisScanline at: i)
			+ ((prevScanline at: i)
			+ (thisScanline at: i - delta) // 2) bitAnd: 255)]! !

!PNGReadWriter methodsFor: 'filtering' stamp: 'DSM 3/25/2000 17:54'!
filterHorizontal: count
	"Use the pixel to the left as a predictor"

	| delta |
	delta _ bitsPerPixel // 8 max: 1.
	delta+1 to: count do: [ :i |
		thisScanline at: i put: (((thisScanline at: i) +
(thisScanline at: i-delta)) bitAnd: 255) ]


! !

!PNGReadWriter methodsFor: 'filtering' stamp: 'DSM 3/25/2000 17:55'!
filterNone: count
! !

!PNGReadWriter methodsFor: 'filtering' stamp: 'RAA 11/7/2000 09:45'!
filterPaeth: count
	"Select one of (the pixel to the left, the pixel above and the pixel to above left) to
	predict the value of this pixel"

	| delta |
	delta _ bitsPerPixel // 8 max: 1.
	1 to: delta do: [ :i |
		thisScanline at: i put:
			(((thisScanline at: i) + (prevScanline at: i)) bitAnd: 255)].
	delta+1 to: count do: [ :i |
		thisScanline
			at: i
			put: (((thisScanline at: i) + (self
				paethPredictLeft: (thisScanline at: i-delta)
				above: (prevScanline at: i)
				aboveLeft: (prevScanline at: i-delta)))
					bitAnd: 255)]

! !

!PNGReadWriter methodsFor: 'filtering' stamp: 'eat 9/11/2000 20:08'!
filterScanline: filterType count: count

	self
		perform: (
			#(filterNone: filterHorizontal: filterVertical: filterAverage: filterPaeth:)
				at: filterType+1)
		with: count.

! !

!PNGReadWriter methodsFor: 'filtering' stamp: 'DSM 3/25/2000 17:54'!
filterVertical: count
	"Use the pixel above as a predictor"

	1 to: count do: [ :i |
		thisScanline at: i put: (((thisScanline at: i) +
(prevScanline at: i)) bitAnd: 255) ]

! !

!PNGReadWriter methodsFor: 'filtering' stamp: 'eat 9/11/2000 20:05'!
paethPredictLeft: a above: b aboveLeft: c
	"Predicts the value of a pixel based on nearby pixels, based on
Paeth (GG II, 1991)"

	| pa pb pc |
	pa _ b > c ifTrue: [b - c] ifFalse: [c - b].
	pb _ a > c ifTrue: [a - c] ifFalse: [c - a].
	pc _ a + b - c - c.
	pc < 0 ifTrue: [
		pc := pc * -1].
	((pa <= pb) and: [pa <= pc]) ifTrue: [^ a].
	(pb <= pc) ifTrue: [^ b].
	^ c
! !

!PNGReadWriter methodsFor: 'writing' stamp: 'ar 12/12/2003 16:37'!
nextPutImage: aForm
	"Write out the given form. We're keeping it simple here, no interlacing, no filters."
	^self nextPutImage: aForm interlace: 0 filter: 0. "no filtering"! !

!PNGReadWriter methodsFor: 'writing' stamp: 'jmv 5/13/2016 14:48'!
nextPutImage: aForm interlace: aMethod filter: aFilterType
	"Note: For now we keep it simple - interlace and filtering are simply ignored"
	| crcStream |
	bigEndian := Smalltalk isBigEndian.
	form := aForm.
	width := aForm width.
	height := aForm height.
	(aForm is: #GrayForm) ifTrue: [
		bitsPerChannel := aForm depth.
		colorType := 0.
		bytesPerScanline _ width * aForm depth + 7 // 8.
	] ifFalse: [
		aForm depth <= 8 ifTrue: [
			bitsPerChannel := aForm depth.
			colorType := 3.
			bytesPerScanline _ width * aForm depth + 7 // 8.
		] ifFalse: [
			bitsPerChannel := 8.
			colorType := 6.
			bytesPerScanline _ width * 4.
		]
	].

	self writeFileSignature.

	crcStream := WriteStream on: (ByteArray new: 1000).
	crcStream resetToStart.
	self writeIHDRChunkOn: crcStream.
	self writeChunk: crcStream.

	(form depth <= 8 and: [(aForm is: #GrayForm) not]) ifTrue:[
		crcStream resetToStart.
		self writePLTEChunkOn: crcStream.
		self writeChunk: crcStream.
		(form is: #ColorForm) ifTrue: [
			crcStream resetToStart.
			self writeTRNSChunkOn: crcStream.
			self writeChunk: crcStream.
		].
	].

	form depth = 16 ifTrue:[
		crcStream resetToStart.
		self writeSBITChunkOn: crcStream.
		self writeChunk: crcStream.
	].

	crcStream resetToStart.
	self writeIDATChunkOn: crcStream.
	self writeChunk: crcStream.

	crcStream resetToStart.
	self writeIENDChunkOn: crcStream.
	self writeChunk: crcStream.! !

!PNGReadWriter methodsFor: 'writing' stamp: 'Representar 3/14/2024 15:12:33'!
updateCrc: oldCrc from: start to: stop in: aCollection
	^ZipWriteStream updateCrc: oldCrc from: start to: stop in: aCollection! !

!PNGReadWriter methodsFor: 'writing' stamp: 'ARM 6/22/2025 20:38:21'!
writeChunk: crcStream
	| bytes length crc debug |
	debug := self debugging.
	bytes := crcStream originalContents.
	length := crcStream position.
	crc := self updateCrc: 16rFFFFFFFF from: 1 to: length in: bytes.
	crc := crc bitXor: 16rFFFFFFFF.
	debug ifTrue: [
		Transcript newLine;
			print: stream position; space;
			nextPutAll: (bytes copyFrom: 1 to: 4) asString;
			nextPutAll: ' len='; print: length;
			nextPutAll: ' crc=0x'; nextPutAll: crc printStringHex  ].
	stream nextUint32Put: length-4 bigEndian: true. "exclude chunk name"
	stream next: length putAll: bytes startingAt: 1.
	stream nextUint32Put: crc bigEndian: true.
	debug ifTrue: [ Transcript nextPutAll: ' afterPos='; print: stream position ].
	crcStream resetToStart.! !

!PNGReadWriter methodsFor: 'writing' stamp: 'nice 1/18/2010 18:08'!
writeFileSignature
	stream nextPutAll: #[ 16r89 16r50 16r4E  16r47 16r0D 16r0A 16r1A 16r0A ]! !

!PNGReadWriter methodsFor: 'writing' stamp: 'jmv 3/12/2017 19:19:47'!
writeIDATChunkOn: aStream
	"Write the IDAT chunk"
	| z |
	aStream nextPutAll: 'IDAT' asByteArray.

	"Avoid growing multiple times. do a rough estimation of space needed"
	aStream growTo: bytesPerScanline * height *11//20.

	z _ ZLibWriteStream on: aStream.
	form depth <= 8 
		ifTrue: [ 
			"Same format for type 3 (indexed color) and type 0 (grayscale, GrayForm)"
			self writeType3DataOn: z ]
		ifFalse: [ self writeType6DataOn: z ].
	z close.
	self debugging ifTrue: [
		Transcript newLine;
			nextPutAll: 'compressed size=';
			print: aStream position;
			nextPutAll: ' uncompressed size=';
			print: z position ]! !

!PNGReadWriter methodsFor: 'writing' stamp: 'ar 12/12/2003 17:08'!
writeIENDChunkOn: aStream
	"Write the IEND chunk"
	aStream nextPutAll: 'IEND' asByteArray.! !

!PNGReadWriter methodsFor: 'writing' stamp: 'ARM 6/22/2025 20:55:01'!
writeIHDRChunkOn: aStream
	"Write the IHDR chunk"
	aStream nextPutAll: 'IHDR' asByteArray.
	aStream nextInt32Put: width bigEndian: true.
	aStream nextInt32Put: height bigEndian: true.
	aStream nextPut: bitsPerChannel.
	aStream nextPut: colorType.
	aStream nextPut: 0. "compression"
	aStream nextPut: 0. "filter method"
	aStream nextPut: 0. "interlace method"
! !

!PNGReadWriter methodsFor: 'writing' stamp: 'jmv 12/8/2020 16:35:46'!
writePLTEChunkOn: aStream
	"Write the PLTE chunk.
	Ignore any form of translucency."
	| r g b colors |
	aStream nextPutAll: 'PLTE' asByteArray.
	(form is: #ColorForm) 
		ifTrue: [ colors := form colors]
		ifFalse: [ colors := Color indexedColors copyFrom: 1 to: (1 bitShift: form depth)].
	colors do: [ :aColor |
		r := (aColor red * 255) truncated.
		g := (aColor green * 255) truncated.
		b := (aColor blue * 255) truncated.
		aStream nextPut: r; nextPut: g; nextPut: b.
	].! !

!PNGReadWriter methodsFor: 'writing' stamp: 'ar 12/12/2003 18:29'!
writeSBITChunkOn: aStream
	"Write the IDAT chunk"
	aStream nextPutAll: 'sBIT' asByteArray.
	form depth = 16 ifFalse:[self error: 'Unimplemented feature'].
	aStream nextPut: 5.
	aStream nextPut: 5.
	aStream nextPut: 5.
	aStream nextPut: 1.! !

!PNGReadWriter methodsFor: 'writing' stamp: 'ar 12/12/2003 17:34'!
writeTRNSChunkOn: aStream
	"Write out tRNS chunk"
	aStream nextPutAll: 'tRNS' asByteArray.
	form colors do:[:aColor|
		aStream nextPut: (aColor alpha * 255) truncated.
	].! !

!PNGReadWriter methodsFor: 'writing' stamp: 'jmv 10/3/2015 14:18'!
writeType3DataOn: zStream
	"Write color indexed data."
	| scanline hack hackBlt swizzleBlt swizzleHack hackDepth |
	scanline := ByteArray new: bytesPerScanline + 3 // 4 * 4.
	hackDepth := bigEndian ifTrue:[form depth] ifFalse:[form depth negated].
	hack := Form extent: width@1 depth: hackDepth bits: scanline.
	hackBlt := BitBlt toForm: hack.
	hackBlt sourceForm: form.
	hackBlt combinationRule: Form over.
	hackBlt destOrigin: 0@0.
	hackBlt width: width; height: 1.
	(form depth < 8 and:[bigEndian not]) ifTrue:[
		swizzleHack := Form new hackBits: scanline.
		swizzleBlt := BitBlt toForm: swizzleHack.
		swizzleBlt sourceForm: swizzleHack.
		swizzleBlt combinationRule: Form over.
		swizzleBlt colorMap: (StandardSwizzleMaps at: form depth).
	].
	0 to: height-1 do:[:i|
		hackBlt sourceOrigin: 0@i; copyBits.
		swizzleBlt ifNotNil:[swizzleBlt copyBits].
		zStream nextPut: 0. "filterType"
		zStream next: bytesPerScanline putAll: scanline startingAt: 1.
	]! !

!PNGReadWriter methodsFor: 'writing' stamp: 'jmv 10/3/2015 14:19'!
writeType6DataOn: zStream
	"Write RGBA data."
	| scanline hack hackBlt cm miscBlt |
	scanline := ByteArray new: bytesPerScanline.
	hack := Form extent: width@1 depth: 32 bits: scanline.
	form depth = 16 ifTrue:[
		"Expand 16 -> 32"
		miscBlt := BitBlt toForm: hack.
		miscBlt sourceForm: form.
		miscBlt combinationRule: Form over.
		miscBlt destOrigin: 0@0.
		miscBlt width: width; height: 1.
	].
	hackBlt := BitBlt toForm: hack.
	hackBlt sourceForm: (miscBlt ifNil:[form] ifNotNil:[hack]).
	hackBlt combinationRule: Form over.
	hackBlt destOrigin: 0@0.
	hackBlt width: width; height: 1.
	bigEndian ifTrue:[
		cm := ColorMap 
			shifts: #(8 8 8 -24) 
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000).
	] ifFalse:[
		cm := ColorMap 
			shifts: #(-16 0 16 0) 
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000).
	].
	hackBlt colorMap: cm.
	0 to: height-1 do:[:i|
		miscBlt ifNil:[
			hackBlt sourceOrigin: 0@i; copyBits.
		] ifNotNil:[
			miscBlt sourceOrigin: 0@i; copyBits.
			hack fixAlpha.
			hackBlt copyBits.
		].
		zStream nextPut: 0. "filterType"
		zStream nextPutAll: scanline.
	]! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'ar 2/10/2004 23:55'!
processBackgroundChunk

	| val red green blue max |

	"Transcript show: '  BACKGROUND: ',chunk printString."
	colorType = 3 ifTrue: [
		backColor := palette at: chunk first + 1.
		^self
	].
	max _ (2 raisedTo: bitsPerChannel) - 1.
	(colorType = 0 or: [colorType = 4]) ifTrue: [
		val _ chunk unsignedShortAt: 1 bigEndian: true.
		backColor := Color gray: val / max.
		^self
	].
	(colorType = 2 or: [colorType = 6]) ifTrue: [
		red _ chunk unsignedShortAt: 1 bigEndian: true.
		green _ chunk unsignedShortAt: 3 bigEndian: true.
		blue _ chunk unsignedShortAt: 5 bigEndian: true.
		backColor := Color r: red/max g: green/max b: blue/max.
		^self
	].
"self halt."

"====
The bKGD chunk specifies a default background color to present the image against. Note that viewers are not bound to honor this chunk; a viewer can choose to use a different background. 

For color type 3 (indexed color), the bKGD chunk contains: 


   Palette index:  1 byte

The value is the palette index of the color to be used as background. 

For color types 0 and 4 (grayscale, with or without alpha), bKGD contains: 


   Gray:  2 bytes, range 0 .. (2^bitdepth)-1

(For consistency, 2 bytes are used regardless of the image bit depth.) The value is the gray level to be used as background. 

For color types 2 and 6 (truecolor, with or without alpha), bKGD contains: 


   Red:   2 bytes, range 0 .. (2^bitdepth)-1
   Green: 2 bytes, range 0 .. (2^bitdepth)-1
   Blue:  2 bytes, range 0 .. (2^bitdepth)-1

(For consistency, 2 bytes per sample are used regardless of the image bit depth.) This is the RGB color to be used as background. 

When present, the bKGD chunk must precede the first IDAT chunk, and must follow the PLTE chunk, if any. 
==="
! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'RAA 11/4/2000 17:00'!
processIDATChunk

	interlaceMethod = 0
		ifTrue: [ self processNonInterlaced ]
		ifFalse: [ self processInterlaced ]
! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'ARM 6/22/2025 20:40:54'!
processIHDRChunk
	width := chunk uint32At: 1 bigEndian: true.
	height := chunk uint32At: 5 bigEndian: true.
	bitsPerChannel := chunk at: 9.
	colorType := chunk at: 10.
	"compression _ chunk at: 11." "TODO - validate compression"
	"filterMethod _ chunk at: 12." "TODO - validate filterMethod"
	interlaceMethod := chunk at: 13. "TODO - validate interlace method"
	(#(2 4 6) includes: colorType)
		ifTrue: [depth := 32].
	(colorType = 0 and: [ bitsPerChannel = 8 ]) ifTrue: [
		depth := 8.
		palette := nil.		"Meaning: 'please use a GrayForm'"
	] ifFalse: [
		(#(0 3) includes: colorType) ifTrue: [
			depth := bitsPerChannel min: 8.
			colorType = 0 ifTrue: [ "grayscale"
				palette := self grayColorsFor: depth ]]].
	bitsPerPixel := (BPP at: colorType+1) at: bitsPerChannel highBit.
	bytesPerScanline := width * bitsPerPixel + 7 // 8.
	rowSize := width * depth + 31 >> 5.
! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'nice 12/26/2009 19:05'!
processInterlaced
	| z startingCol colIncrement rowIncrement startingRow |
	startingCol := #(0 4 0 2 0 1 0 ).
	colIncrement := #(8 8 4 4 2 2 1 ).
	rowIncrement := #(8 8 8 4 4 2 2 ).
	startingRow := #(0 0 4 0 2 0 1 ).
	z := ZLibReadStream on: chunk from: 1 to: chunk size.
	1 to: 7 do: [:pass |
		| cx sc bytesPerPass |
		(self doPass: pass)
			ifTrue:
				[cx := colIncrement at: pass.
				sc := startingCol at: pass.
				bytesPerPass := width - sc + cx - 1 // cx * bitsPerPixel + 7 // 8.
				prevScanline := ByteArray new: bytesPerPass.
				thisScanline := ByteArray new: bytesPerScanline.
				(startingRow at: pass)
					to: height - 1
					by: (rowIncrement at: pass)
					do: [:y |
						| filter temp |
						filter := z next.
						filtersSeen add: filter.
						(filter isNil or: [(filter between: 0 and: 4) not])
							ifTrue: [^ self].
						thisScanline := z next: bytesPerPass into: thisScanline startingAt: 1.
						self filterScanline: filter count: bytesPerPass.
						self copyPixels: y at: sc by: cx.
						temp := prevScanline.
						prevScanline := thisScanline.
						thisScanline := temp.
					]
				]
	].
	z atEnd ifFalse:[self error:'Unexpected data'].! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'ARM 6/22/2025 20:38:50'!
processNextChunk

	| length chunkType crc chunkCrc |

	length := self nextUint32.
	chunkType := (self next: 4) asString.

	"If someone appended garbage at the end of the file, don't let that bite us."
	fileSize - self position < length ifTrue: [
		unknownChunks add: chunkType.
		stream setToEnd.
		^self ].

	chunk := self next: length.
	chunkCrc := self nextUint32 bitXor: 16rFFFFFFFF.
	crc := self updateCrc: 16rFFFFFFFF from: 1 to: 4 in: chunkType.
	crc := self updateCrc: crc from: 1 to: length in: chunk.
	crc = chunkCrc ifFalse:[
		self error: 'PNGReadWriter crc error in chunk ', chunkType.
	].

	chunkType = 'IEND' ifTrue: [^self	"*should* be the last chunk"].
	chunkType = 'sBIT' ifTrue: [^self processSBITChunk "could indicate unusual sample depth in original"].
	chunkType = 'gAMA' ifTrue: [^self 	"indicates gamma correction value"].
	chunkType = 'bKGD' ifTrue: [^self processBackgroundChunk].
	chunkType = 'pHYs' ifTrue: [^self processPhysicalPixelChunk].
	chunkType = 'tRNS' ifTrue: [^self processTransparencyChunk].

	chunkType = 'IHDR' ifTrue: [^self processIHDRChunk].
	chunkType = 'PLTE' ifTrue: [^self processPLTEChunk].
	chunkType = 'IDAT' ifTrue: [
		"---since the compressed data can span multiple
		chunks, stitch them all together first. later,
		if memory is an issue, we need to figure out how
		to do this on the fly---"
		globalDataChunk := globalDataChunk ifNil: [chunk] ifNotNil:
			[globalDataChunk,chunk].
		^self
	].
	unknownChunks add: chunkType.
! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'jmv 3/13/2012 12:42'!
processNonInterlaced
	| z filter temp copyMethod debug |
	debug := self debugging.
	copyMethod _ #(copyPixelsGray: nil copyPixelsRGB: copyPixelsIndexed:
		  copyPixelsGrayAlpha: nil copyPixelsRGBA:) at: colorType+1.
	debug ifTrue: [ Transcript newLine; nextPutAll: 'NI chunk size='; print: chunk size ].
	z _ ZLibReadStream on: chunk from: 1 to: chunk size.
	prevScanline _ ByteArray new: bytesPerScanline.
	thisScanline := ByteArray new: bytesPerScanline.	

	(colorType = 0 and: [ bitsPerChannel < 16]) ifTrue: [
		auxSource _ Form extent: 1 @ (thisScanline size // 4) depth: 32 bits: thisScanline.
		auxDest _ Form extent: 1 @ (form bits size) depth: 32 bits: form bits.
		auxCMap _ Smalltalk isLittleEndian
			ifTrue:[ColorMap 
					shifts: #(-24 -8 8 24) 
					masks: #(16rFF000000 16r00FF0000 16r0000FF00 16r000000FF)].
		auxBitBlt _ (BitBlt toForm: auxDest)
			sourceForm: auxSource;
			colorMap: auxCMap;
			combinationRule: 3 ].

	0 to: height-1 do: [ :y |
		filter _ (z next: 1) first.
		debug ifTrue:[filtersSeen add: filter].
		thisScanline _ z next: bytesPerScanline into: thisScanline startingAt: 1.
		(debug and: [ thisScanline size < bytesPerScanline ]) ifTrue: [
			Transcript nextPutAll: ('wanted {1} but only got {2}' format: { bytesPerScanline. thisScanline size }); newLine ].
		filter = 0 ifFalse:[self filterScanline: filter count: bytesPerScanline].
		self perform: copyMethod with: y.
		temp := prevScanline.
		prevScanline := thisScanline.
		thisScanline := temp.
		].
	z atEnd ifFalse:[self error:'Unexpected data'].
	debug ifTrue: [Transcript  nextPutAll: ' compressed size='; print: z position  ].
! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'ar 2/11/2004 01:02'!
processPLTEChunk

	| colorCount i |

	colorCount _ chunk size // 3. "TODO - validate colorCount against depth"
	palette _ Array new: colorCount.
	0 to: colorCount-1 do: [ :index |
		i _ index * 3 + 1.
		palette at: index+1 put:
			(Color r: (chunk at: i)/255.0 g: (chunk at: i+1)/255.0 b: (chunk at: i+2)/255.0)
		].! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'RAA 11/5/2000 11:24'!
processPhysicalPixelChunk

	"Transcript show: '  PHYSICAL: ',chunk printString."
! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'ar 12/12/2003 18:33'!
processSBITChunk
	| rBits gBits bBits aBits |
	colorType = 6 ifFalse:[^self].
	rBits := chunk at: 1.
	gBits := chunk at: 2.
	bBits := chunk at: 3.
	aBits := chunk at: 4.
	(rBits = 5 and:[gBits = 5 and:[bBits = 5 and:[aBits = 1]]]) ifTrue:[
		depth := 16.
	].! !

!PNGReadWriter methodsFor: 'chunks' stamp: 'jmv 1/18/2017 11:52:19'!
processTransparencyChunk

	"Transcript show: '  TRANSPARENCY ',chunk printString."
	colorType = 0 ifTrue: [
		transparentPixelValue _ chunk unsignedShortAt: 1 bigEndian: true.
		bitsPerChannel <= 8
			ifTrue: [
				"If palette is nil, we are building a GrayForm from a grayscale 8bpp file. Ignore any transparency chunk!!"
				palette ifNotNil: [
					palette at: transparentPixelValue + 1 put: Color transparent ]]
			ifFalse: [
				palette at: 1 put: Color transparent ].
		^ self ].
	colorType = 2 ifTrue: [
		| red green blue |
		red _ chunk unsignedShortAt: 1 bigEndian: true.
		green _ chunk unsignedShortAt: 3 bigEndian: true.
		blue _ chunk unsignedShortAt: 5 bigEndian: true.
		transparentPixelValue _ bitsPerChannel <= 8
			ifTrue: [ 16rFF00 + red << 8 + green << 8 + blue ]
			ifFalse: [ red << 16 + green << 16 + blue ].
		^ self ].
	colorType = 3 ifTrue: [
		chunk withIndexDo: [ :alpha :index |
			palette at: index put: ((palette at: index) alpha: alpha / 255) ].
		^ self ]! !

!PNGReadWriter class methodsFor: 'as yet unclassified' stamp: 'ar 2/11/2004 00:54'!
computeSwizzleMapForDepth: depth
	"Answer a map that maps pixels in a word to their opposite location. Used for 'middle-endian' forms where the byte-order is different from the bit order (good joke, eh?)."
	| map swizzled |
	map := Bitmap new: 256.
	depth = 4 ifTrue:[
		0 to: 255 do:[:pix|
			swizzled := 0.
			swizzled := swizzled bitOr: (((pix bitShift: 0) bitAnd: 15) bitShift: 4).
			swizzled := swizzled bitOr: (((pix bitShift: -4) bitAnd: 15) bitShift: 0).
			map at: pix+1 put: swizzled.
		].
		^ColorMap colors: map
	].

	depth = 2 ifTrue:[
		0 to: 255 do:[:pix|
			swizzled := 0.
			swizzled := swizzled bitOr: (((pix bitShift: 0) bitAnd: 3) bitShift: 6).
			swizzled := swizzled bitOr: (((pix bitShift: -2) bitAnd: 3) bitShift: 4).
			swizzled := swizzled bitOr: (((pix bitShift: -4) bitAnd: 3) bitShift: 2).
			swizzled := swizzled bitOr: (((pix bitShift: -6) bitAnd: 3) bitShift: 0).
			map at: pix+1 put: swizzled.
		].
		^ColorMap colors: map
	].

	depth = 1 ifTrue:[
		0 to: 255 do:[:pix|
			swizzled := 0.
			swizzled := swizzled bitOr: (((pix bitShift: 0) bitAnd: 1) bitShift: 7).
			swizzled := swizzled bitOr: (((pix bitShift: -1) bitAnd: 1) bitShift: 6).
			swizzled := swizzled bitOr: (((pix bitShift: -2) bitAnd: 1) bitShift: 5).
			swizzled := swizzled bitOr: (((pix bitShift: -3) bitAnd: 1) bitShift: 4).
			swizzled := swizzled bitOr: (((pix bitShift: -4) bitAnd: 1) bitShift: 3).
			swizzled := swizzled bitOr: (((pix bitShift: -5) bitAnd: 1) bitShift: 2).
			swizzled := swizzled bitOr: (((pix bitShift: -6) bitAnd: 1) bitShift: 1).
			swizzled := swizzled bitOr: (((pix bitShift: -7) bitAnd: 1) bitShift: 0).
			map at: pix+1 put: swizzled.
		].
		^ColorMap colors: map
	].
	self error: 'Unrecognized depth'! !

!PNGReadWriter class methodsFor: 'as yet unclassified' stamp: 'RAA 11/7/2000 09:20'!
debugging: aBoolean

	Debugging _ aBoolean! !

!PNGReadWriter class methodsFor: 'as yet unclassified' stamp: 'jmv 12/8/2020 16:34:09'!
initialize
	"
	PNGReadWriter initialize
	"

	BPP _ {	#(1 2 4 8 16).
			#(0 0 0 0 0).
			#(0 0 0 24 48).
			#(1 2 4 8 0).
			#(0 0 0 16 32).
			#(0 0 0 0 0).
			#(0 0 0 32 64).
			#(0 0 0 0 0) }.

	BlockHeight _ #(8 8 4 4 2 2 1).
	BlockWidth _ #(8 4 4 2 2 1 1).

	StandardSwizzleMaps := Array new: 4.
	#(1 2 4) do:[:i| StandardSwizzleMaps at: i put: (self computeSwizzleMapForDepth: i)].! !

!PNGReadWriter class methodsFor: 'image reading/writing' stamp: 'nk 7/16/2003 17:57'!
typicalFileExtensions
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#('png')! !

!AiChatTesterWindow methodsFor: 'initialization' stamp: 'ARM 6/21/2025 19:09:19'!
build

	self layoutMorph beColumn;
		addMorph: self buildConversationTextSpace proportionalHeight: 0.75;
		addAdjusterAndMorph: self buildInputSpace proportionalHeight: 0.25.! !

!AiChatTesterWindow methodsFor: 'initialization' stamp: 'ARM 6/21/2025 19:09:19'!
buildConversationTextSpace

		conversationTextSpace _ TextModelMorph textProvider: self model
							textGetter: #conversationText
							textSetter: #conversationText:.
		conversationTextSpace disableEditing.
							
		^conversationTextSpace! !

!AiChatTesterWindow methodsFor: 'initialization' stamp: 'ARM 6/21/2025 19:09:19'!
buildInputSpace

		| inputButton |
		
		inputLayout _ LayoutMorph newRow.
		
		inputTextSpace _ TextModelMorph textProvider: self model
							textGetter: #inputText
							textSetter: #inputText:.
							
		inputButton _ PluggableButtonMorph
						model: self
						stateGetter: nil
						action: #askQuestionFromTextSpace
						label: 'Ask'.
						
		inputLayout addMorph: inputTextSpace proportionalWidth: 0.9;
		addMorph: inputButton proportionalWidth: 0.1.
							
		^inputLayout! !

!AiChatTesterWindow methodsFor: 'initialization' stamp: 'Representar 6/22/2025 17:16:29'!
initializeForModelName: modelName andApiConnector: anApiConnector

	self setLabel: modelName, ' Tester'.
	apiConnector _ anApiConnector.
	self model: (AiChatTesterModel forModelName: modelName).
	self build.! !

!AiChatTesterWindow methodsFor: 'question asked' stamp: 'ARM 6/22/2025 20:58:39'!
askQuestionFromTextSpace
	| questionToAsk responses |
	questionToAsk := inputTextSpace model actualContents asString withBlanksTrimmed.
	model addQuestionToConversation: questionToAsk.
	conversationTextSpace updateAcceptedContents.
	
	[responses := apiConnector responseReaderAfterSendingPrompt: questionToAsk.
	model addAnswerToConversation: responses first.
	(ImageMorph new image: responses second) openInWorld.
	conversationTextSpace updateAcceptedContents.] forkAt: 15.
! !

!AiChatTesterWindow class methodsFor: 'instance-creation' stamp: 'Representar 6/22/2025 18:43:32'!
openDalle2
	
	^self openWithApiConnector:
		(AiApiConnector withRequestMaker: AiApiRequestMaker dalle2
			responseReader: AiApiResponseReader dalle2
			webClientClass: WebClient)
		forModelName: 'Dall-e 2'
! !

!AiChatTesterWindow class methodsFor: 'instance-creation' stamp: 'Representar 6/22/2025 18:43:32'!
openDalle3
	
	^self openWithApiConnector:
		(AiApiConnector withRequestMaker: AiApiRequestMaker dalle3
			responseReader: AiApiResponseReader dalle3
			webClientClass: WebClient)
		forModelName: 'Dall-e 3'
! !

!AiChatTesterWindow class methodsFor: 'instance-creation' stamp: 'Representar 6/22/2025 18:43:32'!
openGptImage1
	
	^self openWithApiConnector:
		(AiApiConnector withRequestMaker: AiApiRequestMaker gptImage1
			responseReader: AiApiResponseReader gptImage1
			webClientClass: WebClient)
		forModelName: 'Gpt Image 1'
! !

!AiChatTesterWindow class methodsFor: 'instance-creation' stamp: 'Representar 6/22/2025 17:16:54'!
openWithApiConnector: anApiConnector forModelName: windowTitle 
	
	^self new initializeForModelName: windowTitle andApiConnector: anApiConnector;
		openInWorld; morphPosition: 64.0@150.0 extent: 663.0@586.0; yourself 
! !

!AiChatTesterWindow class methodsFor: 'instance-creation' stamp: 'Representar 6/22/2025 18:25:19'!
worldMenuOptions 

	^{
		{
		#itemGroup 	-> 		2.
		#itemOrder 		-> 		1.
		#label 			-> 		'Gpt Image 1 Tester'.
		#selector 		-> 		#openGptImage1.
		#object 			-> 		self.
		#icon 			-> 		#editFindReplaceIcon.
		#balloonText 	-> 		'Gpt Image 1 Tester'.
	} asDictionary.
	{
		#itemGroup 	-> 		2.
		#itemOrder 		-> 		1.
		#label 			-> 		'Dalle 3 Tester'.
		#selector 		-> 		#openDalle3.
		#object 			-> 		self.
		#icon 			-> 		#editFindReplaceIcon.
		#balloonText 	-> 		'Dalle 3 Tester'.
	} asDictionary.
	{
		#itemGroup 	-> 		2.
		#itemOrder 		-> 		1.
		#label 			-> 		'Dalle 2 Tester'.
		#selector 		-> 		#openDalle2.
		#object 			-> 		self.
		#icon 			-> 		#editFindReplaceIcon.
		#balloonText 	-> 		'Dalle 2 Tester'.
	} asDictionary.
	}! !

!AiApiTest methodsFor: 'testing' stamp: 'Representar 6/22/2025 19:39:15'!
test01Dalle2HttpConnection

	| connector responses |

	connector _ AiApiConnector withRequestMaker: AiApiRequestMaker dalle2
			responseReader: AiApiResponseReader dalle2
			webClientClass: self.
			
	predefinedResponse _ self predefinedResponseDalle2.
			
	responses _ connector responseReaderAfterSendingPrompt: self defaultPrompt.
	
	self assert: responses first equals: self dalleResultingImageLink.
	self assert: responses second equals: self defaultImageResult
	! !

!AiApiTest methodsFor: 'testing' stamp: 'Representar 6/22/2025 19:45:54'!
test02Dalle3HttpConnection

	| connector responses |

	connector _ AiApiConnector withRequestMaker: AiApiRequestMaker dalle3
			responseReader: AiApiResponseReader dalle3
			webClientClass: self.
			
	predefinedResponse _ self predefinedResponseDalle3.
			
	responses _ connector responseReaderAfterSendingPrompt: self defaultPrompt.
	
	self assert: responses first equals: self dalle3RevisedPrompt.
	self assert: responses second equals: self defaultImageResult
	! !

!AiApiTest methodsFor: 'testing' stamp: 'Representar 6/22/2025 20:17:07'!
test03GptImage1HttpConnection

	| connector responses |

	connector _ AiApiConnector withRequestMaker: AiApiRequestMaker gptImage1 
			responseReader: AiApiResponseReader gptImage1
			webClientClass: self.
			
	predefinedResponse _ self predefinedResponseGptImage1.
			
	responses _ connector responseReaderAfterSendingPrompt: self defaultPrompt.
	
	self assert: responses first equals: (WebUtils jsonDecode: (ReadStream on: self gptImage1Usage)) asString.
	self assert: responses second equals: self defaultImageResult
	! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 19:44:18'!
dalle3RevisedPrompt

	^'A South Asian boy joyfully riding a bright red bicycle. He has a wide grin on his face, showcasing his excitement as he pedals down a winding path surrounded by lush green fields under the radiant sunshine.'! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 19:37:17'!
dalleResultingImageLink

	^'https://oaidalleapiprodscus.blob.core.windows.net/private/org-qL4pKzHzE12RgjiRL1Pg1P7v/user-naYJCWS6Jsym04e4VEuPJfH4/img-WHjzkVULLPb3JV6dh5a07N0u.png?st=2025-06-22T21%3A15%3A58Z&se=2025-06-22T23%3A15%3A58Z&sp=r&sv=2024-08-04&sr=b&rscd=inline&rsct=image/png&skoid=8b33a531-2df9-46a3-bc02-d4b1430a422c&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2025-06-22T22%3A15%3A58Z&ske=2025-06-23T22%3A15%3A58Z&sks=b&skv=2024-08-04&sig=gjoJkIzwbO/GFlLWePwWMFkn%2B%2BJdMVMGi92z/vXi4mk%3D'! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 19:38:53'!
defaultImageResult

	^ Form extent: 1@1 depth: 32! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 18:54:40'!
defaultPrompt

	^'chico en bicicleta'
	! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 20:11:29'!
gptImage1Usage

	^'{
    "input_tokens": 10,
    "input_tokens_details": {
      "image_tokens": 0,
      "text_tokens": 10
    },
    "output_tokens": 272,
    "total_tokens": 282
  }'! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 20:08:46'!
gptResultImageBase64

	^(PNGReadWriter bytesFor: self defaultImageResult) base64Encoded! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 19:37:33'!
predefinedResponseDalle2

	| response |
	
	response _ WebResponse forTestingPurposesWithCode: 200 content: '{
  "created": 1750630558,
  "data": [
    {
      "url": "', self dalleResultingImageLink , '"
    }
  ]
}'.

	^response! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 19:44:44'!
predefinedResponseDalle3

	| response |
	
	response _ WebResponse forTestingPurposesWithCode: 200 content: '{
  "created": 1750632116,
  "data": [
    {
      "revised_prompt": "', self dalle3RevisedPrompt ,'",
      "url": "' , self dalleResultingImageLink , '"
    }
  ]
}'.

	^response! !

!AiApiTest methodsFor: 'test objects' stamp: 'Representar 6/22/2025 20:11:54'!
predefinedResponseGptImage1

	| response |
	
	response _ WebResponse forTestingPurposesWithCode: 200 content: '{
  "created": 1750632466,
  "background": "transparent",
  "data": [
    {
      "b64_json": "', self gptResultImageBase64 , '"}
  ],
  "output_format": "png",
  "quality": "low",
  "size": "1024x1024",
  "usage": ', self gptImage1Usage ,'
}'.

	^response! !

!AiApiTest methodsFor: 'simulation' stamp: 'Representar 6/22/2025 19:39:03'!
httpGet: url 
	^WebResponse forTestingPurposesWithCode: 200
		content: (PNGReadWriter bytesFor: self defaultImageResult) asString! !

!AiApiTest methodsFor: 'simulation' stamp: 'Representar 6/22/2025 19:07:12'!
httpPost: urlString content: postData type: contentType do: aBlock

	^predefinedResponse
! !

!AiApiTest methodsFor: 'simulation' stamp: 'Representar 6/22/2025 19:25:19'!
new
	^self! !

!AiApiConnector methodsFor: 'communication' stamp: 'ARM 6/22/2025 21:30:16'!
extractErrorMessageFrom: webResponse

	^ webResponse status,
		'. ',
		((((WebUtils jsonDecode: (ReadStream on: webResponse content)) at: 'error') at: 'message') first: 17),
		'...'! !

!AiApiConnector methodsFor: 'communication' stamp: 'Representar 6/22/2025 18:44:10'!
newWebClient

	^webClientClass new! !

!AiApiConnector methodsFor: 'communication' stamp: 'ARM 6/22/2025 21:30:00'!
responseReaderAfterSendingPrompt: aQuestionReceived

	| webResponse |
	webResponse := apiRequestMaker sendTextPrompt: aQuestionReceived throughWebClient: self newWebClient.
	webResponse isSuccess ifFalse:
		[self error: (self extractErrorMessageFrom: webResponse)].	
	^apiResponseReader extractGenetedOutputFrom: webResponse withWebClient: self newWebClient.! !

!AiApiConnector methodsFor: 'initialization' stamp: 'Representar 6/22/2025 18:44:10'!
initializeWithRequestMaker: requester withResponseReader: responseReader withWebClientClass: aWebClientClass

	apiRequestMaker _ requester.
	apiResponseReader _ responseReader.
	webClientClass _ aWebClientClass.! !

!AiApiConnector class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 18:43:53'!
withRequestMaker: requester responseReader: responseReader webClientClass: webClientClass
	^self new initializeWithRequestMaker: requester withResponseReader: responseReader withWebClientClass: webClientClass! !

!AiApiRequestMaker methodsFor: 'initialization' stamp: 'Representar 6/22/2025 17:13:14'!
initializeWithApiUrl: url requestContents: contents requestType: type apiKey: key
	apiUrl _ url.
	requestContents _ contents.
	requestType _ type.
	apiKey _ key.! !

!AiApiRequestMaker methodsFor: 'send request' stamp: 'Representar 6/21/2025 22:56:26'!
responseConent: aPromptToSend

	| content |
	
	content _ '{'.
	requestContents associationsDo:[:ass |
		content _ content, '"', ass key, '": "', ass value, '",
'].
	content _ content , ' "prompt": "', aPromptToSend , '"}'.
	
	^content ! !

!AiApiRequestMaker methodsFor: 'send request' stamp: 'Representar 6/22/2025 14:36:12'!
sendTextPrompt: aPromptToSend

	| httpResponse webClient |
	
	webClient _ WebClient new.

	httpResponse _ webClient		
			httpPost: apiUrl 
			content: (self responseConent: aPromptToSend)
			type: requestType 
			do:[:req | 
				req headerAt: 'Authorization' put: 'Bearer ', apiKey].
			
	^httpResponse! !

!AiApiRequestMaker methodsFor: 'send request' stamp: 'Representar 6/22/2025 18:13:33'!
sendTextPrompt: aPromptToSend throughWebClient: aWebClient

	| httpResponse |

	httpResponse _ aWebClient		
			httpPost: apiUrl 
			content: (self responseConent: aPromptToSend)
			type: requestType 
			do:[:req | 
				req headerAt: 'Authorization' put: 'Bearer ', apiKey].
			
	^httpResponse! !

!AiApiRequestMaker class methodsFor: 'instance creation' stamp: 'ARM 6/22/2025 21:20:14'!
apiKeyNotVerified

	"If you put a verified one will also work. This is in case you have credit on a not verified organization"
	^''! !

!AiApiRequestMaker class methodsFor: 'instance creation' stamp: 'ARM 6/22/2025 21:19:10'!
apiKeyVerified

	"You need a verified key to run new OpenAI models.
	Be carefull when verifying your account, you have one only chance to do it.
	Choose a place with good light and make it with a good camera. Agustin"
	^''! !

!AiApiRequestMaker class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 18:22:25'!
dalle2
	^self new initializeWithApiUrl: 'https://api.openai.com/v1/images/generations'
		requestContents: (Dictionary with: 'model' -> 'dall-e-2' with: 'size' -> '256x256')
		requestType: 'application/json'
		apiKey: self apiKeyNotVerified! !

!AiApiRequestMaker class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 18:22:28'!
dalle3
	^self new initializeWithApiUrl: 'https://api.openai.com/v1/images/generations'
		requestContents: (Dictionary with: 'model' -> 'dall-e-3' with: 'size' -> '1024x1024')
		requestType: 'application/json'
		apiKey: self apiKeyNotVerified! !

!AiApiRequestMaker class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 18:20:56'!
gptImage1
	^self new initializeWithApiUrl: 'https://api.openai.com/v1/images/generations'
		requestContents: (Dictionary with: 'model' -> 'gpt-image-1'
						with: 'size' -> '1024x1024'
						with: 'quality' -> 'low'
						with: 'background' -> 'transparent')
		requestType: 'application/json'
		apiKey: self apiKeyVerified! !

!AiApiResponseReader methodsFor: 'initialization' stamp: 'Representar 6/22/2025 16:26:58'!
initializeWithImageReaderMethod: anImageReaderMethod
			textReaderMethod: aTextReaderMethod
			
	imageReaderMethod _ anImageReaderMethod.
	textReaderMethod _ aTextReaderMethod ! !

!AiApiResponseReader methodsFor: 'extract' stamp: 'Representar 6/22/2025 18:51:47'!
extractGenetedOutputFrom: aWebResponse withWebClient: aWebClient
	generatedImage _ imageReaderMethod value: aWebResponse value: aWebClient.
	answeredText _ textReaderMethod value: aWebResponse value: aWebClient.
	^OrderedCollection with: answeredText with: generatedImage ! !

!AiApiResponseReader class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 18:18:36'!
dalle2

	^self withImageReaderMethod: self dalleImageReaderMethod
		textReaderMethod:
		[: aWebResponse :webClient |
		| answer |
			answer _ (((WebUtils jsonDecode: (ReadStream on: aWebResponse content))
				at: 'data') first) at: 'url'.
			answer asString]
! !

!AiApiResponseReader class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 18:18:47'!
dalle3

	^self withImageReaderMethod: self dalleImageReaderMethod
		textReaderMethod:
		[: aWebResponse :webClient |
		| answer |
			answer _ (((WebUtils jsonDecode: (ReadStream on: aWebResponse content))
				at: 'data') first) at: 'revised_prompt'.
			answer asString]
! !

!AiApiResponseReader class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 19:33:42'!
dalleImageReaderMethod

	^[: aWebResponse :webClient |
			| url response imageStream form|
			url := ((WebUtils jsonDecode: (ReadStream on: aWebResponse content))
				at: 'data') first at: 'url' .
			response := webClient httpGet: url.
			imageStream := response content asByteArray readStream.
			form := (PNGReadWriter onBinaryStream: imageStream) nextImage.
			form]! !

!AiApiResponseReader class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 19:33:25'!
gptImage1

	^self withImageReaderMethod:
		[:aWebResponse :webClient |
			| imageBase64 imageDecoded imageStream form|
			imageBase64 := ((WebUtils jsonDecode: (ReadStream on: aWebResponse content))
						at: 'data') first at: 'b64_json' .
			imageDecoded := imageBase64 base64Decoded.
			imageStream := imageDecoded asByteArray readStream.
			form := (PNGReadWriter onBinaryStream: imageStream) nextImage.
			form]
		textReaderMethod:
		[: aWebResponse :webClient |
			| answer |
			answer _ (WebUtils jsonDecode: (ReadStream on: aWebResponse content))
				at: 'usage'.
			answer asString]
! !

!AiApiResponseReader class methodsFor: 'instance creation' stamp: 'Representar 6/22/2025 16:27:04'!
withImageReaderMethod: anImageReaderMethod textReaderMethod: aTextReaderMethod

	^self new initializeWithImageReaderMethod: anImageReaderMethod
			textReaderMethod: aTextReaderMethod
! !

!AiChatTesterModel methodsFor: 'accesing' stamp: 'Representar 6/22/2025 14:47:13'!
conversationText
	^conversationText! !

!AiChatTesterModel methodsFor: 'accesing' stamp: 'Representar 6/22/2025 14:47:22'!
conversationText: aText
	conversationText _ aText! !

!AiChatTesterModel methodsFor: 'accesing' stamp: 'Representar 6/22/2025 14:47:33'!
inputText
	^inputText! !

!AiChatTesterModel methodsFor: 'accesing' stamp: 'Representar 6/22/2025 14:47:43'!
inputText: aText
	inputText _ aText! !

!AiChatTesterModel methodsFor: 'initialization' stamp: 'Representar 6/22/2025 14:52:41'!
initializeForModelName: nameOfModel

	conversationText _ ''.
	inputText _ ''.
	modelName _ nameOfModel.! !

!AiChatTesterModel methodsFor: 'conversation' stamp: 'Representar 6/22/2025 16:04:44'!
addAnswerToConversation: answer

	^ self conversationText: self conversationText ,'
', modelName asText allBold ,  ': ' asText allBold , answer , '

'! !

!AiChatTesterModel methodsFor: 'conversation' stamp: 'Representar 6/22/2025 14:49:20'!
addQuestionToConversation: aQuestionReceived

	^ self conversationText: self conversationText , 'Me: ' asText allBold , aQuestionReceived , '
'! !

!AiChatTesterModel class methodsFor: 'as yet unclassified' stamp: 'Representar 6/22/2025 14:52:22'!
forModelName: modelName

	^self new initializeForModelName: modelName! !

!WebResponse methodsFor: '*AI-Interface-External' stamp: 'ARM 6/22/2025 20:54:47'!
initializeForTestingPurposesWithCode: testCode content: testConent

	content := testConent.
	code := testCode.! !

!WebResponse class methodsFor: '*AI-Interface-External' stamp: 'ARM 6/22/2025 20:54:08'!
forTestingPurposesWithCode: code content: content 
	^self new initializeForTestingPurposesWithCode: code content: content ! !
PNGReadWriter initialize!
