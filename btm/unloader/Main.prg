

Global Preserve Boolean B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, B11, B12, B13, B14, B15, B16, B17, B18, B19, B20, B22, B23, B24, B25, B26, B27
Global Preserve Integer I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15, I16, I17, I18, I19, I20
Global Preserve Real R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20(20), R21
Global Preserve String S1$, S2$, S3$(15), S4$, S5$, S6$, S7$, S8$, S9$, S10$, S11$, S12$, S13$, S14$, S15$, S16$, S17$, S18$, S19$, S20$(30)

Function main
''''''''''''''''''''''''''''''' Bottom_TLA_Station_17 Main Program  '''''''''''''''''''''''''''''''''''''

'--- Load the robot point file ---  
LoadPoints "robot1.pts"
  
'--- Initialize ---
Call Init
  
'--- Robot Parameter Setting ---
Tool 0
I1 = 30
Weight 5 'The load set
Motor On 'Motor on electric
FineDist 0.1 'Target point positioning accuracy setting（mm）
Power High 'High Power mode set High
Speed 100 'Internal speed setting（％）
SpeedS 2000 'Straight-line speed setting（mm/sec）
SpeedFactor I1 'External speed setting（％）
Accel 100, 100 'Speed ratio setting（％）
AccelS 15000, 8000 'Add or subtract speed value setting（mm/sec2）
PTPBoost 75, 75, 75 'Microshift parameter setting

'--- Check the status and start of background task NO.65 ----
If TaskState(65) = 0 Then
	Xqt 65, bgmain
EndIf
  
'--- Normal workflow (circular operation) ---
Do
  SpeedFactor I1 'External speed setting （％）
  Select S2$
    Case "001"
      Call PhotoFeedTray(2)  'Taking pictures of the feeding tray 
    Case "002"
  	  Call ScanFeedTray(R1)  'Feed tray scan code 
  	Case "003"
  	  Call PhotoFeedDUT(5, R1) 'Taking pictures of incoming products
  	Case "004"
  	  Call ScanFeedDUT(6, R1)  'Incoming product scan code
    Case "005"
      Call PhotoDischargeTray(8)  'Taking pictures of the discharge tray
    Case "006"
      Call ScanDischargeTray(R1)  'Outlet tray scan code
    Case "007"
      Call PhotoDischargeDUT(11, R1)  'Outlet tray product photo
    Case "008"
      Call ScanDischargeDUT(12, R1)   'Outlet tray product scan code
    Case "009"
      Call ScanDUTBelow(13, R2)     'Scan the code under the product
    Case "010"
      If B17 = True Then
         If R3 = 0 And R4 = 0 And R5 = 0 Then
            Call TakeFeedDUT(17, R1, R2, R3, R4, R5) 'without visual mode
         Else
            Call TakeFeedDUT_1(17, R1, R2, R3, R4, R5) 'Feed product recharging	
         EndIf
      Else
         Call TakeFeedDUT(17, R1, R2, R3, R4, R5) 'without visual mode
      EndIf
  	Case "011"
  	  If B17 = True Then
         If R3 = 0 And R4 = 0 And R5 = 0 Then
            Call PutDischargeDUT(21, R1, R2, R3, R4, R5) 'without visual mode
         Else
            Call PutDischargeDUT_1(21, R1, R2, R3, R4, R5) 'Discharging product discharging 
         EndIf
      Else
         Call PutDischargeDUT(21, R1, R2, R3, R4, R5) 'without visual mode
      EndIf
    Case "013"
      Call BackSafe           'back to safe position
    Case "014"
      Call VisionCalibration(R1, R3, R4, R5)       'visual calibration
    Case "016"
      Call Throw_NG(R1, R2)   'NG position throwingNG
    Case "017"
      Call Photo_NG(R1)   'NG position photo
    Case "020"
      Call Buffer_Take(R1, R2) 'Take product on the buffer position
    Case "021"
      Call Buffer_Put(R1, R2) 'Put product on the buffer position  
    Case "028"
      Call PhotoDischargeDUT_2(111, R1)  'Outlet tray product photo2  
    Case "031"
      Call PutDischargeDUT_2(121, R1, R2, R3, R4, R5) 'Discharging product discharging2	
    Case "032"
      Call PutDischargeDUT_Three(121, R1, R2, R3, R4, R5) 'Discharging product discharging2	
    Case "036"
      Call ScanTrayCode 'Scan tray code
    Default
      Wait 0.01
  Send
Loop
    
Fend
Function Throw_NG(bli31 As Integer, bli32 As Integer)
 
  Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Gripper 1/2/3 up 
  Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for the gripper 1/2/3 to rise into place

'--- Check the gripper index  ---
Lable_77:
  If bli32 < 1 Or bli32 > 3 Then
	    S11$ = S2$ + "_E1630_a"; B1 = True
	    Print "Gripper index exception"
	    Wait 2
	    GoTo Lable_77
  EndIf

  '--- Check the position index  ---
Lable_78:
  If bli31 < 1 Or bli31 > 4 Then
	    S11$ = S2$ + "_E1629_a"; B1 = True
	    Print "Position index exception"
	    Wait 2
	    GoTo Lable_78
  EndIf
  
    Integer bli55
   If bli32 = 1 Then
     bli55 = 54
   ElseIf bli32 = 2 Then
     bli55 = 58
   ElseIf bli32 = 3 Then
     bli55 = 62
   EndIf
   bli55 = bli55 + bli31 - 1
  
'  '--- Get the current robot position  ---
'  LoadPoints "robot1.pts"
'  P99 = CurPos
'  SavePoints "robot1.pts"
'  
'  '--- Robot motion transition ---
'  If CZ(P99) < CZ(P(bli55)) - 2 Then
'     CZ(P99) = CZ(P(bli55))
'     Move P99
'  EndIf
'  If CY(P99) <= 130 Then
'     Go P0 CP
'  EndIf
'  
Hand P(bli55), Lefty
Go P(bli55) /L

Call GripperDown(R2)

Call GripperOpen(R2)
Wait 0.1
  
Call GripperUp(R2)

S2$ = ""
S11$ = "016_OKOK_a"; B1 = True
Print "Robot NG throwing completed"
SpeedS 2000; AccelS 15000, 8000
		
Fend
Function Photo_NG(bli41 As Integer)

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Gripper 1/2/3 up 
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for the gripper 1/2/3 to rise into place
Tool 0

'--- Check the NG photo location index ---
Lable_6:
If bli41 < 1 Or bli41 > 4 Then
    S11$ = S2$ + "_E1632_a"; B1 = True
    Print "NG bit photo index is abnormal"
    Wait 2
    GoTo Lable_6
EndIf

''--- Get the current robot position  ---
'LoadPoints "robot1.pts"
'P99 = CurPos
'SavePoints "robot1.pts"
'
''--- Robot motion transition ---
'If CZ(P99) < CZ(P(70)) - 2 Then
' CZ(P99) = CZ(P(70))
' Move P99
'EndIf
'If CY(P99) < 180 Then
' Go P0 CP
'EndIf

'---NG location photo spot ---
R10 = -60; R11 = 0; I3 = bli41; I8 = 4 'Array X Spacing; Array Y Spacing; Array Position Index; Array Rows (X direction) 
Call PalletOffset
Hand P(67), Lefty
Go P(67) +X(R12) +Y(R13) /L

Wait 0.1
S2$ = ""
S11$ = "017_OKOK_a"; B1 = True
Print "Robot arrives at NG photo spot"
	
Fend

Function Init
''''''''''''''''''''''''''''''' Initialize  '''''''''''''''''''''''''''''''''''''   

'--- Initializes the Boolean variable ---  
B1 = False; B2 = False; B17 = False; B19 = False; B20 = True; B22 = True;
B23 = False; B24 = False; B25 = False

'--- Initializes integer variables ---  
I1 = 30; I2 = 0; I3 = 0; I4 = 0; I5 = 10; I6 = 0; I7 = 0; I20 = 0

'--- Initialize the real variable ---  
R1 = 0; R2 = 0; R3 = 0; R4 = 0; R5 = 0; R10 = 0; R11 = 0; R11 = 0; R12 = 0; R13 = 0; R15 = 0; R16 = 0; R17 = 0; R18 = 0

'--- Initialize the string variable --- 
S3$(0) = ""; S2$ = ""; S4$ = ""; S5$ = ""; S6$ = ""; S12$ = ""; S13$ = ""; S15$ = ""; S16$ = ""; S17$ = ""; S18$ = "";
   
'--- Initialize robot IO ---    
Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position 	

'--- Check whether the robot gripper has a product ---  

      
Fend
Function PhotoFeedTray(bli01 As Integer)
''''''''''''''''''''''''''''''' Feed tray photography '''''''''''''''''''''''''''''''''''''   

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition  ---
If CZ(P99) < CZ(P(bli01)) - 2 Then
 CZ(P99) = CZ(P(bli01))
 Move P99
EndIf
If CY(P99) <= 220 Then
 Go P0 CP
EndIf
  
Go P(bli01) 'Feeding tray photo position 
Wait 0.1
S2$ = ""
S11$ = "001_OKOK_a"; B1 = True
Print "The robot arrives at the feed tray photo point"
   
