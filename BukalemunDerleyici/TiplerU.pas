unit TiplerU;

interface

type
    TTipler = (sayisal, metinsel,

      mantiksal,

      tanimlayici, tekkarakter,

      arti, artiarti, artiesit, eksiesit, eksi, eksieksi, carpi, carpiesit,
      bolu, boluesit, mod_islemi, mod_esit,

      virgul, nokta, noktalivirgul, ikinokta, ucnokta, ikinoktaustuste,
      soruisareti, unlem,

      esittir, esitesitesit, esitmi, esitdegil, kucuk, kucukesit, buyuk,
      buyukesit, degil, ussu,

      parantezac, parantezkapat, susluparantezac, susluparantezkapat,
      koseliparanteziac, koseliparantezikapat,

      ampersan, duzcizgi, ve, veya,

      eger, ise, degilse, degilse_eger, gonder, say, tekrarla, tekrarla_sartsonda,

      bitir, devam);

    TParca = record
        tip: TTipler;
        deger: String;
        satir: Integer;
    end;

    TOperator = class
        tip: TTipler;
        islemonceligi: Integer;
    end;

    TUcDurum = (ZorunluEvet, ZorunluHayir, Farketmez);

implementation

end.
