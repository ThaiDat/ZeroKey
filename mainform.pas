unit MainForm;

{$mode objfpc}{$H+}
{$codepage utf8}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin,
  KeyUtil, KeyCodeDefine;

type

  { TwndMain }

  TwndMain = class(TForm)
    btnDelay: TButton;
    btnClose: TButton;
    cbIME: TComboBox;
    seDelay: TSpinEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure btnDelayClick(Sender: TObject);
    procedure cbIMEChange(Sender: TObject);
    procedure seDelayChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;
const MsgShow: unicodestring = 'Con số bên cạnh là thời gian nhỏ nhất giữa hai lần gõ phím liên tiếp, đồng thời luôn lớn hơn ping của ứng dụng.' + #10 + 'Trong trường hợp chương trình bị lỗi không gõ được tiếng Việt, nguyên nhân có thể do con số này nhỏ hơn ping của ứng dụng, tăng con số này lên có thể giúp cải thiện vấn đề.' ;


var
  wndMain: TwndMain;

implementation

{$R *.lfm}

{ TwndMain }

procedure TwndMain.btnDelayClick(Sender: TObject);
begin
  ShowMessage(MsgShow);
end;

procedure TwndMain.cbIMEChange(Sender: TObject);
begin
  case cbIME.ItemIndex of
  0: begin
       SelectedTypingMethod:= Telex;
       Selected_Affect := @Telex_Affect;
       Selected_Key_Sign := @Telex_Key_Sign;
       Selected_Key_Nosign := @Telex_Key_Nosign;
       Selected_Rule := @Telex_Rule;
     end;
  1: begin
       SelectedTypingMethod:= Vni;
       Selected_Affect := @Vni_Affect;
       Selected_Key_Sign := @Vni_Key_Sign;
       Selected_Key_Nosign := @Vni_Key_Nosign;
       Selected_Rule := @Vni_Rule;
     end;
  end;
end;

procedure TwndMain.btnCloseClick(Sender: TObject);
begin
  self.Close();
end;

procedure TwndMain.seDelayChange(Sender: TObject);
begin
  DelayTime := seDelay.Value;
end;

end.

