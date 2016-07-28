unit SystemHelper;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  windows;
function IsShift():boolean;
function IsControl() : boolean;
function IsCapslock(): boolean;
implementation

function IsShift: boolean;
begin
  result := GetKeyState(VK_SHIFT) < 0;
end;

function IsControl: boolean;
begin
  result := GetKeyState(VK_CONTROL) < 0;
end;

function IsCapslock: boolean;
begin
  result := GetKeyState(VK_CAPITAL) > 0;
end;



end.

