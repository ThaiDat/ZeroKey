unit KeyUtil;

{$mode objfpc}{$H+}
{$codepage utf8}

interface
uses KeyCodeDefine, sysutils, windows, SystemHelper, Clipbrd;

type TLoopMode = (Up,Down);

var DelayTime: 10 .. 1000;

function GetPosInFull(char: Unicodechar): integer;

function DeCode(st: Unicodestring; termEscape: integer = 0): UnicodeString;

function CheckTermEscape(st : UnicodeString): boolean;

function Encode(st: Unicodestring; var termEscape : integer): Unicodestring;

procedure PasteString(pastestr : UnicodeString; BackSpTimes: byte);

var IsVirtualKey : boolean = false;

implementation

function GetPosInFull(char: Unicodechar): integer;
begin
  result := Pos(char,Alphabet_Full);
end;
//-----------------------------------------------------------------------------
function DeCode(st: Unicodestring; termEscape : integer = 0): UnicodeString;
var
  i, position, temp: Integer;   //temp is distance between two char in alphabet
  tempChar: WideChar;
begin
  if termEscape > 0 then exit(st);

  result:=''; i:= 1;
  while (i <= length(St)) do
  begin
    position := GetPosInFull(st[i]);
    if (Alphabet_Full[position] = Alphabet_Nosign[position]) and (Alphabet_Nosign[Position] = Alphabet_Sign[position])
    then result += st[i]
    else
      begin
        temp := Position - GetPosInFull(Alphabet_Nosign[position]);
        case temp of
        1: insert(Selected_Key_Sign^[2],st,length(st)+1);
        2: insert(Selected_Key_Sign^[3],st,length(st)+1);
        3: insert(Selected_Key_Sign^[4],st,length(st)+1);
        4: insert(Selected_Key_Sign^[5],st,length(st)+1);
        5: insert(Selected_Key_Sign^[6],st,length(st)+1);
        end;
        temp := Position - GetPosInFull(Alphabet_Sign[position]);
        tempChar := Alphabet_Nosign[ GetPosInFull( Alphabet_Sign[Position] )];
        result += tempchar;
        case temp of
        1: insert(Selected_Key_Nosign^[6],st,i+1);
        6: case LowerCase(tempChar) of
           'a': insert(Selected_Key_Nosign^[1],st,i+1);
           'e': insert(Selected_Key_Nosign^[2],st,i+1);
           'o': insert(Selected_Key_Nosign^[3],st,i+1);
           end;
        12: if (lowercase(tempChar) = 'a') then insert(Selected_Key_Nosign^[4],st,i+1) else insert(Selected_Key_Nosign^[5],st,i+1) ;
        end;
      end;
    inc(i);
  end;
end;
//-----------------------------------------------------------------------------
function FindAffectedKey(const source: unicodestring; key: unicodechar; const mode: TLoopMode): integer;
var
  i: Integer;
begin
  key := LowerCase(key);
  if mode =TLoopMode.Up then
    for i:= 1 to length(source) do
      begin
        if pos(Alphabet_Nosign[GetPosInFull(source[i])]{to nosign} ,Selected_Affect^[key]) <> 0 then
          begin
            if (pos(Alphabet_Nosign[GetPosInFull(source[i+1])]{to nosign} ,Selected_Affect^[key]) <> 0)
                and (pos(Alphabet_Nosign[GetPosInFull(source[i+2])]{to nosign} ,Selected_Affect^[key]) <> 0 )
            then
              exit(i+1)
            else if ( (LowerCase(source[i]) = 'i') and (LowerCase(Source[i - 1]) = 'g') and (pos(Alphabet_Nosign[GetPosInFull(source[i+1])]{to nosign} ,Selected_Affect^[key]) <> 0) )
                 or ( (LowerCase(source[i]) = 'u') and (LowerCase(Source[i - 1]) = 'q') and (pos(Alphabet_Nosign[GetPosInFull(source[i+1])]{to nosign} ,Selected_Affect^[key]) <> 0) )
                 then exit(i+1)
                 else exit(i);
          end;
      end
  else
  for i:= length(source) downto 1 do
    if pos(Alphabet_Nosign[GetPosInFull(source[i])]{to nosign} ,Selected_Affect^[key]) <> 0 then exit(i);
  result := -1;
end;
//-----------------------------------------------------------------------------
function CheckTermEscape(st : UnicodeString): boolean;
var
  t,i: Integer;
  SyllableNum : byte = 0; //SyllableNum is the number of Syllable (in Vietnamese: âm tiết)