Fend
Function ScanFeedTray(bli02 As Integer)
''''''''''''''''''''''''''''''' Code scanning of feeding tray '''''''''''''''''''''''''''''''''''''   

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position

If bli02 < 1 Or bli02 > 4 Then
    S11$ = S2$ + "_E1624_a"; B1 = True
    Print "Incoming product photographic index is abnormal"
    Pause
    S2$ = ""
    Exit Function
EndIf



Tool 0

'--- Get the current robot position  ---
'LoadPoints "robot1.pts"
'P99 = CurPos
'SavePoints "robot1.pts"
'
''--- Robot motion transition ---
'If CZ(P99) < CZ(P(bli02 + 36)) - 2 Then
' CZ(P99) = CZ(P(bli02 + 36))
' Move P99
'EndIf
'If CY(P99) <= 220 Then
' Go P0 CP
'EndIf

Go P(bli02 + 36) 'Feeding tray scan position 


S2$ = ""
S11$ = "002_OKOK_a"; B1 = True
Print "The robot arrives at the feeding tray scanning point"
   
Fend
Function PhotoFeedDUT(bli03 As Integer, bli04 As Integer)
''''''''''''''''''''''''''''''' Incoming product photography '''''''''''''''''''''''''''''''''''''   

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check incoming product photo location index ---
If bli04 < 1 Or bli04 > 12 Then
    S11$ = S2$ + "_E1623_a"; B1 = True
    Print "Incoming product photographic index is abnormal"
    Pause
    S2$ = ""
    Exit Function
EndIf

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"
'
''--- Robot motion transition ---
'If CZ(P99) < CZ(P(bli03)) - 2 Then
' CZ(P99) = CZ(P(bli03))
' Move P99
'EndIf
If CY(P99) <= 90 Then
 Accel 80, 80
EndIf

R10 = -60; R11 = 50; I3 = bli04; I8 = 6 'Array X spacing; Array Y spacing; Array location index; Number of array rows (X direction)
Call PalletOffset
Hand P(bli03), Lefty
Go P(bli03) +X(R12) +Y(R13) /L  'Photo point of incoming product

Accel 100, 100

S2$ = ""
S11$ = "003_OKOK_a"; B1 = True
Print "The robot arrives at the feed product photo point"
   
Fend
Function ScanFeedDUT(bli05 As Integer, bli06 As Integer)
''''''''''''''''''''''''''''''' Incoming product scanning code '''''''''''''''''''''''''''''''''''''   

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check incoming product scan position index ---
If bli06 < 1 Or bli06 > 12 Then
    S11$ = S2$ + "_E1624_a"; B1 = True
    Print "Incoming product scan code index is abnormal"
    Pause
        S2$ = ""
    Exit Function
EndIf

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition ---
If CZ(P99) < CZ(P(bli05)) - 2 Then
 CZ(P99) = CZ(P(bli05))
 Move P99
EndIf
If CY(P99) <= 150 Then
 Go P0 CP
EndIf

R10 = -60; R11 = 50; I3 = bli06; I8 = 6 'Array X spacing; Array Y spacing; Array location index; Number of array rows (X direction)
Call PalletOffset
Hand P(bli05), Lefty
Go P(bli05) +X(R12) +Y(R13) /L 'Incoming product scanning point

S2$ = ""
S11$ = "004_OKOK_a"; B1 = True
Print "The robot arrives at the incoming product scanning point"
   
Fend
Function PhotoDischargeTray(bli07 As Integer)
''''''''''''''''''''''''''''''' Take photos of discharging tray '''''''''''''''''''''''''''''''''''''   

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition ---
If CZ(P99) < CZ(P(bli07)) - 2 Then
 CZ(P99) = CZ(P(bli07))
 Move P99
EndIf
If CY(P99) > 220 Then
 Go P0 CP
EndIf

Go P(bli07) /L  'Discharging tray photo point

Wait 0.1
S2$ = ""
S11$ = "005_OKOK_a"; B1 = True
Print "The robot arrives at the discharging tray photo point"
   
Fend
Function ScanDischargeTray(bli21 As Integer)
''''''''''''''''''''''''''''''' Scan the discharging tray '''''''''''''''''''''''''''''''''''''    

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check the index of discharging tray scanning position ---
  If bli21 < 1 Or bli21 > 4 Then
	    S11$ = S2$ + "_E1625_a"; B1 = True
	    Print "The scan code position index of the discharging tray is abnormal"
	    Pause
	       S2$ = ""
    Exit Function
  EndIf
  
''--- Get the current robot position  ---
'LoadPoints "robot1.pts"
'P99 = CurPos
'SavePoints "robot1.pts"
'
''--- Robot motion transition ---
'If CZ(P99) < CZ(P(bli21 + 36)) - 2 Then
' CZ(P99) = CZ(P(bli21 + 36))
' Move P99
'EndIf
'If CY(P99) > 220 Then
' Go P0 CP
'EndIf

Hand P(bli21 + 36), Lefty
Go P(bli21 + 36) /L 'Discharging tray sweep code point

S2$ = ""
S11$ = "006_OKOK_a"; B1 = True
Print "The robot arrives at the discharging tray scanning code point"
   
Fend
Function PhotoDischargeDUT(bli09 As Integer, bli10 As Integer)
''''''''''''''''''''''''''''''' Take photos of discharging products '''''''''''''''''''''''''''''''''''''    
Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check the photographic position index of discharging products ---
Lable_9:
If bli10 < 1 Or bli10 > 48 Then
    S11$ = S2$ + "_E1626_a"; B1 = True
    Print "The photographic position index of output product is abnormal"
     Pause
       S2$ = ""
    Exit Function
EndIf

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"
'
''--- Robot motion transition ---
'If CZ(P99) < CZ(P(bli09)) - 2 Then
' CZ(P99) = CZ(P(bli09))
' Move P99
'EndIf
If CY(P99) > 230 Then
 Accel 80, 80
EndIf

R10 = 60; R11 = -40; I3 = bli10; I8 = 6 'Array X spacing; Array Y spacing; Array location index; Number of array rows (X direction)
Call PalletOffset
Hand P(bli09), Lefty
Go P(bli09) +X(R12) +Y(R13) /L  'Photo point of discharging product

Accel 100, 100

S2$ = ""
S11$ = "007_OKOK_a"; B1 = True
Print "The robot arrives at the discharging product photo point"
   
Fend
Function PhotoDischargeDUT_2(bli09 As Integer, bli10 As Integer)
''''''''''''''''''''''''''''''' Take photos of discharging products2 '''''''''''''''''''''''''''''''''''''    
Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check the photographic position index of discharging products ---
Lable_9:
If bli10 < 1 Or bli10 > 48 Then
    S11$ = S2$ + "_E1626_a"; B1 = True
    Print "The photographic position index of output product is abnormal"
     Pause
    Wait 2
    GoTo Lable_9
EndIf

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition ---
If CZ(P99) < CZ(P(bli09)) - 2 Then
 CZ(P99) = CZ(P(bli09))
 Move P99
EndIf
If CY(P99) > 220 Then
 Go P0 CP
EndIf

R10 = -60; R11 = -40; I3 = bli10; I8 = 6 'Array X spacing; Array Y spacing; Array location index; Number of array rows (X direction)
Call PalletOffset
Hand P(bli09), Lefty
Go P(bli09) +X(R12) +Y(R13) /L  'Photo point of discharging product

Wait 0.1
S2$ = ""
S11$ = "028_OKOK_a"; B1 = True
Print "The robot arrives at the discharging product photo point2"
   
Fend
Function ScanDischargeDUT(bli11 As Integer, bli12 As Integer)
''''''''''''''''''''''''''''''' Scan code for discharging products '''''''''''''''''''''''''''''''''''''       
Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check out product scan code location index ---
Lable_10:
If bli12 < 1 Or bli12 > 48 Then
    S11$ = S2$ + "_E1624_a"; B1 = True
    Print "The scan code position index of the output product is abnormal"
     Pause
    Wait 2
    GoTo Lable_10
EndIf

'   '--- Get the current robot position  ---
'LoadPoints "robot1.pts"
'P99 = CurPos
'SavePoints "robot1.pts"
'
''--- Robot motion transition ---
'If CZ(P99) < CZ(P(bli11)) - 2 Then
' CZ(P99) = CZ(P(bli11))
' Move P99
'EndIf
'If CY(P99) > 220 Then
' Go P0 CP
'EndIf
   
R10 = -60; R11 = -40; I3 = bli12; I8 = 6 'Array X spacing; Array Y spacing; Array location index; Number of array rows (X direction)
Call PalletOffset
Hand P(bli11), Lefty
Go P(bli11) +X(R12) +Y(R13) /L  'Discharging product scan code point

Wait 0.1
S2$ = ""
S11$ = "008_OKOK_a"; B1 = True
Print "The robot arrives at the discharging product scanning point"
   
Fend
Function ScanDUTBelow(bli13 As Integer, bli14 As Integer)
''''''''''''''''''''''''''''''' Scan the code below the product '''''''''''''''''''''''''''''''''''''    
   
