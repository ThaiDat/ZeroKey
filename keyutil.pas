unit KeyUtil;

{$mode objfpc}{$H+}
{$codepage utf8}

interface
uses KeyCodeDefine, sysutils, windows, SystemHelper, Clipbrd;

type TLoopMode = (Up,Down);

var DelayTime: 10 .. 1000;

function PosInFull(char: Unicodechar): integer;

function ToAbSign(char: Unicodechar): Unicodechar;

function ToAbNoSign(char: Unicodechar): Unicodechar;

function ToAbClear(char: Unicodechar): Unicodechar;

function DeCode(st: Unicodestring; termEscape: integer = 0): UnicodeString;

function CheckTermEscape(st : UnicodeString): boolean;

function Encode(st: Unicodestring; var termEscape : integer): Unicodestring;

procedure PasteString(pastestr : UnicodeString; BackSpTimes: byte);

var IsVirtualKey : boolean = false;

implementation
//Return the position of <char> in Alphabet_Full
function PosInFull(char: Unicodechar): integer;
begin
  result := Pos(char,Alphabet_Full);
end;

function ToAbSign(char: Unicodechar): Unicodechar;
begin
  result:=Alphabet_Sign[PosInFull(char)];
end;

function ToAbNoSign(char: Unicodechar): Unicodechar;
begin
  result:=Alphabet_Nosign[PosInFull(char)];
end;

function ToAbClear(char: Unicodechar): Unicodechar;
begin
  result:= Alphabet_NoSign[PosInFull( Alphabet_Sign[PosInFull(char)] )];
end;

//Input: A uncicode string --> Raw string
function DeCode(st: Unicodestring; termEscape : integer = 0): UnicodeString;
var
  i, temp: Integer;   //temp is distance between two char in alphabet
  tempChar: WideChar;
begin
  if termEscape > 0 then exit(st);

  result:=''; i:= 1;
  while (i <= length(St)) do
  begin
    if (st[i] = ToAbNoSign(st[i])) and (ToAbNoSign(st[i]) = ToAbSign(st[i]))
    then result += st[i]
    else
      begin
        temp := PosInFull(st[i]) - PosInFull(ToAbNoSign(st[i]));
        case temp of
        1: insert(SelectedMethod.Key_Sign^[2],st,length(st)+1);
        2: insert(SelectedMethod.Key_Sign^[3],st,length(st)+1);
        3: insert(SelectedMethod.Key_Sign^[4],st,length(st)+1);
        4: insert(SelectedMethod.Key_Sign^[5],st,length(st)+1);
        5: insert(SelectedMethod.Key_Sign^[6],st,length(st)+1);
        end;
        temp := PosInFull(st[i]) - PosInFull(ToAbSign(st[i]));
        tempChar := ToAbClear(st[i]);
        result += tempchar;
        case temp of
        1: insert(SelectedMethod.Key_Nosign^[6],st,i+1);
        6: case LowerCase(tempChar) of
           'a': insert(SelectedMethod.Key_Nosign^[1],st,i+1);
           'e': insert(SelectedMethod.Key_Nosign^[2],st,i+1);
           'o': insert(SelectedMethod.Key_Nosign^[3],st,i+1);
           end;
        12: if (lowercase(tempChar) = 'a') then insert(SelectedMethod.Key_Nosign^[4],st,i+1) else insert(SelectedMethod.Key_Nosign^[5],st,i+1) ;
        end;
      end;
    inc(i);
  end;
end;

//Return the position in processing string of the letter which need changing to another letter (ex: u --> ư)
function AffectedKey(const source: unicodestring; key: unicodechar; const mode: TLoopMode): integer;
var
  i: Integer;
begin
  key := LowerCase(key);
  if mode =TLoopMode.Down then
    for i:= 1 to length(source) do
      begin
        if pos(ToAbNoSign(source[i]),SelectedMethod.Affect^[key]) <> 0 then
          begin
            if (pos(ToAbNoSign(source[i+1]) ,SelectedMethod.Affect^[key]) <> 0)
                and (pos(ToAbNoSign(source[i+2]), SelectedMethod.Affect^[key]) <> 0 )
            then
              exit(i+1)
            else if ( (LowerCase(source[i]) = 'i') and (LowerCase(Source[i - 1]) = 'g') and (pos(ToAbNoSign(source[i+1]) ,SelectedMethod.Affect^[key]) <> 0) )
                 or ( (LowerCase(source[i]) = 'u') and (LowerCase(Source[i - 1]) = 'q') and (pos(ToAbNoSign(source[i+1]) ,SelectedMethod.Affect^[key]) <> 0) )
                 then exit(i+1)
                 else exit(i);
          end;
      end
  else
  for i:= length(source) downto 1 do
    if pos(ToAbNoSign(source[i]),SelectedMethod.Affect^[key]) <> 0 then exit(i);
  result := -1;
end;

//Check whether TermEscape is enabled in current-processing word
function CheckTermEscape(st : UnicodeString): boolean;
var
  lengthSt,i: Integer;
  SyllableNum : byte = 0; //SyllableNum is the number of Syllable (in Vietnamese: âm tiết)
