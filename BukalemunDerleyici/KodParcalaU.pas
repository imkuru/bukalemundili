unit KodParcalaU;

interface

uses System.sysutils, TiplerU, DosyaU, typinfo;

type
    TKodParcala = class
        ParcaSayisi: Integer;
        satir: Integer;

        tokenGoster: Boolean;
    private
        procedure ParcaOlustur(gecici: String);
        procedure parcaEkle(tip: TTipler; deger: String);

        function SayisalMi(chr: Char): Boolean;
        function MetinselMi(chr: Char): Boolean;
        function BosAlanMi(chr: Char): Boolean;
        function SayisalYadaMetinselMi(chr: Char): Boolean;
    public
        parcalar: Array of TParca;
        procedure Parcala(dosyaAdi: String);
        constructor Create;
        procedure Yazdir;
    end;

implementation

{ TKodParcala }

function TKodParcala.BosAlanMi(chr: Char): Boolean;
begin
    if chr in [#10, #32, #9] then
        result := True
    else
        result := false;
end;

constructor TKodParcala.Create;
begin
    SetLength(parcalar, 0);
    ParcaSayisi := 0;
    satir := 0;
    tokenGoster := False;
end;

function TKodParcala.MetinselMi(chr: Char): Boolean;
begin
    if 'abcçdefgðhýijklmnoöprsþtuüvyzqwxABCÇDEFGÐHIÝJKLMNOÖPRSÞTUÜVYZQWX_'.
      IndexOf(chr) <> -1 then
        result := True
    else
        result := false;
end;

procedure TKodParcala.parcaEkle(tip: TTipler; deger: String);
var
    yeni: TParca;
begin
    ParcaSayisi := ParcaSayisi + 1;
    SetLength(parcalar, ParcaSayisi);

    yeni.tip := tip;
    yeni.deger := deger;
    yeni.satir := satir;
    parcalar[ParcaSayisi - 1] := yeni;
end;

procedure TKodParcala.Parcala(dosyaAdi: String);
var
    dosya: TDosya;
    v: String;
    i: Integer;
    gecici: String;
    birnokta: Boolean;
    tekrar: Boolean;
begin
    dosya := TDosya.Create(dosyaAdi);
    v := dosya.Getir;
    i := 0;

    while i < length(v) do
    begin
        if v.Chars[i] = #13 then
        begin
            i := i + 1;
            satir := satir + 1;
            Continue;
        end
        else if BosAlanMi(v.Chars[i]) then
        begin
            i := i + 1;
            Continue;
        end
        else if MetinselMi(v.Chars[i]) then
        begin
            gecici := '';
            tekrar := True;
            repeat
                gecici := gecici + v.Chars[i];
                i := i + 1;

                if not((i < length(v)) and (SayisalYadaMetinselMi(v.Chars[i])))
                then
                    tekrar := false;

            until not tekrar;
            ParcaOlustur(gecici);
        end
        else if SayisalMi(v.Chars[i]) then
        begin
            gecici := '';
            birnokta := True;
            while i < length(v) do
            begin
                gecici := gecici + v.Chars[i]; // 22.0
                i := i + 1;
                if (SayisalMi(v.Chars[i]) = false) and (v.Chars[i] <> '.') then
                    break;

                if (v.Chars[i] = '.') and (v.Chars[i + 1] = '.') then
                    break;
            end;
            parcaEkle(TTipler.sayisal, gecici);
        end
        else if v.Chars[i] = '"' then
        begin
            gecici := '';
            i := i + 1;
            while (i < length(v)) and (v.Chars[i] <> '"') do
            begin
                gecici := gecici + v.Chars[i];
                i := i + 1;
                if v.Chars[i] = '\' then
                begin
                    gecici := gecici + '\';
                    i := i + 1;
                    if v.Chars[i] = '"' then
                    begin
                        gecici := gecici + '"';
                        i := i + 1;
                    end;
                end;
            end;
            i := i + 1;
            parcaEkle(TTipler.metinsel, gecici);
        end
        else if v.Chars[i] = '+' then
        begin
            i := i + 1;
            if v.Chars[i] = '+' then
            begin
                parcaEkle(TTipler.artiarti, '++');
                i := i + 1;
            end
            else if v.Chars[i] = '=' then
            begin
                parcaEkle(TTipler.artiesit, '+=');
                i := i + 1;
            end
            else
                parcaEkle(TTipler.arti, '+');
        end
        else if v.Chars[i] = '-' then
        begin
            i := i + 1;
            if v.Chars[i] = '-' then
            begin
                parcaEkle(TTipler.eksieksi, '--');
                i := i + 1;
            end
            else if v.Chars[i] = '=' then
            begin
                parcaEkle(TTipler.eksiesit, '-=');
                i := i + 1;
            end
            else
                parcaEkle(TTipler.eksi, '-');
        end
        else if v.Chars[i] = '*' then
        begin
            i := i + 1;
            if v.Chars[i] = '*' then
            begin
                parcaEkle(TTipler.ussu, '**');
                i := i + 1;
            end
            else if v.Chars[i] = '=' then
            begin
                parcaEkle(TTipler.carpiesit, '*=');
                i := i + 1;
            end
            else
                parcaEkle(TTipler.carpi, '*');
        end
        else if v.Chars[i] = '/' then
        begin
            i := i + 1;
            if v.Chars[i] = '*' then
            begin
                tekrar := True;
                while (tekrar) and (i < length(v)) do
                begin
                    i := i + 1;
                    if v.Chars[i] = '*' then
                    begin
                        i := i + 1;
                        if v.Chars[i] = '/' then
                        begin
                            i := i + 1;
                            tekrar := false;
                        end;
                    end;
                end;
            end
            else if v.Chars[i] = '/' then
            begin
                while (i < length(v)) and (v.Chars[i] <> #13) do
                begin
                    i := i + 1;
                end;
                i := i + 1;
                satir := satir + 1;
            end
            else if v.Chars[i] = '=' then
            begin
                parcaEkle(TTipler.boluesit, '/=');
                i := i + 1;
            end
            else
                parcaEkle(TTipler.bolu, '+');
        end
        else if v.Chars[i] = '=' then
        begin
            i := i + 1;
            if v.Chars[i] = '=' then
            begin
                i := i + 1;
                if v.Chars[i] = '=' then
                begin
                    parcaEkle(TTipler.esitesitesit, '===');
                    i := i + 1;
                end
                else
                    parcaEkle(TTipler.esitmi, '==');
            end
            else
                parcaEkle(TTipler.esittir, '=');
        end
        else if v.Chars[i] = '!' then
        begin
            i := i + 1;
            if v.Chars[i] = '=' then
            begin
                parcaEkle(TTipler.esitdegil, '!=');
                i := i + 1;
            end
            else
                parcaEkle(TTipler.degil, '!');
        end
        else if v.Chars[i] = '.' then
        begin
            i := i + 1;
            if v.Chars[i] = '.' then
            begin
                i := i + 1;
                if v.Chars[i] = '.' then
                begin
                    parcaEkle(TTipler.ucnokta, '...');
                    i := i + 1;
                end
                else
                    parcaEkle(TTipler.ikinokta, '..');
            end
            else
                parcaEkle(TTipler.nokta, '.');
        end
        else if v.Chars[i] = ';' then
        begin
            i := i + 1;
            parcaEkle(TTipler.noktalivirgul, ';');
        end
        else if v.Chars[i] = ':' then
        begin
            i := i + 1;
            parcaEkle(TTipler.ikinoktaustuste, ':');
        end
        else if v.Chars[i] = '?' then
        begin
            i := i + 1;
            parcaEkle(TTipler.soruisareti, '?');
        end
        else if v.Chars[i] = '%' then
        begin
            i := i + 1;
            if v.Chars[i] = '=' then
            begin
                i := i + 1;
                parcaEkle(TTipler.mod_esit, '%=');
            end
            else
                parcaEkle(TTipler.mod_islemi, '%');
        end
        else if v.Chars[i] = '&' then
        begin
            i := i + 1;
            if v.Chars[i] = '&' then
            begin
                i := i + 1;
                parcaEkle(TTipler.ve, '&&');
            end
            else
                parcaEkle(TTipler.ampersan, '&');
        end
        else if v.Chars[i] = '|' then
        begin
            i := i + 1;
            if v.Chars[i] = '|' then
            begin
                i := i + 1;
                parcaEkle(TTipler.veya, '||');
            end
            else
                parcaEkle(TTipler.duzcizgi, '|');
        end
        else if v.Chars[i] = '<' then
        begin
            i := i + 1;
            if v.Chars[i] = '=' then
            begin
                i := i + 1;
                parcaEkle(TTipler.kucukesit, '<=');
            end
            else
                parcaEkle(TTipler.kucuk, '<');
        end
        else if v.Chars[i] = '>' then
        begin
            i := i + 1;
            if v.Chars[i] = '=' then
            begin
                i := i + 1;
                parcaEkle(TTipler.buyukesit, '>=');
            end
            else
                parcaEkle(TTipler.buyuk, '>');
        end
        else if v.Chars[i] = ',' then
        begin
            i := i + 1;
            parcaEkle(TTipler.virgul, ',');
        end
        else if v.Chars[i] = '(' then
        begin
            i := i + 1;
            parcaEkle(TTipler.parantezac, '(');
        end
        else if v.Chars[i] = ')' then
        begin
            i := i + 1;
            parcaEkle(TTipler.parantezkapat, ')');
        end
        else if v.Chars[i] = '[' then
        begin
            i := i + 1;
            parcaEkle(TTipler.koseliparanteziac, '[');
        end
        else if v.Chars[i] = ']' then
        begin
            i := i + 1;
            parcaEkle(TTipler.koseliparantezikapat, ']');
        end
        else if v.Chars[i] = '{' then
        begin
            i := i + 1;
            parcaEkle(TTipler.susluparantezac, '{');
        end
        else if v.Chars[i] = '}' then
        begin
            i := i + 1;
            parcaEkle(TTipler.susluparantezkapat, '}');
        end
        else if v.Chars[i] = #39 then // tek týrnak
        begin
            i := i + 1;
            gecici := '';
            while i < length(v) do
            begin
                if (v.Chars[i] = #39) and (v.Chars[i] <> '\') then
                begin
                    i := i + 1;
                    break;
                end;

                gecici := gecici + v.Chars[i];
                i := i + 1;
            end;

            if length(gecici) = 0 then
                raise Exception.Create('Karakter türü boþ olamaz!');
            if length(gecici) <> 1 then
                raise Exception.Create
                  ('Karakter türü sadece 1 byte veri depolayabilir.');
            parcaEkle(TTipler.tekkarakter, gecici);
        end
        else
        begin
            raise Exception.Create('Tanýmlanamayan ifade ' + v.Chars[i] +
              ord(v.Chars[i]).ToString());
        end;
    end;
    if tokenGoster then
    begin
        Yazdir;
    end;
end;

procedure TKodParcala.ParcaOlustur(gecici: String);
begin
    if (gecici = 'doðru') or (gecici = 'evet') or (gecici = 'true') then
        parcaEkle(TTipler.mantiksal, 'doðru')
    else if (gecici = 'yanlýþ') or (gecici = 'hayýr') or (gecici = 'false') then
        parcaEkle(TTipler.mantiksal, 'yanlýþ')
    else if (gecici = 've') then
        parcaEkle(TTipler.ve, gecici)
    else if gecici = 'veya' then
        parcaEkle(TTipler.veya, gecici)
    else if gecici = 'gönder' then
        parcaEkle(TTipler.gonder, gecici)
    else if gecici = 'eðer' then
        parcaEkle(TTipler.eger, gecici)
    else if gecici = 'deðilse' then
        parcaEkle(TTipler.degilse, gecici)
    else if gecici = 'say' then
        parcaEkle(TTipler.say, gecici)
    else if gecici = 'tekrarla' then
        parcaEkle(TTipler.tekrarla, gecici)
    else if gecici = 'devam' then
        parcaEkle(TTipler.devam, gecici)
    else if gecici = 'bitir' then
        parcaEkle(TTipler.bitir, gecici)
    else if gecici = 'ise' then
        parcaEkle(TTipler.ise, gecici)
    else
        parcaEkle(TTipler.tanimlayici, gecici);

end;

function TKodParcala.SayisalMi(chr: Char): Boolean;
begin
    if chr in ['0' .. '9'] then
        result := True
    else
        result := false;
end;

function TKodParcala.SayisalYadaMetinselMi(chr: Char): Boolean;
begin
    if '0123456789abcçdefgðhýijklmnoöprsþtuüvyzqwxABCÇDEFGÐHIÝJKLMNOÖPRSÞTUÜVYZQWX_'.
      IndexOf(chr) <> -1 then
        result := True
    else
        result := false;
end;

procedure TKodParcala.Yazdir;
var
    i: Integer;
begin
    for i := 0 to ParcaSayisi - 1 do
    begin
        writeln(GetEnumName(TypeInfo(TTipler), ord(parcalar[i].tip)), ' ',
          #9 + #9 + #9 + parcalar[i].deger);// , '    Satýr: ',
//          parcalar[i].satir);
    end;
end;

end.