''--- Check the scan gripper index under the product ---
'Lable_11:
'  If bli14 < 1 Or bli14 > 3 Then
'  	 Wait 2
'     If bli14 < 0 Or bli14 > 3 Then
'	    S11$ = S2$ + "_E1624_a"; B1 = True
'		Print "The scan grab index under the product is abnormal"
'	    GoTo Lable_11
'	 EndIf
'  EndIf
'   
'bli13 = bli13 + bli14 'Computes the scan position index under the product
'Jump P(bli13) /L LimZ CZ(P0) 'Scan the code point below the product
'Wait 0.1
'S2$ = ""
'S11$ = "009_OKOK_a"; B1 = True
'Print "The robot arrives at the scanning point below the product"
   
Fend
Function TakeFeedDUT(bli15 As Integer, bli16 As Integer, bli17 As Integer, blr01 As Real, blr02 As Real, blr03 As Real)
''''''''''''''''''''''''''''''' Feed product recharging '''''''''''''''''''''''''''''''''''''     
Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check incoming product pick-up location index ---
Lable_12:
If bli16 < 1 Or bli16 > 12 Then
    S11$ = S2$ + "_E1627_a"; B1 = True
    Print "The index of the taking position of the incoming product is abnormal"
     Pause
    Wait 2
    GoTo Lable_12
EndIf
   Print "Current crawl location index="; Print bli16

'--- Check incoming product grab index ---
Lable_13:
If bli17 < 1 Or bli17 > 3 Then
    S11$ = S2$ + "_E1628_a"; B1 = True
    Print "The index of the pick-up gripper of the incoming product is abnormal"
     Pause
    Wait 2
    GoTo Lable_13
EndIf


 Print "VisionX="; Print blr01
 Print "VisionY="; Print blr02
 Print "VisionU="; Print blr03

'---Switch tool coordinates---
   Tool 0
   Print "Current operating coordinates="; Print 0



  'Calculate grab position
  bli15 = bli15 + bli17
  Integer aa
  aa = 100
  aa = bli16 Mod 3
  bli16 = bli16 /3
  If aa = 0 Then
  	aa = 3
  	bli16 = bli16 - 1
  EndIf
  
R10 = -180; R11 = 50; I3 = bli16 + 1; I8 = 2 'Array X spacing; Array Y spacing; Array location index; Number of array rows (X direction)
Call PalletOffset

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition  ---
'If CZ(P99) < CZ(P(bli15)) + 30 - 2 Then
' CZ(P99) = CZ(P(bli15)) + 10
' Move P99
'EndIf
'If CY(P99) <= 220 Then
' Go P0 CP
'EndIf

Hand P(bli15), Lefty

'Open the grip
Call GripperOpen(R2)

'+10mm above the feeding point
Go P(bli15) +X(R12) +Y(R13) +Z(0) +U(blr03) /L

'Lower the gripper
Call GripperDown(R2)

'Feed product pick-up point
SpeedS 1000; AccelS 2000, 2000
Move P(bli15) +X(R12) +Y(R13) +U(blr03) /L

'Close the grip
'Call GripperClamp(R2)
If R2 = 1 Then
Off G1Open
On G1Clamp
ElseIf R2 = 2 Then
Off G2Open
On G2Clamp
ElseIf R2 = 3 Then
Off G3Open
On G3Clamp
EndIf
Wait 0.2

 '+10mm above the feeding point
SpeedS 1000; AccelS 2000, 2000
Move P(bli15) +X(R12) +Y(R13) +Z(0) +U(blr03) /L

'Grab up
Call GripperUp(R2)


S2$ = ""
S11$ = "010_OKOK_a"; B1 = True
Print "The robot arrives at the feed product pick-up point"
SpeedS 2000; AccelS 15000, 8000
Tool 0

Fend
Function TakeFeedDUT_1(bli15 As Integer, bli16 As Integer, bli17 As Integer, blr01 As Real, blr02 As Real, blr03 As Real)
	
''''''''''''''''''''''''''''''' Feed product recharging '''''''''''''''''''''''''''''''''''''    
   
  Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
  Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
   Tool 0
   
    bli15 = bli15 + bli17
    Integer num(6)
    LoadPoints "robot1.pts"
    P45 = P(bli15)
    SavePoints "robot1.pts"
    num(0) = CX(P(bli15))
    num(1) = CY(P(bli15))
    num(2) = CU(P(bli15))
    
'--- Check visual data ---    
   
'    If blr02 < 240 Or blr02 > 313 Or blr01 < 130 Or blr01 > 575 Then
'    	  S11$ = S2$ + "_E1631_a"; B1 = True
'	      Print "Abnormal visual data of discharged products"
'	      Pause
'		  S2$ = ""
'	      Exit Function
'    EndIf
    
     Print "visual data X="; Print blr01
     Print "visual data Y="; Print blr02
     Print "visual data U="; Print blr03
 
     CX(P45) = blr01
     CY(P45) = blr02
     CU(P45) = blr03
    SavePoints "robot1.pts"
    
    
'--- Check incoming product pick-up location index ---
  If bli16 < 1 Or bli16 > 42 Then
	    S11$ = S2$ + "_E1627_a"; B1 = True
	    Print "Exception in index of picking position of feed product"
	      Pause
		  S2$ = ""
	      Exit Function
  EndIf
  Print "Current picking position ="; Print bli16
  
'--- Check incoming product grab index ---
  If bli17 < 1 Or bli17 > 3 Then
	    S11$ = S2$ + "_E1628_a"; B1 = True
	    Print "Exception in index of feeding product picking gripper"
	      Pause
		  S2$ = ""
	      Exit Function
  EndIf
  
  
Hand P45, Lefty
Call GripperOpen(R2)
Print "Current grip index="; Print R2
'------------------------------------------lh 2026 0828
SpeedS 1800; AccelS 15000, 8000
'------------------------------------------lh 2026 0828
Go P45 /L

Call GripperDown(R2)

If R2 = 1 Then
	B24 = True
	ElseIf R2 = 2 Then
	B25 = True
	ElseIf R2 = 3 Then
	B26 = True
EndIf
Call GripperClamp(R2)

Wait 0.2

If R2 = 1 Then
	If Sw(G1ClampSignal) = Off Then
		Pause
	EndIf
EndIf
If R2 = 2 Then
	If Sw(G2ClampSignal) = Off Then
		Pause
	EndIf
EndIf
If R2 = 3 Then
	If Sw(G3ClampSignal) = Off Then
		Pause
	EndIf
EndIf
Call GripperUp(R2)

S2$ = ""
S11$ = "010_OKOK_a"; B1 = True
Print "Robot arrives at the pick-up point of incoming products"
SpeedS 2000; AccelS 15000, 8000
Tool 0
   	
Fend

Function PutDischargeDUT(bli18 As Integer, bli19 As Integer, bli20 As Integer, blr04 As Real, blr05 As Real, blr06 As Real)
''''''''''''''''''''''''''''''' Discharging product discharging'''''''''''''''''''''''''''''''''''''    
Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Check discharging position index of discharging products ---
Lable_14:
If bli19 < 1 Or bli19 > 48 Then
    S11$ = S2$ + "_E1629_a"; B1 = True
    Print "The index of discharging position of discharging product is abnormal"
     Pause
    Wait 2
    GoTo Lable_14
EndIf
    Print "Current crawl location index="; Print bli19

'--- Check the index of discharging gripper for discharging products ---
Lable_15:
If bli20 < 1 Or bli20 > 3 Then
    S11$ = S2$ + "_E1630_a"; B1 = True
    Print "The index of discharging gripper of discharging product is abnormal"
     Pause
    Wait 2
    GoTo Lable_15
EndIf


      Print "VisionX="; Print blr04
      Print "VisionY="; Print blr05
      Print "VisionU="; Print blr06

'---Switch tool coordinates-
Tool 0
Print "tool="; Print 0

  'Calculate grab position
bli18 = bli18 + bli20
Integer aa
	  aa = 100
	  aa = bli19 Mod 3
	  bli19 = bli19 /3
	  If aa = 0 Then
	  	aa = 3
	  	bli19 = bli19 - 1
EndIf
	R10 = 180; R11 = -40; I3 = bli19 + 1; I8 = 2 'Array X spacing; Array Y spacing; Array location index; Number of array rows (X direction)
	Call PalletOffset

'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

Hand P(bli18), Lefty

'+10mm above discharging point of discharging product
Go P(bli18) +X(R12) +Y(R13) +Z(0) +U(blr06) /L

'Lower the gripper
Call GripperDown(R2)

'Discharging point of discharging product
SpeedS 1000; AccelS 2000, 2000
Move P(bli18) +X(R12) +Y(R13) +U(blr06) /L

'Open the grip
Call GripperOpen(R2)

'+10mm above discharging point of discharging product
SpeedS 1000; AccelS 2000, 2000
Move P(bli18) +X(R12) +Y(R13) +Z(0) +U(blr06) /L

'Grab up
Call GripperUp(R2)


S2$ = ""
S11$ = "011_OKOK_a"; B1 = True
Print "The robot arrives at the discharging point of the discharging product"
SpeedS 2000; AccelS 15000, 8000
Tool 0

