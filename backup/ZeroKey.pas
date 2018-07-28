program ZeroKey;

{$mode objfpc}{$H+}
{$codepage utf8}
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Forms, Interfaces, MainForm, WordProcess, windows, SysUtils, SystemHelper,
  KeyUtil;

{$R *.res}
const WH_KEYBOARD_LL = 13;
      WH_MOUSE_LL = 14;

var keyboardHook, mouseHook : cardinal;
    vnProcessor : TWordProcessor;

function KeyDownHookProc(nCode: integer; Msg: WParam; Data: LParam): LRESULT; stdcall;
var info : ^KeybdLLHookStruct absolute Data;
    char : UnicodeChar;
    kbstate : TKeyboardState;
    unicodeResult: LongInt;
begin
  result := CallNextHookEx(keyboardHook,nCode,Msg,Data);

  if (Msg = WM_KEYDOWN) and (not IsVirtualKey) then
  begin
    case info^.vkCode of
      VK_SPACE: vnProcessor.SpaceProcess();
      VK_BACK: vnProcessor.BackSpaceProcess();
      VK_A..VK_Z:
        begin
          GetKeyboardState(kbstate);
          unicodeResult := ToUnicode(info^.vkCode,info^.scanCode,kbState,@char,SizeOf(char),info^.flags);
          IF (IsCapslock()) or (IsShift()) then
            char := UpCase(char)
          else
            char := LowerCase(char);
          if vnProcessor.AddWord(char) then result := 1;
        end;
    else
      vnProcessor.OtherKeysProcess();
    end;
  end;
end;
//
function MouseHookProc(nCode: integer; Msg: WParam; Data: LParam): LRESULT; stdcall;
begin
  if (Msg <> WM_MOUSEWHEEL) and (Msg <> WM_MOUSEMOVE) then
    vnProcessor.OtherKeysProcess();
  result := CallNextHookEx(mouseHook,nCode,Msg,Data);
end;

begin
  vnProcessor := TWordProcessor.Create();
  keyboardHook := SetWindowsHookEx(WH_KEYBOARD_LL, @KeyDownHookProc,HINSTANCE(),0);
  mouseHook := SetWindowsHookEx(WH_MOUSE_LL,@MouseHookProc,HINSTANCE(),0);
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TwndMain, wndMain);
  Application.Run;

  UnhookWindowsHookEx(keyboardHook);
  UnhookWindowsHookEx(mouseHook);
  FreeAndNil(vnProcessor);
  FreeAndNil(wndMain);
  FreeAndNil(Application);
end.

