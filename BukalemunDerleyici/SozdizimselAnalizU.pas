unit SozdizimselAnalizU;

interface

uses system.sysutils, KodParcalaU, DosyaU, TiplerU, StackU, typinfo;

type
    TSozDizimselAnaliz = class(TKodParcala)

        BFDprogramAnaKlasor: String;
        islemGorenDosya: String;
        KonsolaYaz: Boolean;
        Hex: Boolean;
        WinForm: Boolean;

        kod_dosyasi_klasor: String;
        kod_dosyasi_adi: String;

    private
        fCikti: TDosya;
        bas_son_stack: TStack;
        ifade_degilli: TTipler;
        hatadosyasi: String;
        cikti_dosyasi: String;
        i: Integer;
        susluparantezsayisi: Integer;
    public
        procedure Sifirla;
        Constructor Create;
        function getHex(kod: String): String;
        procedure Hata(mesaj: String);

        procedure yazdir1(kod: String);
        procedure yazdir2(kod: String; w: String);

        procedure CiktiDosyasiAyarla(ciktiDosyasiAdi: String);
        procedure CiktiDosyasiKapat;

        function isle: Integer;
        function Parse(dosyaAdi: String): Integer;

        procedure bas_son_stack_isle_susluparantezkapat;
        procedure bas_son_stack_isle_noktalivirgul;

        procedure arti_arti_eksi_eksi(deger: String; t: TTipler);

        procedure while_dongusu;
        procedure for_dongusu;
        procedure EgerOku;
        function SartOku(son: TTipler; stackisle: Boolean): Boolean;

        procedure SinifIslem;
        function ifadeoku: Boolean;

        function FonksiyonTanimla(deger: String): Boolean;
        function Fonksiyon(var pSayisi: Integer): Boolean;

        function DegiskenTanimla(deger: String): Boolean;

        function MatematikselIslem: Boolean;
        function islem_onceligi_getir(t: TTipler): Integer;

        procedure SartOkuStackIsle(st: TStack);
    end;

implementation

{ TSozDizimselAnaliz }

procedure TSozDizimselAnaliz.arti_arti_eksi_eksi(deger: String; t: TTipler);
begin
    i := i + 1;
    yazdir2('degisken_yukle', deger);
    yazdir2('yukle', '1');
    if t = TTipler.artiarti then
        yazdir1('arti')
    else
        yazdir1('eksi');
    yazdir2('degerata', deger);
end;

procedure TSozDizimselAnaliz.bas_son_stack_isle_noktalivirgul;
begin
    while bas_son_stack.Adet > 0 do
    begin
        if bas_son_stack.Getir = TTipler.tekrarla_sartsonda then
            Break;

        if bas_son_stack.Getir <> TTipler.susluparantezac then
        begin
            yazdir1('bitti.');
            bas_son_stack.Sil;
        end
        else
            Break;
    end;
end;

procedure TSozDizimselAnaliz.bas_son_stack_isle_susluparantezkapat;
var
    parantez: Boolean;
begin
    parantez := False;
    while bas_son_stack.Adet > 0 do
    begin
        if bas_son_stack.Getir = TTipler.susluparantezac then
        begin
            if parantez then
                Break;
            parantez := true;
            bas_son_stack.Sil;
        end
        else
        begin
            yazdir1('bitti.');
            bas_son_stack.Sil;
        end;
    end;
end;

procedure TSozDizimselAnaliz.CiktiDosyasiAyarla(ciktiDosyasiAdi: String);
var
    d_adi: String;
begin
    if WinForm then
        d_adi := kod_dosyasi_klasor + ciktiDosyasiAdi + '.munf'
    else
        d_adi := kod_dosyasi_klasor + ciktiDosyasiAdi + '.mun';

    fCikti := TDosya.Create(d_adi);
end;

procedure TSozDizimselAnaliz.CiktiDosyasiKapat;
begin
    fCikti.Kaydet;
end;

constructor TSozDizimselAnaliz.Create;
begin
    Sifirla;
    bas_son_stack := TStack.Create;
    KonsolaYaz := False;
    Hex := true;
    WinForm := False;
end;

function TSozDizimselAnaliz.DegiskenTanimla(deger: String): Boolean;
var
    sonuc, tekrar, degiskenAdiGerekli: Boolean;
    prm_sayisi: Integer;
    o: String;