Fend
Function PutDischargeDUT_1(bli18 As Integer, bli19 As Integer, bli20 As Integer, blr04 As Real, blr05 As Real, blr06 As Real)

'''''''''''''''''''''''''''''''Discharging product discharging  '''''''''''''''''''''''''''''''''''''    

  Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
  Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
  '--- Check the visual data of discharging products ---    
'    If blr05 < -290 Or blr05 > 1 Or blr04 < 270 Or blr04 > 530 Then
'    	  S11$ = S2$ + "_E1631_a"; B1 = True
'	      Print "Abnormal visual data of discharged products XY"
'	      	      Pause
'		  S2$ = ""
'	      Exit Function
'    EndIf
  
  '--- Check discharging position index of discharging products ---
  If bli19 < 1 Or bli19 > 48 Then
	    S11$ = S2$ + "_E1629_a"; B1 = True
	    Print "Exception in discharging position index of discharging product"
	    	      	      Pause
		  S2$ = ""
	      Exit Function
  EndIf
   Print "Current position index ="
   Print bli19
   
'---Check the index of discharging gripper for discharging products  ---
  If bli20 < 1 Or bli20 > 3 Then
  		S2$ = ""
	    S11$ = S2$ + "_E1630_a"; B1 = True
	    Print "Exception in index of discharging gripper of discharging product"
        	      	      Pause
		  S2$ = ""
	      Exit Function
  EndIf
  
    Tool 0
  
  	Print "before"
  	Print bli18
  
     bli18 = bli18 + bli20
     Print "after"
  	Print bli18
    Integer num(6)
    LoadPoints "robot1.pts"
    P46 = P(bli18)
    SavePoints "robot1.pts"
    num(0) = CX(P(bli18))
    num(1) = CY(P(bli18))
    num(2) = CU(P(bli18))

    CX(P46) = blr04
    CY(P46) = blr05
    CU(P46) = blr06
    SavePoints "robot1.pts"
    Print "visual data X="; Print blr04
    Print "visual data Y="; Print blr05
    Print "visual data U="; Print blr06




'  '--- Get the current robot position  ---
'  LoadPoints "robot1.pts"
'  P99 = CurPos
'  SavePoints "robot1.pts"
  '--- Robot motion transition ---
'  If CZ(P99) < CZ(P46) + 20 - 2 Then
'     CZ(P99) = CZ(P46) + 20
'     Move P99
'  EndIf
'  If CY(P99) >= 500 Then
'     Go P0 CP
'  EndIf

'---Switch tool coordinates--

  
Hand P46, Lefty

'---+20mm above discharging point of discharging product
'------------------------------------------lh 2026 0828
SpeedS 1800; AccelS 15000, 8000
'------------------------------------------lh 2026 0828

Go P46 +Z(0) /L


Call GripperDown(R2)


If R2 = 1 Then
	B24 = False
	ElseIf R2 = 2 Then
	B25 = False
	ElseIf R2 = 3 Then
	B26 = False
EndIf
Call GripperOpen(R2)

Call GripperUp(R2)


S2$ = ""
S11$ = "011_OKOK_a"; B1 = True
Print "Robot reaches the discharging point of discharging product"
SpeedS 2000; AccelS 15000, 8000
Tool 0
		
Fend

Function PutDischargeDUT_Three(bli18 As Integer, bli19 As Integer, bli20 As Integer, blr04 As Real, blr05 As Real, blr06 As Real)

'''''''''''''''''''''''''''''''Discharging product discharging  '''''''''''''''''''''''''''''''''''''    

  Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
  Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
  '--- Check the visual data of discharging products ---    
  
  '--- Check discharging position index of discharging products ---
  If bli19 < 1 Or bli19 > 48 Then
	    S11$ = S2$ + "_E1629_a"; B1 = True
	    Print "Exception in discharging position index of discharging product"
	    	      	      Pause
		  S2$ = ""
	      Exit Function
  EndIf
   Print "Current position index ="
   Print bli19
   
'---Check the index of discharging gripper for discharging products  ---
  If bli20 < 1 Or bli20 > 3 Then
  		S2$ = ""
	    S11$ = S2$ + "_E1630_a"; B1 = True
	    Print "Exception in index of discharging gripper of discharging product"
        	      	      Pause
		  S2$ = ""
	      Exit Function
  EndIf
  
    Tool 0
  	Print "before"
  	Print bli18
  	
    bli18 = 21 + bli20   'bli18 = bli18 + bli20
     
    Print "after"
    Print bli18
    Integer num(6)
    LoadPoints "robot1.pts"
    P46 = P(bli18)
    SavePoints "robot1.pts"
    num(0) = CX(P(bli18))
    num(1) = CY(P(bli18))
    num(2) = CU(P(bli18))

    CX(P46) = blr04
    CY(P46) = blr05
    CU(P46) = blr06
    SavePoints "robot1.pts"
    Print "visual data X="; Print blr04
    Print "visual data Y="; Print blr05
    Print "visual data U="; Print blr06

'---Switch tool coordinates--

  
Hand P46, Lefty

'---+20mm above discharging point of discharging product
Go P46 +Z(0) /L


Call GripperDownThree()

If R2 = 1 Then
	B24 = False
	ElseIf R2 = 2 Then
	B25 = False
	ElseIf R2 = 3 Then
	B26 = False
EndIf

Call GripperOpenThree()

Call GripperUpThree()


S2$ = ""
S11$ = "032_OKOK_a"; B1 = True
Print "Robot reaches the discharging point of discharging product"
SpeedS 2000; AccelS 15000, 8000
Tool 0
		
Fend
Function PutDischargeDUT_2(bli18 As Integer, bli19 As Integer, bli20 As Integer, blr04 As Real, blr05 As Real, blr06 As Real)

'''''''''''''''''''''''''''''''Discharging product discharging2  '''''''''''''''''''''''''''''''''''''    

  Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
  Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
  
  
     bli18 = bli18 + bli20
    Integer num(6)
    LoadPoints "robot1.pts"
    P46 = P(bli18)
    SavePoints "robot1.pts"
    num(0) = CX(P(bli18))
    num(1) = CY(P(bli18))
    num(2) = CU(P(bli18))
    
'--- Check the visual data of discharging products ---    
    vision_er:
    If blr05 < -230 Or blr05 > 90 Or blr04 < 275 Or blr04 > 600 Then
    	  S11$ = S2$ + "_E1631_a"; B1 = True
	      Print "Abnormal visual data of discharged products"
	      Pause
	      Wait 2
	      GoTo vision_er
    EndIf
    CX(P46) = blr04
    CY(P46) = blr05
    CU(P46) = blr06
    SavePoints "robot1.pts"
    Print "visual data X="; Print blr04
    Print "visual data Y="; Print blr05
    Print "visual data U="; Print blr06


'--- Check discharging position index of discharging products ---
Lable_14:
  If bli19 < 1 Or bli19 > 48 Then
  		S2$ = ""
	    S11$ = S2$ + "_E1629_a"; B1 = True
	    Print "Exception in discharging position index of discharging product"
	    Pause
	    Wait 2
	    GoTo Lable_14
  EndIf
   Print "Current position index ="
   Print bli19
   
'---Check the index of discharging gripper for discharging products  ---
Lable_15:
  If bli20 < 1 Or bli20 > 3 Then
  		S2$ = ""
	    S11$ = S2$ + "_E1630_a"; B1 = True
	    Print "Exception in index of discharging gripper of discharging product"
	    Pause
	    Wait 2
	    GoTo Lable_15
  EndIf

  '--- Get the current robot position  ---
  LoadPoints "robot1.pts"
  P99 = CurPos
  SavePoints "robot1.pts"
  '--- Robot motion transition ---
'  If CZ(P99) < CZ(P46) + 20 - 2 Then
'     CZ(P99) = CZ(P46) + 20
'     Move P99
'  EndIf
'  If CY(P99) >= 500 Then
'     Go P0 CP
'  EndIf

'---Switch tool coordinates--
  Tool 0
  
Hand P46, Lefty

'---+20mm above discharging point of discharging product
Go P46 +Z(0) /L

'Gripper drops
Call GripperDown(R2)

'Discharging point of discharging product
SpeedS 1000; AccelS 2000, 2000
Move P46 /L

'Gripper to open
Call GripperOpen(R2)

'---+20mm above discharging point of discharging product
Wait 0.05
SpeedS 1000; AccelS 2000, 2000
Move P46 +Z(0) /L

'Gripper rises
Call GripperUp(R2)


S2$ = ""
S11$ = "031_OKOK_a"; B1 = True
Print "Robot reaches the discharging point2 of discharging product"
SpeedS 2000; AccelS 15000, 8000
Tool 0
		
Fend
Function GetCurrentPosition_1
''''''''''''''''''''''''''''''' Obtaining robot position '''''''''''''''''''''''''''''''''''''    

LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

R15 = CX(P99)
R16 = CY(P99)
R17 = CZ(P99)
R18 = CU(P99)
S15$ = Str$(R15)
S16$ = Str$(R16)
S17$ = Str$(R17)
S18$ = Str$(R18)
S13$ = "_" + S15$ + "_" + S16$ + "_" + S18$
S11$ = S2$ + S13$ + "_OKOK_a"; B1 = True
   
