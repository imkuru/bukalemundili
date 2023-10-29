program BukalemunDerleyici;

{$APPTYPE CONSOLE}
{$R *.res}

uses
    System.SysUtils,
    Classes,
    TiplerU in 'TiplerU.pas',
    KodParcalaU in 'KodParcalaU.pas',
    DosyaU in 'DosyaU.pas',
    SozdizimselAnalizU in 'SozdizimselAnalizU.pas',
    StackU in 'StackU.pas';

var
    s: TSozDizimselAnaliz;

    uzanti: String;
    dosyaadi: String;
    klasor: String;
    projeadi: String;

    dosya: String;

    durdur: Boolean;
    konsolgizle: Boolean;
    buk_dosyasi: Boolean;

    fManifest: TDosya;

    I: Integer;
    d: TDosya;
    err_no: Integer;

    dosyaAdiOku: String;

begin
    try
        s := TSozDizimselAnaliz.Create;
        s.BFDprogramAnaKlasor := ExtractFilePath(ParamStr(0));

        durdur := false;
        konsolgizle := false;
        buk_dosyasi := false;

        if ParamCount = 0 then
        begin
            writeln('Derlenecek *.ale veya *.buk dosyasý parametre olarak gönderilmelidir.');
            readln;
            ExitCode := 10;
            exit;
        end;

        if ParamStr(1) = '-?' then
        begin
            writeln('Bukalemun v1.0' + #13);
            writeln('-beklet: Derleme bittikten sonra konsol penceresini durdur.');
            writeln('-konsolayaz: Derleme sonucunu dosyaya ve konsol ekranýna yaz.');
            writeln('-hexyok: Derleme sonucunu hex kod yerine okunabilir kod olarak yaz.');
            writeln('-form: Derlenecek kodlarýn form uygulamasýna ait olduðunu belirler.');
            exit;
        end;

        if ParamCount > 1 then
        begin
            for I := 1 to ParamCount do
            begin
                if ParamStr(I) = '-beklet' then
                    durdur := true
                else if ParamStr(I) = '-konsolayaz' then
                    s.KonsolaYaz := true
                else if ParamStr(I) = '-hexyok' then
                    s.Hex := false
                else if ParamStr(I) = '-konsolgizle' then
                    konsolgizle := true
                else if ParamStr(I) = '-form' then
                    s.WinForm := true
                else if ParamStr(I) = '-tokengoster' then
                     s.tokenGoster := True;
            end;
        end;

        dosya := ParamStr(1);
        uzanti := ExtractFileExt(dosya);
        dosyaadi := ExtractFileName(dosya);
        dosyaadi := copy(dosyaadi, 1, length(dosyaadi) - length(uzanti));

        klasor := ExtractFilePath(dosya);

        s.kod_dosyasi_adi := dosyaadi;
        s.kod_dosyasi_klasor := klasor;

        if uzanti = '.buk' then
        begin
            buk_dosyasi := true;
        end
        else if uzanti = '.ale' then
        begin
            buk_dosyasi := false;
        end
        else
        begin
            writeln('*.buk veya *.ale dosyasý parametre olarak gönderilebilir.');
            readln;
            ExitCode := 10;
            exit;
        end;

        if buk_dosyasi then
        begin
            projeadi := dosyaadi;
        end
        else
        begin
            fManifest := TDosya.Create(dosya);
            projeadi := fManifest.SatirGetir(0);
        end;

        if s.WinForm then
        begin
            if FileExists(klasor + projeadi + '.munf') then
                DeleteFile(klasor + projeadi + '.munf');
        end
        else
        begin
            if FileExists(klasor + projeadi + '.mun') then
                DeleteFile(klasor + projeadi + '.mun');
        end;

        if FileExists(klasor + projeadi + '_rapor.txt') then
            DeleteFile(klasor + projeadi + '_rapor.txt');

        if FileExists(klasor + projeadi + '_rapor2.txt') then
            DeleteFile(klasor + projeadi + '_rapor2.txt');

        s.CiktiDosyasiAyarla(projeadi);
        if buk_dosyasi then
        begin
            if FileExists(dosya) = false then
            begin
                writeln(dosya + ': Bulunamadý');
                ExitCode := 0;
                exit;
            end;

            s.islemGorenDosya := dosya;
            s.Sifirla;
            err_no := s.Parse(dosya);
        end
        else
        begin
            for I := 1 to fManifest.SatirSayisi - 1 do
            begin
                dosyaAdiOku := fManifest.SatirGetir(I);

                if FileExists(dosyaAdiOku) = false then
                begin
                    writeln(dosya + ': Bulunamadý');
                    ExitCode := 0;
                    exit;
                end;

                s.islemGorenDosya := dosyaAdiOku;
                s.Sifirla;
                err_no := s.Parse(dosyaAdiOku);
            end;
            fManifest.Kapat;
        end;

        s.CiktiDosyasiKapat;
        writeln('iþlem baþarýlý.');

        if durdur then
            readln;
    except
        on E: Exception do
        begin
            writeln(E.ClassName, ': ', E.Message);
            readln;
        end;
    end;

end.
