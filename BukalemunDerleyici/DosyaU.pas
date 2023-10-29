unit DosyaU;

interface

uses System.sysutils, Classes;

type
    TDosya = class
    private
        dosyaAdi: String;
        okundu: Boolean;
        fl: TStringList;
    public
        Constructor Create(_dosyaadi: String);
        function Getir: String;
        procedure Kaydet;
        procedure Ekle(veri: String);

        function SatirSayisi: Integer;
        function SatirGetir(i: Integer): String;
        procedure Kapat;
    end;

implementation

{ TDosya }

constructor TDosya.Create(_dosyaadi: String);
begin
    dosyaAdi := _dosyaadi;
    fl := TStringList.Create;
    okundu := false;
end;

procedure TDosya.Ekle(veri: String);
begin
    fl.Add(veri);
end;

function TDosya.Getir: String;
begin
    fl.LoadFromFile(dosyaAdi, TEncoding.UTF8);
    result := fl.Text;
    fl.Destroy;
end;

procedure TDosya.Kapat;
begin
    fl.Destroy;
end;

procedure TDosya.Kaydet;
begin
    fl.SaveToFile(dosyaAdi, TEncoding.UTF8);
    fl.Destroy;
end;

function TDosya.SatirGetir(i: Integer): String;
begin
    if okundu = false then
    begin
        okundu := true;
        fl.LoadFromFile(dosyaAdi, TEncoding.UTF8);
    end;
    result := fl.Strings[i];
end;

function TDosya.SatirSayisi: Integer;
begin
    if okundu = false then
    begin
        okundu := true;
        fl.LoadFromFile(dosyaAdi, TEncoding.UTF8);
    end;

    result := fl.Count;
end;

end.