Fend

Function GetCurrentPosition(bli28 As Integer)
''''''''''''''''''''''''''''''' Obtaining robot position '''''''''''''''''''''''''''''''''''''    
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

R15 = CX(P(bli28))
R16 = CY(P(bli28))
R17 = CZ(P(bli28))
R18 = CU(P(bli28))
S15$ = Str$(R15)
S16$ = Str$(R16)
S17$ = Str$(R17)
S18$ = Str$(R18)
S13$ = "_" + S15$ + "_" + S16$ + "_" + S18$
S11$ = S2$ + S13$ + "_OKOK_a"; B1 = True
   
Fend
Function BackSafe
''''''''''''''''''''''''''''''' Robot back to safety '''''''''''''''''''''''''''''''''''''    
  If B20 = True Then
  Lable_4:
         
    If Sw(G1ClampSignal) = On Or Sw(G2ClampSignal) = On Or Sw(G3ClampSignal) = On Then
       Wait 1
       If Sw(G1ClampSignal) = On Then 'If Sw(G1ClampSignal) = On And Sw(G1OpenSignal) = Off Then
       	  S2$ = ""
       	  S11$ = "013_E9000_a"; B1 = True
       	  Print "Robot initialization gripper 1 has a product exception"
	      'Pause
	      If B22 = True Then
	         GoTo Lable_19
	      Else
	         GoTo Lable_18
	      EndIf
	   Else
	   	   Off G1Clamp; On G1Open
       EndIf
       If Sw(G2ClampSignal) = On Then 'If Sw(G2ClampSignal) = On And Sw(G2OpenSignal) = Off Then
          S2$ = ""
       	  S11$ = "013_E9001_a"; B1 = True
       	  Print "Robot initialization gripper 2 has a product exception"
	      'Pause
	      If B22 = True Then
	         GoTo Lable_19
	      Else
	         GoTo Lable_18
	      EndIf
	      
	   Else
	   	   Off G2Clamp; On G2Open
	      
       EndIf
       If Sw(G3ClampSignal) = On Then 'If Sw(G3ClampSignal) = On And Sw(G3OpenSignal) = Off Then
          S2$ = ""
       	  S11$ = "013_E9002_a"; B1 = True
       	  Print "Robot initialization gripper 3 has a product exception"
	      'Pause
	      If B22 = True Then
	         GoTo Lable_19
	      Else
	         GoTo Lable_18
	      EndIf
	      
	   Else
	   	   Off G3Clamp; On G3Open
	      
       EndIf
       
'       If Sw(G1ClampSignal) = Off And Sw(G1OpenSignal) = Off Then
'      		Off G1Clamp; On G1Open
'      	EndIf
'      	
'      	If Sw(G2ClampSignal) = Off And Sw(G2OpenSignal) = Off Then
'      		Off G2Clamp; On G2Open
'      	EndIf
'      	
'      	If Sw(G3ClampSignal) = Off And Sw(G3OpenSignal) = Off Then
'      		Off G3Clamp; On G3Open
'      	EndIf
      GoTo Lable_4
      
      Else
      B22 = False
      Off G1Clamp; Off G2Clamp; Off G3Clamp; On G1Open; On G2Open; On G3Open;
      EndIf
   EndIf
 
Lable_19:
 
SpeedFactor 15
Tool 0
I2 = 0

'---Robot attitude confirmation and error prevention ---  
Lable_5:
  If Hand(Here) = Righty Then
     Wait 2
     If Hand(Here) = Righty Then
        S2$ = ""
	    S11$ = "013_E1613_a"; B1 = True
	    Print "Robot posture is abnormal"
	    GoTo Lable_5
	 EndIf
  EndIf

'--- Judge the state of axis 3 and lock it ---
If SFree(3) = True Then
   SLock 3
EndIf

  LoadPoints "robot1.pts"
  P99 = CurPos
  If CZ(P0) <= -2 And CZ(P0) > 0 Then   'Judge the height of the robot's safety bit
  CZ(P0) = -1
  EndIf
  SavePoints "robot1.pts"
  
  If CZ(P99) <= CZ(P0) + 0.5 Then             'Judge the height of the current position of the robot
  CZ(P99) = CZ(P0)
  Move P99
  ElseIf CZ(P99) > 1 Then
'  S2$ = ""
  S11$ = "013_E1612_a"; B1 = True
  Print "The height of the 3rd axis of the robot is abnormal"
  EndIf
  
  Go P0
  Wait 0.2
'  S2$ = ""
  If B22 = True Then
     B22 = False
  Else
     S11$ = "013_OKOK_a"; B1 = True
     S2$ = ""
  EndIf
  Print "The robot reaches the safe point"
  Lable_18:
  SpeedFactor I1
  Tool 0
  
Fend
Function VisionCalibration(bli22 As Integer, bra11 As Real, bra12 As Real, bra13 As Real)
''''''''''''''''''''''''''''''' Visual calibration '''''''''''''''''''''''''''''''''''''    
Tool 0
'--- Check the visual calibration position index ---
Lable_16:
  If bra11 < -15 Or bra11 > 15 Or bra12 < -15 Or bra12 > 15 Or bra13 < -15 Or bra13 > 15 Then
        Wait 1
	    S11$ = S2$ + "_E1637_a"; B1 = True
	    Print "Abnormal index of visual calibration position"
	    GoTo Lable_16
  EndIf
  LoadPoints "robot1.pts"
  P99 = CurPos
  SavePoints "robot1.pts"

Select bli22
	 Case 5
	 	Print "The currently moving camera bit="; Print bli22
	  	I20 = 5
	  If CZ(P99) < -50 Then
	     CZ(P99) = -50
	     Move P99
	  EndIf
	  If CY(P99) < 200 Then
	     Go P0 CP
	  EndIf
	  Go P(bli22)
  	 
	Case 11
		Print "The currently moving camera bit="; Print bli22
	    I20 = 11
	  If CZ(P99) < -30 Then
	     CZ(P99) = -30
	     Move P99
	  EndIf
	  If CY(P99) > 200 Then
	     Go P0 CP
	  EndIf
	  Go P(bli22)
	 	  
	Default
	  	
	  If I20 = 0 Then
	  	GoTo label_aa
	  EndIf

	  Print "Current offsetX="; Print bra11
	  Print "Current offsetY="; Print bra12
	  Print "Current offsetU="; Print bra13
	  Go P(I20) +X(bra11) +Y(bra12) +U(bra13) /L 'The currently moving camera bit 	
	  WaitPos
  
Send

label_aa:

	S19$ = S2$
	LoadPoints "robot1.pts"
	P98 = CurPos
	SavePoints "robot1.pts"
	R15 = CX(P98)
	R16 = CY(P98)
	R17 = CZ(P98)
	R18 = CU(P98)
	S15$ = Str$(R15)
	S16$ = Str$(R16)
	S17$ = Str$(R17)
	S18$ = Str$(R18)
	S13$ = "_" + S15$ + "_" + S16$ + "_" + S18$
	S2$ = ""
	S11$ = S19$ + S13$ + "_OKOK_a"; B1 = True
      
Fend
Function RecordCurrentPosition(bli23 As Integer)
''''''''''''''''''''''''''''''' Record the current position of the robot '''''''''''''''''''''''''''''''''''''    

'--- Check record robot position index检查记录机器人位置索引 ---
Lable_17:
  If bli23 < 900 Or bli23 > 999 Then
	    S11$ = S2$ + "_E054_a"; B1 = True
	    Print "The record robot position index is abnormal"
	     Pause
	    Wait 2
	    GoTo Lable_17
  EndIf

If bli23 >= 900 Then
    LoadPoints "robot1.pts"
	P99 = CurPos
	CX(P(bli23)) = CX(P99)
	CY(P(bli23)) = CY(P99)
	CZ(P(bli23)) = CZ(P99)
	CU(P(bli23)) = CU(P99)
	SavePoints "robot1.pts"
	S11$ = S2$ + "_OKOK_a"; B1 = True
	Print "The current position of the robot is recorded"
EndIf
   
Fend
Function WriteRobotDO
''''''''''''''''''''''''''''''' Write robot universal output '''''''''''''''''''''''''''''''''''''    

Integer d
For d = 1 To 7
	S20$(d) = Mid$(S3$(3), d, 1)
	S20$(d + 7) = Mid$(S3$(4), d, 1)
	S20$(d + 14) = Mid$(S3$(5), d, 1)
Next
For d = 1 To 16
	R20(d) = Val(S20$(d))
	If R20(d) = 1 Then
	   On (d + 63)
	ElseIf R20(d) = 0 Then
	   Off (d + 63)
	EndIf
Next
S11$ = S2$ + "_OKOK_a"; B1 = True
Print "Write robot universal output complete"

Fend
Function ReadRobotDO
''''''''''''''''''''''''''''''' Read robot universal output '''''''''''''''''''''''''''''''''''''   
   
