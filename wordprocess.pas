unit WordProcess;

{$mode objfpc}{$H+}
{$codepage utf8}

interface
uses sysutils, KeyUtil, KeyCodeDefine;

type
  KeybdLLHookStruct = record
    vkCode      : cardinal;
    scanCode    : cardinal;
    flags       : cardinal;
    time        : cardinal;
    dwExtraInfo : cardinal;
  end;

  { TWordProcessor }

  TWordProcessor = class
    private
      WordPrevious: Unicodestring;
      WordCurrent : Unicodestring;
      TermEscapeCurrent : integer;
      TermEscapPrevious : integer;
    public
      function AddWord(char : UnicodeChar) : boolean;
      procedure SpaceProcess();
      procedure BackSpaceProcess();
      procedure OtherKeysProcess();
  end;


implementation

{ TWordProcessor }

function TWordProcessor.AddWord(char: UnicodeChar) : boolean; //false for not pastekey
var tempWord: UnicodeString;
  LengthWordCurrent, LengthTempWord, BackTimes: Integer;
  firstDiff: Byte;
  str: String;

  function FindFirstDifferentPos(oldWord, newWord : UnicodeString) : byte;
  var
    i: Integer;
  begin
    if oldWord <> '' then
      begin
        for i := 1 to length(oldWord) do
          if (oldWord[i] <> newWord[i]) then
            exit(i);
      end
    else i:=0;

    if i < length(newWord) then exit(i+1);
  end;

begin
  tempWord := self.WordCurrent; //oldword
  LengthWordCurrent := length(WordCurrent);
  LengthTempWord := length(tempWord);
  if (TermEscapeCurrent = 0) and (CheckTermEscape(WordCurrent)) then TermEscapeCurrent:= LengthWordCurrent;

  if ( pos(lowercase(char), Selected_Key_Sign^)<>0 ) or ( pos(LowerCase(char),Selected_Key_Nosign^) <> 0 ) then
    self.WordCurrent := Encode(Decode(WordCurrent,TermEscapeCurrent) + char,TermEscapeCurrent)
  else
    self.WordCurrent := Encode(Decode(WordCurrent + char,TermEscapeCurrent),TermEscapeCurrent);

  firstDiff := FindFirstDifferentPos(tempWord, WordCurrent);
  if firstDiff > LengthTempWord then exit(false);
  BackTimes := LengthTempWord - firstDiff + 1;
  str := UTF8Encode(copy(self.WordCurrent, firstDiff, length(WordCurrent)-firstDiff+1));
  PasteString(str, BackTimes);
  result := true;
end;

procedure TWordProcessor.SpaceProcess;
begin
  WordPrevious := WordCurrent;
  TermEscapPrevious := TermEscapeCurrent;
  WordCurrent := '';
  TermEscapeCurrent := 0;
end;

procedure TWordProcessor.BackSpaceProcess;
begin
  if (WordCurrent = '') then
    begin
      WordCurrent := WordPrevious;
      TermEscapeCurrent := TermEscapPrevious;
      WordPrevious := '';
      TermEscapPrevious := 0;
    end
  else
    begin
      delete(WordCurrent, length(WordCurrent), 1);
      //Udapte WordCurrent
      if (Length(WordCurrent) < TermEscapeCurrent) then TermEscapeCurrent := 0;
    end;
end;

procedure TWordProcessor.OtherKeysProcess;
begin
  WordCurrent := '';
  TermEscapeCurrent := 0;
  WordPrevious := '';
  TermEscapPrevious := 0;
end;

end.

