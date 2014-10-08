/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         CreateBtn_Click
*/
CreateBtn_Click: 
FileName = VRFileDialog( VRWindow(), "Create Database", "Save", "", , ,  )
if FileName = "" then
    return
ok = VRMethod( "FieldList", "GetStringList", "Fields." )


status = RxViperCreateDatabase(FileName, '0', Fields.)
if status = 1 then
Do
    Buttons.1 = "OK"
    Buttons.0 = 1
    id = VRMessage( VRWindow(), "Database created.", "Database creation status", "Information", "Buttons.", OK, OK )
    ok = VRMethod( "FieldList", "Clear" )
    ok = VRSet( "EF_1", "Value", "" )
    ok = VRSet( "CreateBtn", "Enabled", 0 )
    
    return
End
Else
Do
   Buttons.1 = "OK"
    Buttons.0 = 1

   id = VRMessage( VRWindow(), "Database creation failed.", "Database creation status", "Information", "Buttons.", OK, OK )
    
 
End


return

/*:VRX         EF_1_Change
*/
EF_1_Change: 
ok = VRMethod( "FieldList", "GetStringList", "FieldList." )
if FieldList.0 = 0 then
    ok = VRSet( "CreateBtn", "Enabled", 0 )
    
return

/*:VRX         EF_1_GotFocus
*/
EF_1_GotFocus: 

return

/*:VRX         EF_1_KeyPress
*/
EF_1_KeyPress: 

key = VRGet( "EF_1", "KeyString" )
 if key = '{Newline}' then
Do

  if Modify = 0 then
  Do
    newfield = VRGet( "EF_1", "Value" )
    if newfield = "" then
        return
    else
        ok = VRSet( "CreateBtn", "Enabled", 1 )
        
    ok = VRMethod( "FieldList", "GetStringList", "Fields." )
    if Fields.0 = 0 then
        Fields.0 = 1

    position = VRMethod( "FieldList", "AddString", newfield, ) 
       
    ok = VRSet( "EF_1", "Value", "" )
    
  End
  Else
  Do
        modfield = VRGet( "EF_1", "Value" )
        if modfield <> "" then
        Do
            selected = VRGet( "FieldList", "Selected" )
            selectedstring = VRGet( "FieldList", "SelectedString" )
            ok = VRMethod( "FieldList", "Deselect", selected )
            
            position = VRMethod( "FieldList", "AddString", modfield, selected )
        End
        Else
            selectedstring = VRGet( "FieldList", "SelectedString" )
             
        ok = VRMethod( "FieldList", "DeleteString", selectedstring )
        ok = VRSet( "EF_1", "Value", "" )

        Modify = 0
  End

    ok = VRSet( "InsertBtn", "Enabled", 0 )
End


return

/*:VRX         EF_1_Verify
*/
EF_1_Verify: 


return

/*:VRX         FieldList_Click
*/
FieldList_Click: 

    selectedfield = VRGet( "FieldList", "SelectedString" )

    ok = VRSet( "EF_1", "Value", selectedfield )
    if selectedfield <> "" then
    Modify = 1
    ok = VRSet( "InsertBtn", "Enabled", 1 )
    


return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         InsertBtn_Click
*/
InsertBtn_Click: 

value = VRGet( "EF_1", "Value" )
selected = VRGet( "FieldList", "Selected" )
ok = VRMethod( "FieldList", "Deselect", selected )
position = VRMethod( "FieldList", "AddString", value, selected )
ok = VRSet( "EF_1", "Value", "" )

ok = VRMethod( "EF_1", "SetFocus" )
Modify = 0
ok = VRSet( "InsertBtn", "Enabled", 0 )


return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         Window1_Close
*/
Window1_Close:
    call SysDropFuncs
    call Quit
return

/*:VRX         Window1_Create
*/
Window1_Create: 

/* Register the VIPER Database Engine functions... */
rc = RxFuncAdd("SysLoadFuncs","Viper", "SysLoadFuncs")
call SysLoadFuncs

Modify = 0
return