begin
  lengthSt:= length(st);
  result := false;
  if lengthSt < 2 then exit(false); //st has only 1 char
  if st[1] in ['w','f','j','z'] then exit(true); //Vietnamese words couldn't start with these letters
  case LowerCase(st[lengthSt]) of
    'q','d','k','l','v','b': Exit(true);
    'g':
       if (st[lengthSt-1] <> 'N') and (st[lengthSt-1] <> 'n') then exit(true);
    'h':
       begin
         if pos(st[lengthSt-1],'NnCcGgPpTtKk') = 0 then exit(true);
         if lengthSt = 2 then exit(false); // st has only 2 chars : (N/C/G/P/lengthSt)H
         case LowerCase(st[lengthSt-1]) of
           'n','c':
              if pos(ToAbClear(st[lengthSt-2]), 'aAeEiI' ) = 0 then exit(true);
           'p','t','k': exit(true);
           'g' : if (st[lengthSt-2] <> 'N') and (st[lengthSt-2] <> 'n') then exit(true);
         end;
       end;
    't','p','c','n','m':
       if pos(ToAbClear(st[lengthSt-1] ) , 'aAeEiIoOuUyY' ) = 0 then exit(true);
  end;
  // To this line st[lengthSt] is default vowel (aeiou)
  for i := lengthSt downto 1 do
    if (pos(ToAbClear(st[i]) , 'aAeEiIoOuUyY') <> 0) then //not vowel
      begin
        Inc(SyllableNum);
        break;
      end;
  for i := i -1 downto 1 do
    if (pos(ToAbClear(st[i]) , 'aAeEiIoOuUyY') = 0) then
      break;
  for i:= i - 1 downto 1 do
    if (pos(ToAbClear(st[i]) , 'aAeEiIoOuUyY') <> 0) then //is vowel
      begin
        inc(SyllableNum);
        break;
      end;
  if (SyllableNum >= 2) then exit(true);
end;
//-----------------------------------------------------------------------------

function Encode(st: Unicodestring; var termEscape : integer): Unicodestring;
var i , j, affectedPos, t: integer;
loopMode: TLoopMode;
begin
  result:=st[1]; i:=2;
  while i <= length(st) do
  begin
    if termEscape > 0 then result += st[i] //if TermEscaping Enabled
    else if LowerCase(st[i]) = SelectedMethod.Key_Sign^[1] then //if st[i] = z (telex)
      begin
        t := 0;
        for j:=1 to length(result) do
          if ( pos(ToAbNosign(result[j]),SelectedMethod.Affect^[SelectedMethod.Key_Sign^[1]]) <> 0 ) and ( pos(result[j],'aeiouyAEIOUY') = 0 ) then
            begin
              result[j] := ToAbClear(result[j]);
              t := 1;
            end;
        if t = 0 then
          begin
            result+=SelectedMethod.Key_Sign^[1]; //no affected key
            termEscape := i;
          end;
      end
    else if pos(LowerCase(St[i]),SelectedMethod.Key_Sign^)<>0 then // if st[i] in Key_sign other than z
      begin
        if pos( ToAbClear(result[length(result)]),'aeiouyAEIOUY') <> 0 then
          loopMode := TLoopMode.Down //from the first letter to the last one.
        else
          loopMode:= TLoopMode.Up; // from the last letter to first one.
        // detect loop mode. Put sign from the top for the word ending with a vowel, change to Unicode letter from the bottom

        affectedPos := AffectedKey(result,st[i],loopMode);

        if (affectedPos > 0) then
          begin
            t := PosInFull(result[affectedPos]); //A temp number, store the position of affectedLetter in Alphabet_Full
            if (t - PosInFull(Alphabet_Nosign[t]) = SelectedMethod.Rule^[LowerCase(st[i])]) then //duplicate key
              begin
                result[affectedPos] := Alphabet_Nosign[t];
                result += st[i];
                termEscape := i;
              end
            else
              result[affectedPos] := Alphabet_Full[ SelectedMethod.Rule^[LowerCase(st[i])] + PosInFull( Alphabet_Nosign[t]) ]
          end
        else result += st[i]; //no affected key
      end
    else if pos(LowerCase(st[i]),SelectedMethod.Key_Nosign^)<>0 then // if st[i] in key_no_sign
      begin
        affectedPos := AffectedKey(result,st[i],TLoopMode.Up);
        if (affectedPos > 0) then
          begin
            t := PosInFull(result[affectedPos]);
            //special combo 'uow' --> change to 'ươ'
            if (LowerCase(result[affectedPos]) = 'o') and (LowerCase(result[affectedPos-1]) = 'u') and (LowerCase(st[i]) = SelectedMethod.Key_Nosign^[4]) then
              begin
                result[affectedPos] := Alphabet_Full[ 12 + PosInFull(Alphabet_Nosign[t])];
                t := PosInFull(result[affectedPos-1]);
                result[affectedPos-1] := Alphabet_Full[ 12 + PosInFull(Alphabet_Nosign[t])];
                //12 is SelectedRule
              end
            else if (t - PosInFull(Alphabet_Sign[t]) = SelectedMethod.Rule^[LowerCase(st[i]) ]) then //duplicate key
              begin
                result[affectedPos] := Alphabet_Sign[t];
                result += st[i];
                termEscape := i;
              end
            else
              result[affectedPos] := Alphabet_Full[ SelectedMethod.Rule^[LowerCase(st[i])] + PosInFull( Alphabet_Sign[t]) ]
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
    Sleep(DelayTime); //delay for program to handle key event
    IsVirtualKey := false;
    Clipboard().AsText := tempClipbrd;
end;
//-----------------------------------------------------------------------------


end.

