unit StackU;

interface

uses TiplerU, typinfo;

type
    TStack = class
        Adet: Integer;
    private
        elemanlar: array of TTipler;

    public
        constructor Create;
        procedure Ekle(t: TTipler);
        function Getir: TTipler;
        function GetirIndeks(i: Integer): TTipler;
        function GetirStr: String;
        procedure Sil;

    end;

implementation

{ TStack }

constructor TStack.Create;
begin
    Adet := 0;
    SetLength(elemanlar, 0);
end;

procedure TStack.Ekle(t: TTipler);
begin
    Adet := Adet + 1;
    SetLength(elemanlar, Adet);
    elemanlar[Adet - 1] := t;
end;

function TStack.Getir: TTipler;
begin
    Result := elemanlar[Adet - 1];
end;

function TStack.GetirIndeks(i: Integer): TTipler;
begin
    Result := elemanlar[i];
end;

function TStack.GetirStr: String;
begin
    Result := GetEnumName(TypeInfo(TTipler), Ord(Getir));
end;

procedure TStack.Sil;
begin
    Adet := Adet - 1;
    SetLength(elemanlar, Adet);
end;

end.
