unit MainForm;

{$mode objfpc}{$H+}
{$codepage utf8}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin,
  KeyUtil;

type

  { TwndMain }

  TwndMain = class(TForm)
    btnDelay: TButton;
    btnClose: TButton;
    cbIME: TComboBox;
    seDelay: TSpinEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure btnDelayClick(Sender: TObject);
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

procedure TwndMain.btnCloseClick(Sender: TObject);
begin
  self.Close();
end;

procedure TwndMain.seDelayChange(Sender: TObject);
begin
  DelayTime := seDelay.Value;
end;

end.