String sta_DO$(20), sta_read_DO$(2), c1$(8), c2$(8)
Integer g, g1, sta0(8), sta1(8), aa(8), bb(8)
sta0(0) = Out(8)
sta1(0) = Out(9)
For g = 0 To 7
	aa(g) = sta0(g) Mod 2
	sta0(g + 1) = sta0(g) / 2
	If sta0(g) = 1 Then
        GoTo end_for
        EndIf
Next
end_for:
For g = 0 To 7
    c1$(g) = Str$(aa(g))
Next
sta_read_DO$(1) = c1$(0) + c1$(1) + c1$(2) + c1$(3) + c1$(4) + c1$(5) + c1$(6) + c1$(7)

For g = 0 To 7
	bb(g) = sta1(g) Mod 2
	sta1(g + 1) = sta1(g) / 2
	If sta1(g) = 1 Then
        GoTo end_for2
        EndIf
Next
end_for2:
For g = 0 To 7
    c2$(g) = Str$(bb(g))
Next
sta_read_DO$(2) = c2$(0) + c2$(1) + c2$(2) + c2$(3) + c2$(4) + c2$(5) + c2$(6) + c2$(7)
S13$ = "_" + sta_read_DO$(1) + sta_read_DO$(2)
S11$ = S2$ + S13$ + "_OKOK_a"; B1 = True
Print "Read robot universal output complete"
   
Fend
Function ReadRobotDI
''''''''''''''''''''''''''''''' Read robot universal input '''''''''''''''''''''''''''''''''''''   
   
String sta_di$(20), sta_read_di$(2), e1$(8), e2$(8)
Integer f, f1, sta_di0(8), sta_di1(8), aaa(8), bbb(8)
sta_di0(0) = In(8)
sta_di1(0) = In(9)
For f = 0 To 7
	aaa(f) = sta_di0(f) Mod 2
	sta_di0(f + 1) = sta_di0(f) / 2
	If sta_di0(f) = 1 Then
        GoTo aaa_end
        EndIf
Next
aaa_end:
For f = 0 To 7
    e1$(f) = Str$(aaa(f))
Next
sta_read_di$(1) = e1$(0) + e1$(1) + e1$(2) + e1$(3) + e1$(4) + e1$(5) + e1$(6) + e1$(7)

For f = 0 To 7
	bbb(f) = sta_di1(f) Mod 2
	sta_di1(f + 1) = sta_di1(f) / 2
	If sta_di1(f) = 1 Then
        GoTo bbb_end
        EndIf
Next
bbb_end:
For f = 0 To 7
    e2$(f) = Str$(bbb(f))
Next
sta_read_di$(2) = e2$(0) + e2$(1) + e2$(2) + e2$(3) + e2$(4) + e2$(5) + e2$(6) + e2$(7)
S13$ = "_" + sta_read_di$(1) + sta_read_di$(2)
S11$ = S2$ + S13$ + "_OKOK_a"; B1 = True
Print "Reading robot universal input complete"
      
Fend
Function GripperClamp(bli24 As Integer)
''''''''''''''''''''''''''''''' Gripper clamping '''''''''''''''''''''''''''''''''''''   
   
Select bli24
  Case 1
  	Off G1Open
  	On G1Clamp '#1Gripper clamping
  	Wait Sw(G1ClampSignal) = On, 2 'Wait for gripper 1 to clamp in place
  Case 2
  	Off G2Open
  	On G2Clamp '#2Gripper clamping
  	Wait Sw(G2ClampSignal) = On, 2 'Wait for gripper 2 to clamp in place  	
  Case 3
  	Off G3Open
  	On G3Clamp '#3Gripper clamping
  	Wait Sw(G3ClampSignal) = On, 2 'Wait for gripper 3 to clamp in place  	
  Default

Send
      
Fend
Function GripperOpen(bli25 As Integer)
''''''''''''''''''''''''''''''' Gripper open '''''''''''''''''''''''''''''''''''''    

Select bli25
  Case 1
  	Off G1Clamp
  	On G1Open '#1Gripper open
  	Wait Sw(G1OpenSignal) = On, 2 'Wait for grab 1 to open in place
  Case 2
  	Off G2Clamp
  	On G2Open '#2Gripper open
  	Wait Sw(G2OpenSignal) = On, 2 'Wait for grab 2 to open in place  	
  Case 3
  	Off G3Clamp
  	On G3Open '#3Gripper open
  	Wait Sw(G3OpenSignal) = On, 2 'Wait for grab 3 to open in place  	
  Default
Send
   
Fend

Function GripperOpenThree()
''''''''''''''''''''''''''''''' Gripper open '''''''''''''''''''''''''''''''''''''    

	Off G1Clamp
	Off G2Clamp
	Off G3Clamp
  	On G1Open '#1Gripper open
  	On G2Open '#2Gripper open
  	On G3Open '#3Gripper open
  	Wait Sw(G1OpenSignal) = On, 2 'Wait for grab 1 to open in place
  	Wait Sw(G2OpenSignal) = On, 2 'Wait for grab 2 to open in place 
	Wait Sw(G3OpenSignal) = On, 2 'Wait for grab 3 to open in place
   
Fend
Function GripperUp(bli26 As Integer)
''''''''''''''''''''''''''''''' Gripper rise '''''''''''''''''''''''''''''''''''''   
   
Select bli26
  Case 1
  	Off G1Down
  	On G1Up '1#Gripper rise
  	Wait Sw(G1UpSignal) = On, 2 'Wait for gripper 1 to rise into place
  Case 2
  	Off G2Down
  	On G2Up '2#Gripper rise
  	Wait Sw(G2UpSignal) = On, 2 'Wait for gripper 2 to rise into place  	
  Case 3
  	Off G3Down
  	On G3Up '3#Gripper rise
  	Wait Sw(G3UpSignal) = On, 2 'Wait for gripper 3 to rise into place  	
  Default
Send
   
Fend
Function GripperUpThree()
''''''''''''''''''''''''''''''' Gripper rise '''''''''''''''''''''''''''''''''''''   
   Off G1Down
   Off G2Down
   Off G3Down
  	On G1Up '1#Gripper rise
  	On G2Up '2#Gripper rise
  	On G3Up '3#Gripper rise
  	Wait Sw(G1UpSignal) = On, 2 'Wait for gripper 1 to rise into place
  	Wait Sw(G2UpSignal) = On, 2 'Wait for gripper 2 to rise into place
  	Wait Sw(G3UpSignal) = On, 2 'Wait for gripper 3 to rise into place  
Fend

Function GripperDown(bli27 As Integer)
''''''''''''''''''''''''''''''' Gripper decline '''''''''''''''''''''''''''''''''''''   
   
Select bli27
  Case 1
  	Off G1Up
  	On G1Down '1#Gripper decline
  	Wait Sw(G1DownSignal) = On, 2 'Wait for Gripper 1 to drop into place
  Case 2
  	Off G2Up
  	On G2Down '2#Gripper decline
  	Wait Sw(G2DownSignal) = On, 2 'Wait for Gripper 2 to drop into place  	
  Case 3
  	Off G3Up
  	On G3Down '3#Gripper decline
  	Wait Sw(G3DownSignal) = On, 2 'Wait for Gripper 3 to drop into place  	
  Default
Send

Fend

Function GripperDownThree()
''''''''''''''''''''''''''''''' Gripper decline '''''''''''''''''''''''''''''''''''''   
   
  	Off G1Up
  	Off G2Up
  	Off G3Up
  	On G1Down '1#Gripper decline
  	On G2Down '2#Gripper decline
  	On G3Down '3#Gripper decline
  	
  	Wait Sw(G1DownSignal) = On, 2 'Wait for Gripper 1 to drop into place
  	Wait Sw(G2DownSignal) = On, 2 'Wait for Gripper 2 to drop into place
  	Wait Sw(G3DownSignal) = On, 2 'Wait for Gripper 3 to drop into place

Fend
Function PalletOffset
''''''''''''''''''''''''''''''' Calculation of array X/Y axis offset '''''''''''''''''''''''''''''''''''''   

Integer bli100, bli101, bli102, bli103, bli104

bli104 = I8 'I8Number of array rows (X direction)
bli100 = I3 'Hole number index of I3 material tray  
bli101 = I3 'Hole number index of I3 material tray
bli100 = bli100 - 1 '  2
bli101 = bli101 - 1 '  2
bli100 = bli100 / bli104 '  2
bli102 = bli100 '  3
bli102 = bli102 * bli104  ' 6
bli101 = bli101 - bli102  ' 
R12 = R10
R12 = R12 * bli101 'Calculate the X-axis offset of the array
R13 = R11
R13 = R13 * bli100 'Calculate the Y-axis offset of the array
Print "X/Y offset of the array="; Print R12, R13
   
Fend

Function StartTask
'''''''''''''''''''''''''''''''' Starting background Tasks '''''''''''''''''''''''''''''''''''''   
'
'Do
''--- Determine the status of background tasks and start them ---
' If TaskState(PCNET) = 0 Then
'	Xqt 66, PCnet, NoEmgAbort
' ElseIf TaskState(ManualMode) = 0 Then
'	Xqt 67, ManualMode
' ElseIf TaskState(MonitorIO) = 0 Then
'    Xqt 68, MonitorIO
' EndIf
'Loop
'     
Fend
Function MonitorIO
''''''''''''''''''''''''''''''' IO monitoring and alarm  '''''''''''''''''''''''''''''''''''''   

