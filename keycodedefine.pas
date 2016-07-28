unit KeyCodeDefine;

{$mode objfpc}{$H+}
{$codepage utf8}

interface
type
  DictRule = array [char] of byte ; //Dictionary<char,byte>
  PDictRule = ^DictRule;

  DictAffectChar = array [char] of UnicodeString;
  PDictAffectChar = ^DictAffectChar;
const Alphabet_Full  : UnicodeString = 'aàảãáạâầẩẫấậăằẳẵắặbcdđeèẻẽéẹêềểễếệfghiìỉĩíịjklmnoòỏõóọôồổỗốộơờởỡớợpqrstuùủũúụ......ưừửữứựvwxyỳỷỹýỵzAÀẢÃÁẠÂẦẨẪẤẬĂẰẲẴẮẶBCDĐEÈẺẼÉẸÊỀỂỄẾỆFGHIÌỈĨÍỊJKLMNOÒỎÕÓỌÔỒỔỖỐỘƠỜỞỠỚỢPQRSTUÙỦŨÚỤ......ƯỪỬỮỨỰVWXYỲỶỸÝỴZ';
      Alphabet_Sign  : UnicodeString = 'aàảãáạaàảãáạaàảãáạbcddeèẻẽéẹeèẻẽéẹfghiìỉĩíịjklmnoòỏõóọoòỏõóọoòỏõóọpqrstuùủũúụ......uùủũúụvwxyỳỷỹýỵzAÀẢÃÁẠAÀẢÃÁẠAÀẢÃÁẠBCDDEÈẺẼÉẸEÈẺẼÉẸFGHIÌỈĨÍỊJKLMNOÒỎÕÓỌOÒỎÕÓỌOÒỎÕÓỌPQRSTUÙỦŨÚỤ......UÙỦŨÚỤVWXYỲỶỸÝỴZ';
      Alphabet_Nosign: UnicodeString = 'aaaaaaââââââăăăăăăbcdđeeeeeeêêêêêêfghiiiiiijklmnooooooôôôôôôơơơơơơpqrstuuuuuu......ưưưưưưvwxyyyyyyzAAAAAAÂÂÂÂÂÂĂĂĂĂĂĂBCDĐEEEEEEÊÊÊÊÊÊFGHIIIIIIJKLMNOOOOOOÔÔÔÔÔÔƠƠƠƠƠƠPQRSTUUUUUU......ƯƯƯƯƯƯVWXYYYYYYZ';

      Telex_Key_Sign : UnicodeString = 'zfrxsj';
      Telex_Key_Nosign : UnicodeString = 'aeowwd';
var
  Telex_Rule : DictRule;
  Telex_Affect : DictAffectChar;

  Selected_Rule : PDictRule;
  Selected_Affect : PDictAffectChar;
  Selected_Key_Sign, Selected_Key_Nosign: ^UnicodeString;

implementation


initialization
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

// Add your input method here

Selected_Affect := @Telex_Affect;
Selected_Key_Sign := @Telex_Key_Sign;
Selected_Key_Nosign := @Telex_Key_Nosign;
Selected_Rule := @Telex_Rule;
end.