begin
  t:= length(st); result := false;
  if t < 2 then exit(false); //st has only 1 char
  case LowerCase(st[t]) of
    'q','d','k','l','v','b':
       exit(true);
    'g':
       if (st[t-1] <> 'N') and (st[t-1] <> 'n') then exit(true);
    'h':
       begin
         if pos(st[t-1],'NnCcGgPpTtKk') = 0 then exit(true);
         if t = 2 then exit(false); // st has only 2 chars : (N/C/G/P/T)H
         case LowerCase(st[t-1]) of
           'n','c':
              if pos(Alphabet_NoSign[GetPosInFull( Alphabet_Sign[GetPosInFull(st[t-2])] )] , 'aAeEiI' ) = 0 then exit(true);
           'p','t','k': exit(true);
           'g' : if (st[t-2] <> 'N') and (st[t-2] <> 'n') then exit(true);
         end;
       end;
    't','p','c','n','m':
       if pos(Alphabet_NoSign[GetPosInFull( Alphabet_Sign[GetPosInFull(st[t-1])] )] , 'aAeEiIoOuUyY' ) = 0 then exit(true);
  end;
  // To this line st[t] is default vowel (aeiou)
  for i := t downto 1 do
    if (pos(Alphabet_NoSign[GetPosInFull( Alphabet_Sign[GetPosInFull(st[i])] )] , 'aAeEiIoOuUyY') <> 0) then //not vowel
      begin
        Inc(SyllableNum);
        break;
      end;
  for i := i -1 downto 1 do
    if (pos(Alphabet_NoSign[GetPosInFull( Alphabet_Sign[GetPosInFull(st[i])] )] , 'aAeEiIoOuUyY') = 0) then
      break;
  for i:= i - 1 downto 1 do
    if (pos(Alphabet_NoSign[GetPosInFull( Alphabet_Sign[GetPosInFull(st[i])] )] , 'aAeEiIoOuUyY') <> 0) then //is vowel
      begin
        inc(SyllableNum);
        break;
      end;
  if (SyllableNum >= 2) then exit(true);
end;

//-----------------------------------------------------------------------------
function Encode(st: Unicodestring; var termEscape : integer): Unicodestring;
var i , j, affectPos, t: integer;
loopMode: TLoopMode;
begin
  result:=st[1]; i:=2;
  while i <= length(st) do
  begin
    if termEscape > 0 then result += st[i] else //if TermEscaping Enabled
    if LowerCase(st[i]) = Selected_Key_Sign^[1] then //if st[i] = z (telex)
      begin
        t := 0;
        for j:=1 to length(result) do
          if ( pos(Alphabet_Nosign[GetPosInFull(result[j])],Selected_Affect^[Selected_Key_Sign^[1]]) <> 0 ) and ( pos(result[j],'aeiouyAEIOUY') = 0 ) then
            begin
              result[j] := Alphabet_Nosign[GetPosInFull(Alphabet_Sign[GetPosInFull(result[j])])]; // to normal
              t := 1;
            end;
        if t = 0 then
          begin
            result+=Selected_Key_Sign^[1]; //no affected key
            termEscape := i;
          end;
      end
    else if pos(LowerCase(St[i]),Selected_Key_Sign^)<>0 then // if st[i] in Key_sign other than z
      begin
        if pos( Alphabet_Nosign[ GetPosInFull( Alphabet_Sign[ GetPosInFull(result[length(result)]) ] )],'aeiouyAEIOUY') <> 0 then
          loopMode := TLoopMode.Up
        else
          loopMode:= TLoopMode.Down; // detect loop mode

        affectPos := FindAffectedKey(result,st[i],loopMode);

        if (affectPos > 0) then
          begin
            t := GetPosInFull(result[affectPos]);
            if (t - GetPosInFull(Alphabet_Nosign[t]) = Selected_Rule^[LowerCase(st[i])]) then //duplicate key
              begin
                result[affectPos] := Alphabet_Nosign[t];
                result += st[i];
                termEscape := i;
              end
            else
              result[affectPos] := Alphabet_Full[ Selected_Rule^[LowerCase(st[i])] + GetPosInFull( Alphabet_Nosign[t]) ]
          end
        else result += st[i]; //no affected key
      end
    else if pos(LowerCase(st[i]),Selected_Key_Nosign^)<>0 then // if st[i] in key_no_sign
      begin
        affectPos := FindAffectedKey(result,st[i],TLoopMode.Down);
        if (affectPos > 0) then
          begin
            t := GetPosInFull(result[affectPos]);
            if (t - GetPosInFull(Alphabet_Sign[t]) = Selected_Rule^[LowerCase(st[i]) ]) then //duplicate key
              begin
                result[affectPos] := Alphabet_Sign[t];
                result += st[i];
                termEscape := i;
              end
            else
              result[affectPos] := Alphabet_Full[ Selected_Rule^[LowerCase(st[i])] + GetPosInFull( Alphabet_Sign[t]) ]
          end
        else result += st[i]; //no affected key
      end
    else  //if st[i] do not affect current word
      begin
        result += st[i];
      end;

    inc(i);
  end;//end while
end;
//-----------------------------------------------------------------------------
procedure PasteString(pastestr: UnicodeString; BackSpTimes: byte);
var
  tempClipbrd: UnicodeString;
begin
  tempClipbrd := Clipboard().AsText;
  Clipboard().AsText := pastestr;
  Sleep(10);
  IsVirtualKey := true;
  while (BackSpTimes > 0) do
  begin
    keybd_event(VK_BACK,0,0,0); //press
    keybd_event(VK_BACK,0,KEYEVENTF_KEYUP,0); // release
    dec(BackSpTimes);
  end;

  if (IsShift()) then
    begin
      keybd_event(VK_INSERT,0,0,0);//press INSERT
      keybd_event(VK_INSERT,0,2,0);//release INSERT
    end
  else //not pressing SHIFT
    begin
      keybd_event(VK_SHIFT,0,0,0); //press SHIFT
      keybd_event(VK_INSERT,0,0,0);//press INSERT
      keybd_event(VK_SHIFT,0,2,0);//release INSERT
      keybd_event(VK_INSERT,0,2,0); // release SHIFT
    end;
    //finally
    Sleep(DelayTime); //delay for program handle key event
    IsVirtualKey := false;
    Clipboard().AsText := tempClipbrd;
end;
//------------------------------------------------------------------------------



end.