Do
'--- Gripper 1 gripper cylinder clamping signal monitoring ---
If Oport(G1Clamp) = On And B24 = True Then
   Wait Sw(G1ClampSignal) = On, 0.2
   If Oport(G1Clamp) = On And Sw(G1ClampSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1600_a"; B1 = True
      Print "Gripper 1 gripper cylinder clamping signal is abnormal"
      B24 = False
      EndIf
   EndIf
EndIf

'--- Gripper 1 gripper cylinder release signal monitoring ---
If Oport(G1Open) = On Then
   Wait Sw(G1OpenSignal) = On, 0.5
   If Oport(G1Open) = On And Sw(G1OpenSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1601_a"; B1 = True
      Print "Abnormal release signal of gripper 1 gripper cylinder"
       Pause
      EndIf
   EndIf
EndIf

'--- Gripper 2 gripper cylinder clamping signal monitoring ---
If Oport(G2Clamp) = On And B25 = True Then
   Wait Sw(G2ClampSignal) = On, 0.2
   If Oport(G2Clamp) = On And Sw(G2ClampSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1602_a"; B1 = True
      Print "Gripper 2 gripper cylinder clamping signal is abnormal"
      B25 = False
      EndIf
   EndIf
EndIf

'--- Gripper 2 gripper cylinder release signal monitoring ---
If Oport(G2Open) = On Then
   Wait Sw(G2OpenSignal) = On, 0.5
   If Oport(G2Open) = On And Sw(G2OpenSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1603_a"; B1 = True
      Print "Abnormal release signal of gripper 2 gripper cylinder"
       Pause
      EndIf
   EndIf
EndIf

'--- Gripper 3 gripper cylinder clamping signal monitoring ---
If Oport(G3Clamp) = On And B26 = True Then
   Wait Sw(G3ClampSignal) = On, 0.2
   If Oport(G3Clamp) = On And Sw(G3ClampSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1604_a"; B1 = True
      Print "Gripper 3 gripper cylinder clamping signal is abnormal"
      B26 = False
      EndIf
   EndIf
EndIf

'--- Gripper 3 gripper cylinder release signal monitoring ---
If Oport(G3Open) = On Then
   Wait Sw(G3OpenSignal) = On, 0.5
   If Oport(G3Open) = On And Sw(G3OpenSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1605_a"; B1 = True
      Print "Abnormal release signal of gripper 3 gripper cylinder"
     Pause
      EndIf
   EndIf
EndIf

'--- Lifting signal monitoring of lifting cylinder of gripper 1 ---
If Oport(G1Up) = On Then
   Wait Sw(G1UpSignal) = On, 1
   If Oport(G1Up) = On And Sw(G1UpSignal) = Off Then
      'If S2$ <> "" Then
      S11$ = S2$ + "_E1606_a"; B1 = True
      Print "Abnormal lifting signal of lifting cylinder of gripper 1"
      Pause
      'EndIf
   EndIf
EndIf

'--- Monitoring of lowering signal of lifting cylinder of gripper 1 ---
'If Oport(G1Down) = On Then
'   Wait Sw(G1DownSignal) = On, 1
'   If Sw(G1DownSignal) = Off Then 'If Oport(G1Down) = On And Sw(G1DownSignal) = Off
'      If S2$ <> "" Then
'      S11$ = S2$ + "_E1607_a"; B1 = True
'      Print "Abnormal lowering signal of lifting cylinder of gripper 1"
'      Pause
'      EndIf
'   EndIf
'EndIf

'--- Lifting signal monitoring of lifting cylinder of gripper 2 ---
If Oport(G2Up) = On Then
   Wait Sw(G2UpSignal) = On, 1
   If Oport(G2Up) = On And Sw(G2UpSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1608_a"; B1 = True
      Print "Abnormal lifting signal of lifting cylinder of gripper 2"
      Pause
      EndIf
   EndIf
EndIf

'--- Monitoring of lowering signal of lifting cylinder of gripper 2 ---
'If Oport(G2Down) = On Then
'   Wait Sw(G2DownSignal) = On, 1
'      If Sw(G2DownSignal) = Off Then 'If Oport(G2Down) = On And Sw(G2DownSignal) = Off Then
'      If S2$ <> "" Then
'      S11$ = S2$ + "_E1609_a"; B1 = True
'      Print "Abnormal lowering signal of lifting cylinder of gripper 2"
'      Pause
'      EndIf
'   EndIf
'EndIf

'--- Lifting signal monitoring of lifting cylinder of gripper 3 ---
If Oport(G3Up) = On Then
   Wait Sw(G3UpSignal) = On, 1
   If Oport(G3Up) = On And Sw(G3UpSignal) = Off Then
      If S2$ <> "" Then
      S11$ = S2$ + "_E1610_a"; B1 = True
      Print "Abnormal lifting signal of lifting cylinder of gripper 3"
      Pause
      EndIf
   EndIf
EndIf

'--- Monitoring of lowering signal of lifting cylinder of gripper 3 ---
'If Oport(G3Down) = On Then
'   Wait Sw(G3DownSignal) = On, 1
'   If Sw(G3DownSignal) = Off Then 'If Oport(G3Down) = On And Sw(G3DownSignal) = Off Then
'      If S2$ <> "" Then
'      S11$ = S2$ + "_E1611_a"; B1 = True
'      Print "Abnormal lowering signal of lifting cylinder of gripper 3"
'      Pause
'      EndIf
'   EndIf
'EndIf
   
   If B19 = True Then
   	B19 = False
   	Pause
   EndIf
   
  
Loop

Fend
Function bgmain
'''''''''''''''''''''''''''''''' Starting background Tasks ''''''''''''''''''''''''''''''''''''' 

Do

'--- Determine the status of background tasks and start them ---
' If TaskState(PCNET) = 0 Or TaskState(PCNET) = 5 Then
'	'Xqt 66, PCnet, NoEmgAbort
' EndIf

 If TaskState(MonitorIO) = 0 Or TaskState(MonitorIO) = 5 Then
    Xqt 68, MonitorIO
 EndIf

'---------Connected to the PC连接PC-------- 
again_1:
   Print "bgmain is beginning"
   Call PCnet
   Wait 0.01
GoTo again_1

Loop

Fend

Function CPK_TEST

Tool 0
Weight 5 'The load set
Motor On 'Motor on electric
'Axis positioning accuracy setting Fine 3, 3, 3, 3 '4
FineDist 0.1 'Target point positioning accuracy setting
Power High 'High power mode setting
Speed 100 'Internal speed setting（％）
SpeedS 2000 'Straight-line speed setting（mm/sec）

Accel 100, 100 'Speed ratio setting（％）
AccelS 15000, 8000 'Add or subtract speed value setting（mm/sec2）
PTPBoost 75, 75, 75 'Microshift parameter setting
'LimitTorque 20, 20, 20, 20 'Torque limit setting

SpeedFactor 80
Integer gg
For gg = 1 To 100
	Move P50
	Wait 2
	Move P51
	Wait 2
Next

Fend

Function PCnet
''''''''''''''''''''''''''''''' Communicate with upper computer software '''''''''''''''''''''''''''''''''''''
   S10$ = ""
   CloseNet #201
   Wait 0.1
   OpenNet #201 As Server
   Print "waiting for connect....."
   WaitNet #201
   Print "connect Success....."
   
Do
   If ChkNet(201) < 0 Then
   Print "check the NET fail....."
   Exit Do
   EndIf
   
   '---------recevie From PC---------
   If ChkNet(201) > 0 Then
   Input #201, S10$
   Print "receive from PC=" + S10$
   Print #201, S10$
   Print "send to PC=" + S10$
   
   Call Message_analyze
   EndIf
          
   
'---------Send to PC-------------     
   If B1 = True Then
      B1 = False
      Print #201, S11$
      Print S11$
      
      S10$ = ""
      S3$(0) = ""
      S12$ = ""
      S13$ = ""
      S11$ = ""
   EndIf
             
   Wait 0.001
Loop


Fend
Function Message_analyze
	
	   '---------parsing strings---------    
   S3$(0) = Left$(S10$, 3)
   S3$(1) = Mid$(S10$, 5, 3)
   S3$(2) = Mid$(S10$, 9, 2)
   S3$(3) = Mid$(S10$, 12, 7)
   S3$(4) = Mid$(S10$, 20, 7)
   S3$(5) = Mid$(S10$, 28, 7)
   S3$(6) = Right$(S10$, 1)
   
   S3$(7) = Mid$(S10$, 4, 1)
   S3$(8) = Mid$(S10$, 8, 1)
   S3$(9) = Mid$(S10$, 11, 1)
   S3$(10) = Mid$(S10$, 19, 1)
   S3$(11) = Mid$(S10$, 27, 1)
   S3$(12) = Mid$(S10$, 35, 1)
   
   
   If S3$(0) = "101" Then
    Call WriteRobotDO
        GoTo Lable_3
   EndIf
   
   If S3$(0) = "102" Then
      	Call ReadRobotDO
        GoTo Lable_3
   EndIf
   If S3$(0) = "103" Then
      	Call ReadRobotDI
        GoTo Lable_3
   EndIf
   
   If S3$(0) = "104" Then
      R21 = Val(S3$(3))
      Call WriteRobotSpeed
   Else
	  R1 = Val(S3$(1))
	  R2 = Val(S3$(2))
	  R3 = Val(S3$(3))
	  R4 = Val(S3$(4))
	  R5 = Val(S3$(5))
	  S2$ = S3$(0)
   EndIf
   Wait 0.1

	'---------check function code--------
  ' S3$(0) = Left$(S10$, 3)
   I5 = Val(S3$(0))
   If I5 <= 0 Then
   Print "function code is " + S3$(0)
   S11$ = S2$ + "_E1619_a"; B1 = True
   B1 = True
   B19 = True
   Wait 0.5
   GoTo Lable_3
   EndIf

   '---------check string num--------    
   I6 = Len(S10$)
   If I6 <> 36 Then
   Print "Not enough strings....."
   S11$ = S2$ + "_E1618_a"; B1 = True
   B1 = True
   B19 = True
   Wait 0.5
   GoTo Lable_3
   EndIf
   '---------check the end string-----   	
   S4$ = Mid$(S10$, 36, 1)
   S5$ = Right$(S10$, 1)
   If S4$ <> "a" Or S5$ <> "a" Then
   Print "check the end string is error....."
   S11$ = S2$ + "_E1621_a"; B1 = True
   B1 = True
   B19 = True
   Wait 0.5
   GoTo Lable_3
   EndIf
   '---------check separator-----   	
   Integer a
   For a = 7 To 11
   	  If S3$(a) <> S3$(a + 1) Then
   Print "check the separator....."
   S11$ = S2$ + "_E1622_a"; B1 = True
   B1 = True
   B19 = True
   Wait 0.5
   GoTo Lable_3
      EndIf
   Next


	
   '--------- data analysis---------       
   Select S2$

    Case "012"  'Obtaining robot position
    	Call GetCurrentPosition(R1)
    	S2$ = ""
    Case "015"  'Record the current position of the robot
    	Call GetCurrentPosition_1
     	S2$ = ""
    Case "105"  'Reading robot speed
    	Call ReadRobotSpeed
    	S2$ = ""
    Case "018"  'visual switch
    	Call photo_change(R1)
    	S2$ = ""
    Send
     
Lable_3:
	   S3$(0) = ""

Fend
Function WriteRobotSpeed
'''''''''''''''''''''''''''''''' Write the external velocity of the robot '''''''''''''''''''''''''''''''''''''   

'--- Check the external velocity data of the robot ---
If R21 < 1 Then
  R21 = 1
ElseIf R21 > 100 Then
  R21 = 100
EndIf

I1 = R21 'Robot external speed write
S11$ = "104_OKOK_a"; B1 = True
Print "Write robot external speed complete"
    
Fend
Function ReadRobotSpeed
'''''''''''''''''''''''''''''''' Read the external speed of the robot '''''''''''''''''''''''''''''''''''''   

'--- Robot external speed character length read ---
S6$ = Str$(I1)
I7 = Len(S6$)

'--- Robot external speed character length complement ---
If I7 = 1 Then
  S6$ = "00" + S6$
ElseIf I7 = 2 Then
  S6$ = "0" + S6$
ElseIf I7 = 3 Then
  S6$ = S6$
EndIf

S11$ = S2$ + "_" + S6$ + "_OKOK_a"; B1 = True
Print "Read robot external speed complete"
    
Fend
Function photo_change(bli67 As Integer)

Label667:
	If bli67 < 1 Or bli67 > 2 Then
	S11$ = S2$ + "_E1620_a"; B1 = True
	Wait 1
	  Pause
	  GoTo Label667
	EndIf
	
	If bli67 = 1 Then
		B17 = True
		B20 = True
		Print "B17 = True;B20 = True"
	EndIf
    If bli67 = 2 Then
		B17 = False
		B20 = False
	    Print "B17 = False;B20 = False"
	EndIf
	
   S11$ = S2$ + "_OKOK_a"; B1 = True
   Print "Visual switching succeeded"
    			
Fend
Function Buffer_Take(bli33 As Integer, bli34 As Integer)
'''''''''''''''''''''''''''''''' Robot take product on the buffer position '''''''''''''''''''''''''''''''''''''  

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Gripper 1/2/3 up 
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for the gripper 1/2/3 to rise into place

'--- Check the gripper index  ---
Lable_79:
  If bli34 < 1 Or bli34 > 3 Then
     S11$ = S2$ + "_E1630_a"; B1 = True
     Print "Gripper index exception"
     Wait 2
     GoTo Lable_79
  EndIf

'--- Check the position index  ---
Lable_80:
  If bli33 < 1 Or bli33 > 4 Then
     S11$ = S2$ + "_E1629_a"; B1 = True
     Print "Position index exception"
     Wait 2
     GoTo Lable_80
  EndIf
  
Integer bli56
If bli34 = 1 Then
   bli56 = 65
ElseIf bli34 = 2 Then
   bli56 = 69
ElseIf bli34 = 3 Then
   bli56 = 73
EndIf
   bli56 = bli56 + bli33 - 1
  
'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition ---
If CZ(P99) < CZ(P(bli56)) - 2 Then
   CZ(P99) = CZ(P(bli56))
   Move P99
EndIf
If CY(P99) <= 130 Then
   Go P0 CP
EndIf
  
Hand P(bli56), Lefty
'---Move to +5mm above buffer take position ---  
Go P(bli56) +Z(5) /L

SpeedS 1000; AccelS 2000, 2000
Call GripperOpen(R2)
Call GripperDown(R2)
Go P(bli56) /L

Call GripperClamp(R2)
Wait 0.1
  
'---Move to +5mm above buffer take position ---    
Move P(bli56) +Z(5) /L
Call GripperUp(R2)

S2$ = ""
S11$ = "020_OKOK_a"; B1 = True
Print "Robot take product on the buffer position completed"
SpeedS 2000; AccelS 15000, 8000
		
Fend
Function Buffer_Put(bli35 As Integer, bli36 As Integer)
'''''''''''''''''''''''''''''''' Robot put product on the buffer position '''''''''''''''''''''''''''''''''''''  

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Gripper 1/2/3 up 
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for the gripper 1/2/3 to rise into place

'--- Check the gripper index  ---
Lable_81:
  If bli36 < 1 Or bli36 > 3 Then
     S11$ = S2$ + "_E1630_a"; B1 = True
     Print "Gripper index exception"
     Wait 2
     GoTo Lable_81
  EndIf

'--- Check the position index  ---
Lable_82:
  If bli35 < 1 Or bli35 > 4 Then
     S11$ = S2$ + "_E1629_a"; B1 = True
     Print "Position index exception"
     Wait 2
     GoTo Lable_82
  EndIf
  
Integer bli57
If bli36 = 1 Then
   bli57 = 79
ElseIf bli36 = 2 Then
   bli57 = 83
ElseIf bli36 = 3 Then
   bli57 = 87
EndIf
   bli57 = bli57 + bli35 - 1
  
'--- Get the current robot position  ---
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition ---
If CZ(P99) < CZ(P(bli57)) - 2 Then
   CZ(P99) = CZ(P(bli57))
   Move P99
EndIf
If CY(P99) <= 130 Then
   Go P0 CP
EndIf
  
Hand P(bli57), Lefty
'---Move to +5mm above buffer put position ---  
Go P(bli57) +Z(5) /L

SpeedS 1000; AccelS 2000, 2000
Call GripperDown(R2)
Go P(bli57) /L

Call GripperOpen(R2)
Wait 0.1
  
'---Move to +5mm above buffer put position ---    
Move P(bli57) +Z(5) /L
Call GripperUp(R2)

S2$ = ""
S11$ = "021_OKOK_a"; B1 = True
Print "Robot put product on the buffer position completed"
SpeedS 2000; AccelS 15000, 8000
		
Fend
Function ScanTrayCode
''''''''''''''''''''''''''''''' ScanTrayCode '''''''''''''''''''''''''''''''''''''   

Off G1Down; Off G2Down; Off G3Down; On G1Up; On G2Up; On G3Up 'Grip 1/2/3 up
Wait Sw(G1UpSignal) = On; Wait Sw(G2UpSignal) = On; Wait Sw(G3UpSignal) = On 'Wait for gripper 1/2/3 to rise into position
Tool 0

'--- Get the current robot position  --- 
LoadPoints "robot1.pts"
P99 = CurPos
SavePoints "robot1.pts"

'--- Robot motion transition ---
'If CZ(P99) < CZ(P(bli05)) - 2 Then
' CZ(P99) = CZ(P(bli05))
' Move P99
'EndIf
'If CY(P99) <= 150 Then
' Go P0 CP
'EndIf
Hand P(80), Lefty
Go P(80) /L 'Incoming product scanning point

S2$ = ""
S11$ = "036_OKOK_a"; B1 = True
Print "The robot arrives at the tray code scanning point"
   
Fend