begin
    sonuc := False;
    tekrar := true;
    degiskenAdiGerekli := False;

    while tekrar do
    begin
        if parcalar[i].tip <> TTipler.tanimlayici then
            if degiskenAdiGerekli = False then
            begin
                Result := sonuc;
                Exit;
            end
            else
                Hata('Deðiþken adý beklenirken ' + parcalar[i].deger +
                  ' geldi.');

        sonuc := true;

        if (deger = 'doðruyanlýþ') or (deger = 'sayý') or (deger = 'vsayý') or
          (deger = 'metin') or (deger = 'karakter') then
            yazdir2('tanimla', deger + ' ' + parcalar[i].deger)
        else
            yazdir2('harici_tanimla', deger + ' ' + parcalar[i].deger);

        i := i + 1;

        if parcalar[i].tip = TTipler.esittir then
        begin
            o := parcalar[i - 1].deger;
            i := i + 1;
            if MatematikselIslem then
                yazdir2('degerata', o)
            else
            begin
                if parcalar[i].tip = TTipler.metinsel then
                begin
                    yazdir2('yukle', '"' + parcalar[i].deger + '"');
                    yazdir2('degerata', parcalar[i - 2].deger);
                    i := i + 1;
                end
                else if parcalar[i].tip = TTipler.tekkarakter then
                begin
                    yazdir2('yukle', '''' + parcalar[i].deger + '''');
                    yazdir2('degerata', parcalar[i - 2].deger);
                    i := i + 1;
                end
                else if (parcalar[i].tip = mantiksal) or
                  (parcalar[i].tip = TTipler.sayisal) then
                begin
                    yazdir2('yukle', parcalar[i].deger);
                    yazdir2('degerata', parcalar[i - 2].deger);
                    i := i + 1;
                end
                else if parcalar[i].tip = TTipler.tanimlayici then
                begin
                    prm_sayisi := 0;
                    i := i + 1;
                    if Fonksiyon(prm_sayisi) then
                        yazdir2('fonksiyon_yukle',
                          deger + ' ' + IntToStr(prm_sayisi));

                end
                else
                    Hata('Hatalý veri: ' + parcalar[i].deger);
            end;

        end;

        if parcalar[i].tip = TTipler.virgul then
        begin
            i := i + 1;
            tekrar := true;
            degiskenAdiGerekli := true;
        end
        else
            tekrar := False;

    end;

    Result := sonuc;

end;

procedure TSozDizimselAnaliz.EgerOku;
begin
    if SartOku(TTipler.ise, true) = False then
        Hata('Þart ifadesi beklenirken ' + parcalar[i].deger);

    if parcalar[i].tip = TTipler.susluparantezac then
    begin
        susluparantezsayisi := susluparantezsayisi + 1;
        i := i + 1;
        bas_son_stack.Ekle(TTipler.susluparantezac);
    end
    else
        bas_son_stack.Ekle(TTipler.eger);

    yazdir1('basla');
end;

function TSozDizimselAnaliz.Fonksiyon(var pSayisi: Integer): Boolean;
begin
    if parcalar[i].tip = TTipler.parantezac then
        i := i + 1
    else
    Begin
        Result := False;
        Exit;
    End;

    if parcalar[i].tip <> TTipler.parantezkapat then
    begin
        while i < parcasayisi do
        begin
            if MatematikselIslem then
            begin
                pSayisi := pSayisi + 1;
            end
            else if ifadeoku = False then
                Hata('Bir ifade beklenirken ' + parcalar[i].deger + ' geldi.')
            else
                pSayisi := pSayisi + 1;

            if parcalar[i].tip = TTipler.virgul then
            begin
                i := i + 1;
                Continue;
            end
            else
                Break;
        end;

        if i >= parcasayisi then
            Hata('Parantezin kapatýlmasý gerekiyordu.')
        else if parcalar[i].tip <> TTipler.parantezkapat then
            Hata('Parantezin kapatýlmasý gerekirken ' + parcalar[i].deger +
              ' geldi.');
    end;
    i := i + 1;
    Result := true;
end;

function TSozDizimselAnaliz.FonksiyonTanimla(deger: String): Boolean;
var
    tur: String;
begin
    if (parcalar[i].tip <> TTipler.tanimlayici) or
      (parcalar[i + 1].tip <> TTipler.parantezac) then
    begin
        Result := False;
        Exit;
    end;

    if deger <> 'fonksiyon' then
        Hata('Fonksyion tanýmlama hatalý: ' + deger + ' ' + parcalar[i].deger);

    yazdir2('fonksiyon_tanimla', deger + ' ' + parcalar[i].deger);
    i := i + 2;

    while parcalar[i].tip <> TTipler.parantezkapat do
    begin
        if parcalar[i].tip <> TTipler.tanimlayici then
            Hata('Tür beklenirken ' + parcalar[i].deger + ' ifadesi geldi.');

        tur := parcalar[i].deger;
        i := i + 1;
        if parcalar[i].tip <> TTipler.tanimlayici then
            Hata('Deðiþken adý beklenirken ' + parcalar[i].deger +
              ' ifadesi geldi.');
        yazdir2('parametre', tur + ' ' + parcalar[i].deger);
        i := i + 1;

        if parcalar[i].tip = TTipler.virgul then
            i := i + 1
        else if parcalar[i].tip <> TTipler.parantezkapat then
            Hata('Beklenmeyen ifade ' + parcalar[i].deger);

    end;
    i := i + 1;

    if parcalar[i].tip <> TTipler.susluparantezac then
        Hata('{ beklenirken ' + parcalar[i].deger + ' ifadesi geldi.');

    i := i + 1;
    susluparantezsayisi := susluparantezsayisi + 1;
    yazdir1('basla');
    Result := true;

end;

procedure TSozDizimselAnaliz.for_dongusu;
begin
    yazdir1('say');
    if parcalar[i].tip <> TTipler.parantezac then
        Hata('parantez beklenirken ' + parcalar[i].deger + ' geldi.');
    i := i + 1;

    if (parcalar[i].tip = TTipler.tanimlayici) and
      (parcalar[i + 1].tip = TTipler.tanimlayici) then
    begin
        yazdir2('tanimla', parcalar[i].deger + ' ' + parcalar[i + 1].deger);
        i := i + 2;
    end
    else if parcalar[i].tip = TTipler.tanimlayici then
    begin
        yazdir2('islemsiz', parcalar[i].deger);
        i := i + 1;
    end;

    if parcalar[i].tip <> TTipler.ikinoktaustuste then
        Hata('Deðiþken tanýmlamasý ya da deðiþken adý beklenirken ' +
          parcalar[i].deger + ' geldi.');

    // baþlangýç deðeri
    i := i + 1;

    if (parcalar[i].tip = TTipler.eksi) and
      (parcalar[i + 1].tip = TTipler.sayisal) then
    begin
        i := i + 1;
        parcalar[i].deger := '-' + parcalar[i].deger;
    end;

    if parcalar[i].tip = TTipler.sayisal then
        yazdir2('islemsiz', parcalar[i].deger)
    else if parcalar[i].tip = TTipler.tanimlayici then
        yazdir2('degisken_yukle', parcalar[i].deger);

    // .. veya ...
    i := i + 1;

    if (parcalar[i].tip <> TTipler.ikinokta) and
      (parcalar[i].tip <> TTipler.ucnokta) then
        Hata('.. ya da ... beklenirken ' + parcalar[i].deger + ' geldi.')
    else
        yazdir2('islemsiz', parcalar[i].deger);

    // bitiþ deðeri
    i := i + 1;

    if (parcalar[i].tip = TTipler.eksi) and
      (parcalar[i + 1].tip = TTipler.sayisal) then
    begin
        i := i + 1;
        parcalar[i].deger := '-' + parcalar[i].deger;
    end;

    if parcalar[i].tip = TTipler.sayisal then
        yazdir2('islemsiz', parcalar[i].deger)
    else if parcalar[i].tip = TTipler.tanimlayici then
        yazdir2('degisken_yukle', parcalar[i].deger);

    // artýþ
    i := i + 1;
    if parcalar[i].tip = TTipler.virgul then
    begin
        i := i + 1;

        if (parcalar[i].tip = TTipler.eksi) and
          (parcalar[i + 1].tip = TTipler.sayisal) then
        begin
            i := i + 1;
            parcalar[i].deger := '-' + parcalar[i].deger;
        end;

        if parcalar[i].tip = TTipler.sayisal then
            yazdir2('islemsiz', parcalar[i].deger)
        else if parcalar[i].tip = TTipler.tanimlayici then
            yazdir2('degisken_yukle', parcalar[i].deger)
        else
            Hata('Artýþ deðeri beklenirken ' + parcalar[i].deger + ' geldi.');

        i := i + 1;
    end
    else
        yazdir2('islemsiz', '1');

    if parcalar[i].tip <> TTipler.parantezkapat then
        Hata(') beklenirken ' + parcalar[i].deger + ' geldi.');

    i := i + 1;

    if parcalar[i].tip = TTipler.susluparantezac then
    begin
        susluparantezsayisi := susluparantezsayisi + 1;
        i := i + 1;
        bas_son_stack.Ekle(TTipler.susluparantezac);
    end
    else
        bas_son_stack.Ekle(TTipler.say);

    yazdir1('basla');

end;

function TSozDizimselAnaliz.getHex(kod: String): String;
begin
    if kod = 'islemsiz' then
        Result := '0x000'
    else if kod = 'basla' then
        Result := '0x001'
    else if kod = 'bitti.' then
        Result := '0x002'
    else if kod = 'sinif_tanimla' then
        Result := '0x003'
    else if kod = 'kalitim' then
        Result := '0x004'
    else if kod = 'tanimla' then
        Result := '0x005'
    else if kod = 'fonksiyon_tanimla' then
        Result := '0x006'
    else if kod = 'parametre' then
        Result := '0x007'
    else if kod = 'tekrarla' then
        Result := '0x008'
    else if kod = 'say' then
        Result := '0x009'
    else if kod = 'eger' then
        Result := '0x010'
    else if kod = 'degilse' then
        Result := '0x011'
    else if kod = 'gonder' then
        Result := '0x012'
    else if kod = 'degerata' then
        Result := '0x013'
    else if kod = 'yukle' then
        Result := '0x014'
    else if kod = 'degisken_yukle' then
        Result := '0x015'
    else if kod = 'fonksiyon_yukle' then
        Result := '0x016'
    else if kod = 'cagir' then
        Result := '0x017'
    else if kod = 'birlestir' then
        Result := '0x018'
    else if kod = 'karsilastir' then
        Result := '0x019'
    else if kod = 'icinde' then
        Result := '0x020'
    else if kod = 'bitir' then
        Result := '0x021'
    else if kod = 'devam' then
        Result := '0x022'
    else if kod = 'arti' then
        Result := '0x023'
    else if kod = 'eksi' then
        Result := '0x024'
    else if kod = 'carpi' then
        Result := '0x025'
    else if kod = 'bolu' then
        Result := '0x026'
    else if kod = 'mod_islemi' then
        Result := '0x027'
    else if kod = 'degil' then
        Result := '0x028'
    else if kod = 'harici_tanimla' then
        Result := '0x029'
    else if kod = 'ussu' then
        Result := '0x030'
    else if kod = 'degilse_eger' then
        Result := '0x031'
    else
        Result := '0x000';
end;

procedure TSozDizimselAnaliz.Hata(mesaj: String);
var
    dosya: TDosya;
begin
    dosya := TDosya.Create(kod_dosyasi_klasor + kod_dosyasi_adi + '_rapor.txt');
    dosya.Ekle(IntToStr(parcalar[i].satir + 1) + '. Satýr. "' + islemGorenDosya
      + '": ' + mesaj);
    dosya.Kaydet();

    raise Exception.Create(IntToStr(parcalar[i].satir + 1) +
      '. Satýr. ' + mesaj);
end;

function TSozDizimselAnaliz.ifadeoku: Boolean;
var
    deger: String;
    prm_adet: Integer;
begin
    if (parcalar[i].tip = TTipler.eksi) and
      (parcalar[i + 1].tip = TTipler.sayisal) then
    begin
        i := i + 1;
        parcalar[i].deger := '-' + parcalar[i].deger;
    end;

    if parcalar[i].tip = TTipler.degil then
    begin
        i := i + 1;
        ifade_degilli := TTipler.degil;
    end;

    if parcalar[i].tip = TTipler.sayisal then
    begin
        yazdir2('yukle', parcalar[i].deger);
        if ifade_degilli = TTipler.degil then
        begin
            yazdir1('degil');
            ifade_degilli := TTipler.bitir;
        end;
        i := i + 1;
        Result := true;
        Exit;
    end;

    if parcalar[i].tip = TTipler.metinsel then
    begin
        yazdir2('yukle', '"' + parcalar[i].deger + '"');
        if ifade_degilli = TTipler.degil then
        begin
            yazdir1('degil');
            ifade_degilli := TTipler.bitir;
        end;
        i := i + 1;
        Result := true;
        Exit;
    end;

    if parcalar[i].tip = TTipler.tekkarakter then
    begin
        yazdir2('yukle', '''' + parcalar[i].deger + '''');
        if ifade_degilli = TTipler.degil then
        begin
            yazdir1('degil');
            ifade_degilli := TTipler.bitir;
        end;
        i := i + 1;
        Result := true;
        Exit;
    end;

    if parcalar[i].tip = TTipler.mantiksal then
    begin
        yazdir2('yukle', parcalar[i].deger);
        if ifade_degilli = TTipler.degil then
        begin
            yazdir1('degil');
            ifade_degilli := TTipler.bitir;
        end;
        i := i + 1;
        Result := true;
        Exit;
    end;

    if parcalar[i].tip = TTipler.tanimlayici then
    begin
        deger := parcalar[i].deger;
        i := i + 1;
        prm_adet := 0;

        if Fonksiyon(prm_adet) then
            yazdir2('fonksiyon_yukle', deger + ' ' + IntToStr(prm_adet))
        else
            yazdir2('degisken_yukle', deger);

        if parcalar[i].tip = TTipler.nokta then
        begin
            i := i + 1;
            yazdir1('icinde');
            ifadeoku;
        end;

        if ifade_degilli = TTipler.degil then
        begin
            yazdir1('degil');
            ifade_degilli := TTipler.bitir;
        end;

        Result := true;
        Exit;

    end;

    Result := False;

end;

function TSozDizimselAnaliz.isle: Integer;
var
    deger: String;
    prm_sayisi: Integer;
begin
    while i < parcasayisi do
    begin
        if parcalar[i].tip = TTipler.susluparantezac then
        begin
            susluparantezsayisi := susluparantezsayisi + 1;
            yazdir1('basla');
            i := i + 1;
            Continue;
        end
        else if parcalar[i].tip = TTipler.susluparantezkapat then
        begin
            if bas_son_stack.Adet > 0 then
            begin

                if bas_son_stack.Getir = TTipler.tekrarla_sartsonda then
                begin
                    bas_son_stack.Sil;
                    i := i + 1;
                    yazdir1('bitti.');
                    SartOku(TTipler.ise, False);
                end
                else
                    bas_son_stack_isle_susluparantezkapat;
            end;

            yazdir1('bitti.');

            susluparantezsayisi := susluparantezsayisi - 1;
            i := i + 1;
            Continue;
        end
        else if parcalar[i].tip = TTipler.say then
        begin
            i := i + 1;
            for_dongusu;
            Continue;
        end
        else if parcalar[i].tip = TTipler.tekrarla then
        begin
            i := i + 1;
            yazdir1('tekrarla');
            while_dongusu;
            Continue;
        end
        else if parcalar[i].tip = TTipler.bitir then
        begin
            i := i + 1;
            yazdir1('bitir');
        end
        else if parcalar[i].tip = TTipler.devam then
        begin
            i := i + 1;
            yazdir1('devam');
        end
        else if parcalar[i].tip = TTipler.degilse then
        begin
            i := i + 1;
            if parcalar[i].tip = TTipler.eger then
            begin
                i := i + 1;
                yazdir1('degilse_eger');
                EgerOku;
                Continue;
            end
            else
            begin
                yazdir1('degilse');
                yazdir1('basla');
            end;

            if parcalar[i].tip = TTipler.susluparantezac then
            begin
                i := i + 1;
                susluparantezsayisi := susluparantezsayisi + 1;
                bas_son_stack.Ekle(TTipler.susluparantezac);
            end
            else
                bas_son_stack.Ekle(TTipler.degilse);
            Continue;
        end
        else if parcalar[i].tip = TTipler.eger then
        begin
            i := i + 1;
            yazdir1('eger');
            EgerOku;
            Continue;
        end
        else if parcalar[i].tip = TTipler.gonder then
        begin
            i := i + 1;
            if parcalar[i].tip = TTipler.noktalivirgul then
            begin
                i := i + 1;
                yazdir2('gonder', 'bos');
                Continue;
            end;

            if MatematikselIslem = False then
                Hata('Ýfade bekleniyordu ancak ' + parcalar[i].deger +
                  ' geldi.');

            yazdir1('gonder');
        end
        else if (parcalar[i].tip = TTipler.artiarti) or
          (parcalar[i].tip = TTipler.eksieksi) then
        begin
            i := i + 1;
            if parcalar[i].tip <> TTipler.tanimlayici then
                Hata('Deðiþken ya da ifade beklenirken ' + parcalar[i].deger +
                  ' geldi.');

            arti_arti_eksi_eksi(parcalar[i].deger, parcalar[i - 1].tip);
        end
        else if parcalar[i].tip = TTipler.tanimlayici then
        begin
            deger := parcalar[i].deger;
            prm_sayisi := 0;
            i := i + 1;
            if deger = 'sýnýf' then
            begin
                SinifIslem;
                Continue;
            end;
            if parcalar[i].tip = TTipler.nokta then
            begin
                i := i - 1;
                ifadeoku;
            end
            else if parcalar[i].tip = TTipler.esittir then
            begin
                i := i + 1;
                if MatematikselIslem then
                    yazdir2('degerata', deger)
                else
                    Hata('= den sonra bir ifade bekleniyordu ancak ' +
                      parcalar[i].deger + ' geldi.');
            end
            else if parcalar[i].tip = TTipler.artiesit then
            begin
                i := i + 1;
                yazdir2('degisken_yukle', deger);
                if MatematikselIslem then
                begin
                    yazdir1('arti');
                    yazdir2('degerata', deger);
                end
                else
                    Hata('+= den sonra bir ifade bekleniyordu ancak ' +
                      parcalar[i].deger + ' geldi.');
            end
            else if parcalar[i].tip = TTipler.eksiesit then
            begin
                i := i + 1;
                yazdir2('degisken_yukle', deger);
                if MatematikselIslem then
                begin
                    yazdir1('eksi');
                    yazdir2('degerata', deger);
                end
                else
                    Hata('-= den sonra bir ifade bekleniyordu ancak ' +
                      parcalar[i].deger + ' geldi.');
            end
            else if parcalar[i].tip = TTipler.boluesit then
            begin
                i := i + 1;
                yazdir2('degisken_yukle', deger);
                if MatematikselIslem then
                begin
                    yazdir1('bolu');
                    yazdir2('degerata', deger);
                end
                else
                    Hata('/= den sonra bir ifade bekleniyordu ancak ' +
                      parcalar[i].deger + ' geldi.');
            end
            else if parcalar[i].tip = TTipler.carpiesit then
            begin
                i := i + 1;
                yazdir2('degisken_yukle', deger);
                if MatematikselIslem then
                begin
                    yazdir1('carpi');
                    yazdir2('degerata', deger);
                end
                else
                    Hata('*= den sonra bir ifade bekleniyordu ancak ' +
                      parcalar[i].deger + ' geldi.');
            end
            else if parcalar[i].tip = TTipler.mod_esit then
            begin
                i := i + 1;
                yazdir2('degisken_yukle', deger);
                if MatematikselIslem then
                begin
                    yazdir1('mod_islemi');
                    yazdir2('degerata', deger);
                end
                else
                    Hata('%= den sonra bir ifade bekleniyordu ancak ' +
                      parcalar[i].deger + ' geldi.');
            end
            else if (parcalar[i].tip = TTipler.artiarti) or
              (parcalar[i].tip = TTipler.eksieksi) then
            begin
                arti_arti_eksi_eksi(deger, parcalar[i].tip);
            end
            else if FonksiyonTanimla(deger) then
            begin
                Continue;
            end
            else if DegiskenTanimla(deger) then
            begin

            end
            else if Fonksiyon(prm_sayisi) then
            begin
                yazdir2('fonksiyon_yukle', deger + ' ' + IntToStr(prm_sayisi));
            end
            else
                Hata(deger + ' deðiþkeni üzerinde hiçbir iþlme yapýlmadý.');

        end
        else
            Hata('Tanýmlanamayan tür: ' + parcalar[i].deger);

        if parcalar[i].tip = TTipler.noktalivirgul then
        begin
            i := i + 1;
            bas_son_stack_isle_noktalivirgul;
            Continue;
        end
        else
            Hata('; bekleniyordu ancak ' + parcalar[i].deger + ' geldi.');
    end;

    if susluparantezsayisi > 0 then
    begin
        Hata('} eksik');
    end;

    Result := 0;
end;

function TSozDizimselAnaliz.islem_onceligi_getir(t: TTipler): Integer;
begin
    if (t = TTipler.arti) or (t = TTipler.eksi) then
        Result := 1
    else if (t = TTipler.carpi) or (t = TTipler.bolu) or (t = TTipler.mod_islemi)
    then
        Result := 2
    else if (t = TTipler.ussu) then
        Result := 3;
end;

function TSozDizimselAnaliz.MatematikselIslem: Boolean;
var
    s: Array of TOperator;
    sAdet: Integer;
    ifadegerekli: Boolean;
    parantezsayisi: Integer;
    idx: Integer;
    p1, p2: Integer;
begin
    SetLength(s, 0);
    sAdet := 0;

    ifadegerekli := true;
    parantezsayisi := 0;

    while i < parcasayisi do
    begin
        if parcalar[i].tip = TTipler.noktalivirgul then
            Break;

        if (parcalar[i].tip = TTipler.kucuk) or
          (parcalar[i].tip = TTipler.kucukesit) or
          (parcalar[i].tip = TTipler.buyuk) or
          (parcalar[i].tip = TTipler.buyukesit) or
          (parcalar[i].tip = TTipler.esitmi) or
          (parcalar[i].tip = TTipler.esitdegil) or
          (parcalar[i].tip = TTipler.ise) or (parcalar[i].tip = TTipler.ve) or
          (parcalar[i].tip = TTipler.veya) then
        begin
            if ifadegerekli then
                Hata('Ýfade beklenirken ' + parcalar[i].deger + ' geldi.');
            Break;
        end;

        if parcalar[i].tip = TTipler.virgul then
            Break;

        if (parantezsayisi = 0) and (parcalar[i].tip = TTipler.parantezkapat)
        then
            Break;

        if (ifadegerekli) and (ifadeoku) then
        begin
            ifadegerekli := False;
            Continue;
        end;

        if (ifadegerekli) and (parcalar[i].tip <> TTipler.parantezac) then
            Hata('ifade bekleniyordu ancak ' + parcalar[i].deger + ' geldi.');

        idx := -1;

        if (parcalar[i].tip = TTipler.arti) or (parcalar[i].tip = TTipler.eksi)
          or (parcalar[i].tip = TTipler.carpi) or
          (parcalar[i].tip = TTipler.bolu) or
          (parcalar[i].tip = TTipler.mod_islemi) or
          (parcalar[i].tip = TTipler.ussu) then
            idx := islem_onceligi_getir(parcalar[i].tip);

        if idx <> -1 then
        begin
            ifadegerekli := true;

            if sAdet = 0 then
            begin
                sAdet := sAdet + 1;
                SetLength(s, sAdet);
                s[sAdet - 1] := TOperator.Create;
                s[sAdet - 1].tip := parcalar[i].tip;
                s[sAdet - 1].islemonceligi := idx;
            end
            else
            begin
                while sAdet > 0 do
                begin
                    p2 := s[sAdet - 1].islemonceligi;
                    p1 := idx;
                    if (p2 > p1) or
                      ((p2 = p1) and (parcalar[i].tip <> TTipler.ussu)) then
                    begin
                        yazdir1(GetEnumName(TypeInfo(TTipler),
                          Ord(s[sAdet - 1].tip)));

                        sAdet := sAdet - 1;
                        SetLength(s, sAdet);
                    end
                    else
                        Break;

                end;
                sAdet := sAdet + 1;
                SetLength(s, sAdet);
                s[sAdet - 1] := TOperator.Create;
                s[sAdet - 1].tip := parcalar[i].tip;
                s[sAdet - 1].islemonceligi :=
                  islem_onceligi_getir(parcalar[i].tip);
            end;
            i := i + 1;
        end
        else if parcalar[i].tip = TTipler.parantezac then
        begin
            sAdet := sAdet + 1;
            SetLength(s, sAdet);
            s[sAdet - 1] := TOperator.Create;
            s[sAdet - 1].tip := TTipler.parantezac;
            s[sAdet - 1].islemonceligi := -2;
            i := i + 1;
            parantezsayisi := parantezsayisi + 1;
        end
        else if parcalar[i].tip = TTipler.parantezkapat then
        begin
            if parantezsayisi = 0 then
                Hata('parantez yanlýþ yerde kapatýldý.');

            parantezsayisi := parantezsayisi - 1;

            while (sAdet > 0) and (s[sAdet - 1].islemonceligi <> -2) do
            begin
                yazdir1(GetEnumName(TypeInfo(TTipler), Ord(s[sAdet - 1].tip)));

                sAdet := sAdet - 1;
                SetLength(s, sAdet);
            end;
            sAdet := sAdet - 1;
            SetLength(s, sAdet);
        end
        else
            Hata('Operator beklenirken ' + parcalar[i].deger + ' geldi.');
    end;
    if ifadegerekli then
    begin
        Result := true;
        Exit;
    end;

    if parantezsayisi > 0 then
        Hata('Parantez hatasý! Parantezlerin hepsi kapanmamýþ.');

    while sAdet > 0 do
    begin
        yazdir1(GetEnumName(TypeInfo(TTipler), Ord(s[sAdet - 1].tip)));

        sAdet := sAdet - 1;
    end;
    SetLength(s, 0);
    Result := true;
end;

function TSozDizimselAnaliz.Parse(dosyaAdi: String): Integer;
begin
    SetLength(parcalar, 0);
    parcasayisi := 0;
    Parcala(dosyaAdi);
    Result := isle;
end;

function TSozDizimselAnaliz.SartOku(son: TTipler; stackisle: Boolean): Boolean;
var
    ifadegerekli: Boolean;
    sartvardi: Boolean;
    veveya: TUcDurum;
    parantezsayisi: Integer;

    stack: TStack;
begin
    ifadegerekli := true;
    sartvardi := False;
    veveya := TUcDurum.ZorunluHayir;

    parantezsayisi := 0;
    stack := TStack.Create;

    while i < parcasayisi do
    begin
        if parcalar[i].tip = son then
        begin
            if ifadegerekli then
                Hata('Ýfade beklenirken ' + parcalar[i].deger + ' geldi...');
            i := i + 1;
            if stackisle then
                SartOkuStackIsle(stack);
            Break;
        end;

        if (parcalar[i].tip = TTipler.degil) and
          (parcalar[i + 1].tip = TTipler.parantezac) then
        begin
            stack.Ekle(parcalar[i].tip);
            i := i + 1;
            ifadegerekli := true;
            veveya := TUcDurum.ZorunluHayir;
            Continue;
        end;

        if parcalar[i].tip = TTipler.parantezac then
        begin
            stack.Ekle(parcalar[i].tip);
            i := i + 1;
            ifadegerekli := true;
            veveya := TUcDurum.ZorunluHayir;
            parantezsayisi := parantezsayisi + 1;
            Continue;
        end;

        if parcalar[i].tip = TTipler.parantezkapat then
        begin
            i := i + 1;
            SartOkuStackIsle(stack);
            ifadegerekli := False;
            veveya := TUcDurum.ZorunluEvet;
            parantezsayisi := parantezsayisi - 1;
            Continue;
        end;

        if ifadegerekli then
        begin
            if MatematikselIslem then
            begin
                ifadegerekli := false;
                veveya := TUcDurum.Farketmez;
                sartvardi := true;
            end
            else if ifadeoku then
            begin
                ifadegerekli := false;
                veveya := TUcDurum.Farketmez;
                sartvardi := true;
            end
            else
                Hata('Ýfade beklenirken ' + parcalar[i].deger + ' geldi.');
        end;

        if parcalar[i].tip = TTipler.parantezkapat then
        begin
            i := i + 1;
            SartOkuStackIsle(stack);
            ifadegerekli := False;
            veveya := TUcDurum.ZorunluEvet;
            parantezsayisi := parantezsayisi - 1;
            Continue;
        end
        else if parcalar[i].tip = son then
        begin
            if ifadegerekli then
                Hata('Ýfade beklenirken ' + parcalar[i].deger + ' geldi.');
            i := i + 1;
            Break;
        end;

        if (parcalar[i].tip = TTipler.ve) or (parcalar[i].tip = TTipler.veya)
        then
        begin
            stack.Ekle(parcalar[i].tip);
            i := i + 1;
            ifadegerekli := true;
            veveya := TUcDurum.Farketmez;
            Continue;
        end

        else if (parcalar[i].tip = TTipler.esitmi) or
          (parcalar[i].tip = TTipler.esitesitesit) or
          (parcalar[i].tip = TTipler.esitdegil) or
          (parcalar[i].tip = TTipler.kucuk) or
          (parcalar[i].tip = TTipler.kucukesit) or
          (parcalar[i].tip = TTipler.buyuk) or
          (parcalar[i].tip = TTipler.buyukesit) then
        begin
            if veveya = TUcDurum.ZorunluEvet then
                Hata('ve / veya beklenirken ' + parcalar[i].deger + ' geldi.');

            yazdir2('karsilastir', parcalar[i].deger);
            i := i + 1;
            ifadegerekli := true;
            Continue;
        end
        else
            Hata('Oopps fazla geldin: ' + parcalar[i].deger);
    end;

    if parantezsayisi > 0 then
        Hata('Kapanmayan parantez var!!!');
    if parantezsayisi < 0 then
        Hata('Fazladan kapatýlmýþ parantez var!!!');

    SartOkuStackIsle(stack);
    Result := sartvardi;
end;

procedure TSozDizimselAnaliz.SartOkuStackIsle(st: TStack);
begin
    while st.Adet > 0 do
    begin
        if st.Getir = TTipler.parantezac then
        begin
            st.Sil;

            while (st.Adet > 0) and (st.Getir = TTipler.degil) do
            begin
                yazdir1('degil');
                st.Sil;
            end;
            Break;
        end;

        if st.Getir = TTipler.degil then
            yazdir1('degil')
        else
            yazdir2('birlestir', st.GetirStr);
        st.Sil;
    end;
end;

procedure TSozDizimselAnaliz.Sifirla;
begin
    i := 0;
    satir := 0;
end;

procedure TSozDizimselAnaliz.SinifIslem;
var
    sinifadi: String;
    kalitim_sinifi: String;
begin
    if parcalar[i].tip <> TTipler.tanimlayici then
        Hata('Sýnýf adý beklenirken ' + parcalar[i].deger + ' geldi.');

    sinifadi := parcalar[i].deger;
    kalitim_sinifi := '';
    i := i + 1;

    if parcalar[i].tip = TTipler.ikinoktaustuste then
    begin
        i := i + 1;
        if parcalar[i].tip <> TTipler.tanimlayici then
            Hata('Kalýtým için sýnýf adý beklenirken ' + parcalar[i].deger +
              ' geldi.');
        kalitim_sinifi := parcalar[i].deger;
        i := i + 1;
    end;

    if parcalar[i].tip <> TTipler.susluparantezac then
        Hata('{ beklenirken ' + parcalar[i].deger + ' geldi.');

    susluparantezsayisi := susluparantezsayisi + 1;
    i := i + 1;
    yazdir2('sinif_tanimla', sinifadi);
    if kalitim_sinifi <> '' then
        yazdir2('kalitim', kalitim_sinifi);
    yazdir1('basla');
end;

procedure TSozDizimselAnaliz.while_dongusu;
begin
    if parcalar[i].tip = TTipler.susluparantezac then
    begin
        susluparantezsayisi := susluparantezsayisi + 1;
        i := i + 1;
        bas_son_stack.Ekle(TTipler.tekrarla_sartsonda);
    end
    else
    begin
        if SartOku(TTipler.ise, true) = False then
            Hata('Þart ifadesi beklenirken ' + parcalar[i].deger + ' geldi.');

        if parcalar[i].tip = TTipler.susluparantezac then
        begin
            susluparantezsayisi := susluparantezsayisi + 1;
            i := i + 1;
            bas_son_stack.Ekle(TTipler.susluparantezac);
        end
        else
            bas_son_stack.Ekle(TTipler.tekrarla);
    end;

    yazdir1('basla');
end;

procedure TSozDizimselAnaliz.yazdir1(kod: String);
begin
    yazdir2(kod, '');
end;

procedure TSozDizimselAnaliz.yazdir2(kod, w: String);
var
    str: String;
begin
    str := '';
    if Hex then
        str := getHex(kod)
    else
        str := kod;

    if w <> '' then
        w := ' ' + w;

    if KonsolaYaz then
        writeln(str, w);

    fCikti.Ekle(str + w);
end;

end.
