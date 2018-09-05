unit KeyCodeDefine;

{$mode objfpc}{$H+}
{$codepage utf8}

interface
type
  DictRule = array [char] of byte ; //Dictionary<char,byte>
  PDictRule = ^DictRule;

  DictAffectChar = array [char] of UnicodeString;
  PDictAffectChar = ^DictAffectChar;
  MethodName = (Telex, Vni);
  TMethod = record
    Rule : PDictRule;
    Affect : PDictAffectChar;
    Key_Sign, Key_Nosign: ^UnicodeString;
    Method: MethodName;
    end;
const Alphabet_Full  : UnicodeString = 'aàảãáạâầẩẫấậăằẳẵắặbcdđeèẻẽéẹêềểễếệfghiìỉĩíịjklmnoòỏõóọôồổỗốộơờởỡớợpqrstuùủũúụ......ưừửữứựvwxyỳỷỹýỵzAÀẢÃÁẠÂẦẨẪẤẬĂẰẲẴẮẶBCDĐEÈẺẼÉẸÊỀỂỄẾỆFGHIÌỈĨÍỊJKLMNOÒỎÕÓỌÔỒỔỖỐỘƠỜỞỠỚỢPQRSTUÙỦŨÚỤ......ƯỪỬỮỨỰVWXYỲỶỸÝỴZ';
      Alphabet_Sign  : UnicodeString = 'aàảãáạaàảãáạaàảãáạbcddeèẻẽéẹeèẻẽéẹfghiìỉĩíịjklmnoòỏõóọoòỏõóọoòỏõóọpqrstuùủũúụ......uùủũúụvwxyỳỷỹýỵzAÀẢÃÁẠAÀẢÃÁẠAÀẢÃÁẠBCDDEÈẺẼÉẸEÈẺẼÉẸFGHIÌỈĨÍỊJKLMNOÒỎÕÓỌOÒỎÕÓỌOÒỎÕÓỌPQRSTUÙỦŨÚỤ......UÙỦŨÚỤVWXYỲỶỸÝỴZ';
      Alphabet_Nosign: UnicodeString = 'aaaaaaââââââăăăăăăbcdđeeeeeeêêêêêêfghiiiiiijklmnooooooôôôôôôơơơơơơpqrstuuuuuu......ưưưưưưvwxyyyyyyzAAAAAAÂÂÂÂÂÂĂĂĂĂĂĂBCDĐEEEEEEÊÊÊÊÊÊFGHIIIIIIJKLMNOOOOOOÔÔÔÔÔÔƠƠƠƠƠƠPQRSTUUUUUU......ƯƯƯƯƯƯVWXYYYYYYZ';

      Telex_Key_Sign : UnicodeString = 'zfrxsj';
      Telex_Key_Nosign : UnicodeString = 'aeowwd';

      Vni_Key_Sign : UnicodeString = '023415';
      Vni_Key_Nosign : UnicodeString = '666789';
var
  Telex_Rule, Vni_Rule : DictRule;
  Telex_Affect, Vni_Affect : DictAffectChar;
  SelectedMethod: TMethod;
implementation


initialization
//Telex
Telex_Rule['s'] := 4;       Telex_Affect['s'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Telex_Rule['f'] := 1;       Telex_Affect['f'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Telex_Rule['r'] := 2;       Telex_Affect['r'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Telex_Rule['x'] := 3;       Telex_Affect['x'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Telex_Rule['j'] := 5;       Telex_Affect['j'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Telex_Rule['z'] := 0;       Telex_Affect['z'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Telex_Rule['a'] := 6;       Telex_Affect['a'] := 'aâăAÂĂ';
Telex_Rule['e'] := 6;       Telex_Affect['e'] := 'eêEÊ';
Telex_Rule['o'] := 6;       Telex_Affect['o'] := 'oôơOÔƠ';
Telex_Rule['w'] := 12;      Telex_Affect['w'] := 'aâăoôơuưAÂĂOÔƠUƯ';
Telex_Rule['d'] := 1;       Telex_Affect['d'] := 'dđDĐ';
//Vni
Vni_Rule['1'] := 4;           Vni_Affect['1'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Vni_Rule['2'] := 1;           Vni_Affect['2'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Vni_Rule['3'] := 2;           Vni_Affect['3'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Vni_Rule['4'] := 3;           Vni_Affect['4'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Vni_Rule['5'] := 5;           Vni_Affect['5'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Vni_Rule['0'] := 0;           Vni_Affect['0'] := 'aâăeêioôơuưyAÂĂEÊIOÔƠUƯY';
Vni_Rule['6'] := 6;           Vni_Affect['6'] := 'aâăeêoôơAÂĂEÊOÔƠ';
Vni_Rule['7'] := 12;          Vni_Affect['7'] := 'oôơuưOÔƠUƯ';
Vni_Rule['8'] := 12;          Vni_Affect['8'] := 'aâăAÂĂ';
Vni_Rule['9'] := 1;           Vni_Affect['9'] := 'dđDĐ';
// Add new input method here
SelectedMethod.Method:= Telex;
SelectedMethod.Affect := @Telex_Affect;
SelectedMethod.Key_Sign := @Telex_Key_Sign;
SelectedMethod.Key_Nosign := @Telex_Key_Nosign;
SelectedMethod.Rule := @Telex_Rule;
end.

