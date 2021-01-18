with Ada.Text_IO, Ada.Numerics.Float_Random, Ada.Numerics
   .Discrete_Random, bufor;
use Ada.Text_IO, Ada.Numerics.Float_Random;

procedure kontrolerobiektu is
    -- typ danych określający sortowane obiekty
    type Obiekt is (typ1, typ2, typ3);
    iloscTypow : constant Integer := 3;
    -- typ dla maszyny stanów wewnątrz sortownika
    type Stany is (pobieranie, wstawianie, czekanie);
    function Obraz (o : Obiekt) return String is  --pomocnicza funkcja do tworzenia Stringa aby wyświetlić zawartość bufora 
        (o'Img);
    package LosObiekt is new Ada.Numerics.Discrete_Random (Obiekt);
    package BuforObjektow is new bufor (Obiekt,Obraz => Obraz);

    -- task taśmociągu / generatora obiektów definicja
    task type TasmociagObiektow is
        entry Start (liczbaObiektow : in Integer); --wejscie z parametrem "in" definiującym ile obiektow ma zostac wygenerowanych
        entry Wstrzymaj;
        entry Wznow;
        entry Stop; -- wejscia "Stop" oznaczają koniec pracy task'ów
    end TasmociagObiektow;

    -- task sortownika definicja
    task type SortownikObiektow is
        entry Start;
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end SortownikObiektow;

    -- task pakera definicja
    task type PakerObiektu is
        entry Start (typO : in Obiekt; nazwaO : in String; numerO : in integer); --wejscie z parametrami "in" definiującymi jakiego typu obiekty ma pakować, nadające mu numer do identyfikacji pakera
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end PakerObiektu;

    -- task bezpieczeństwa definicja
    task type Bezpieczenstwo is
        entry Start;
        entry Sygnalizuj; -- wejscie oznaczające awaryjne wcisniecie przycisku bezpieczenstwa, zatrzymujace prace maszyn
        entry Wznow; -- wejscie oznaczajace wznowienie pracy maszyn po ustaniu zagrożenia
        entry Stop;
    end Bezpieczenstwo;

    -- bufory wyjściowe(konkretnego typu obiektow) z sortownika/sortowników, z ktorych pobierają Pakery
    BOs : array (Obiekt) of BuforObjektow.BuforP;
    -- bufor wejściowy sortownika/sortowników, do którego wstawia Taśmociąg
    BS : BuforObjektow.BuforP;
    -- tworzenie taśmociągu
    T : TasmociagObiektow;
    -- tworzenie sortowników
    Ss : array (Integer range 0 .. 1) of SortownikObiektow;
    -- tworzenie pakerów
    Ps : array (Integer range 0 .. 2) of PakerObiektu;
    -- tworzenie tablicy zmiennych informujących czy dany paker jest w trakcie pracy
    PsON : array (Ps'range) of Boolean := ( others => False);
    -- tworzenie sterownika bezpieczeństwa
    B : Bezpieczenstwo;
    -- zmienna bezpiecznego działania procesu
    on : Boolean := False;

    -- task taśmociągu / generatora - implementacja
    task body TasmociagObiektow is
        G                : LosObiekt.Generator; -- generator różnego typu obiektów
        L                : Integer; -- zmienna wykorzystywana do wygenerowania wlasciwej liczby obiektów
        pauza            : Boolean := False; -- zmienna informujaca czy Tasmociag jest aktualnie wstrzymany
        dane             : Obiekt; -- zmienna do przechowywania elementu przekazywanego pozniej do bufora sortownika/sortowników
    begin
        accept Start (liczbaObiektow : in Integer) do
            L := liczbaObiektow;
        end Start;
        Put_Line ("==== TASMOCIAG ROZPOCZYNA PRACE");
        Main: loop
            select
                accept Stop;
                exit Main;
            or
                accept Wstrzymaj do
                    Put_Line ("==== TASMOCIAG WSTRZYMANY");
                    pauza := True;
                end Wstrzymaj;
            or
                accept Wznow do
                    Put_Line ("==== TASMOCIAG WZNOWIONY");
                    pauza := False;
                end Wznow;
            else
                if not pauza then -- jesli Taśmociąg nie jest wstrzymany
                    if not BS.Pelny then -- sprawdzanie czy mozna wstawić obiekt, jeśli nie Taśmociąg czeka aby nie wywołać awarii
                        dane := LosObiekt.Random (G);
                        --Put_Line
                        --   (" TASMOCIAG UMIESCZCZA DANE TYPU »" & dane'Img &
                        --    "« DO BUFORA SORTOWNIKA");
                        BS.Wstaw (dane);--wstawianie obiektu do buforu sortownika/ów
                        Put_Line("==== (" & L'Img &" ) TASMOCIAG WSTAWIA " & dane'Img & " DO BS()=" & BS.Wyswietl);
                        L := L - 1;
                        delay 0.1;
                    else
                        Put_Line ("==== TAŚMOCIĄG CZEKA NA MIEJSCE W SORTOWNIKU");
                        while True loop -- pętla czekania na zwolnienie miejsca w buforze sortownika/ów
                            if not BS.Pelny then
                                exit;
                            end if;
                        end loop;
                    end if;
                    -- zakoncz generowanie obiektów gdy L=0 (jak ujemne to generuje je w nieskonczonosc)
                    exit when L = 0;
                end if;
            end select;
        end loop Main;
        Put_Line ("==== TASMOCIAG KONCZY PRACE");
        -- poczekaj do opróżnienia buforu sortownika/ów
        while not BS.Pusty loop
            null;
        end loop;
        -- zakończ pracę sortownika/ów, ponieważ więcej obiektów już nie będzie
        for S of Ss loop
            S.Stop;
        end loop;
    end TasmociagObiektow;

    -- task sortownika - implementacja
    task body SortownikObiektow is
        dane          : Obiekt; -- zmienna przechowujaca obiekt przekazywany do bufora konkretnego typu obiektów
        podmieniony   : Boolean := False; -- zmienna pomocnicza informująca czy podmiana się powiodła
        pauza         : Boolean := False;
        stan          : Stany   := pobieranie; -- zmienna przechowująca aktualny stan sortownika
    begin
        accept Start;
        Put_Line ("SORTOWNIK OBIEKTOW ROZPOCZYNA PRACE");
        loop
            select
                accept Stop;
                exit;
            or
                accept Wstrzymaj do
                    Put_Line ("SORTOWNIK WSTRZYMANY");
                    pauza := True;
                end Wstrzymaj;
            or
                accept Wznow do
                    Put_Line ("SORTOWNIK WZNOWIONY");
                    pauza := False;
                end Wznow;

            else
                if not pauza then
                    -- maszyna stanow sortownika - stan okresla co w danym momencie powinien robic sortownik
                    case stan is
                        when pobieranie => -- pobiera obiekt z tych wstawionych przez Taśmociąg i przechodzi w stan wstawianie
                            if not BS.Pusty then
                                BS.Pobierz (dane);
                                Put_Line("SORTOWNIK POBRAŁ " & dane'Img & " Z BS()=" & BS.Wyswietl);
                                stan := wstawianie;
                            end if;
                        when wstawianie => -- stan realizujacy sortowanie - sortownik wstawia dany typ do odpowiedniego buforu i przechodzi w stan pobieranie
                            if BOs(dane).Pelny then -- jesli bufor obiektu jest pełny na razie nie uda sie wstawic obiektu, 
                            --wiec jesli w buforze sortownika są min 2 obiekty, sprawdza czy jest możliwa podmiana i wstawienie jakiegos innego typu

                                                            --if not podmieniony then
                                                            --    Put_Line(" BUFOR POBRANEGO PRZEZ SORTOWNIK OBIEKTU JEST PRZEPEŁNIONY, PODMIENIAM...");
                                Put_Line("Bede podmieniac");
                                if(BS.Ile>1) then
                                    Put_Line("Bedzie podmienianeee essaaa");
                                    BS.Podmien (dane, podmieniony);
                                end if;
                                Put_Line("Skonczylem");
                                                            --end if;
                                                            --else
                                if podmieniony then
                                    Put_Line("SORTOWNIK PODMIENIL ELEMENT I BEDZIE PROBOWAL WSTAWIC");
                                    stan := wstawianie; -- udalo sie podmienic, więc zmienia stan na wstawianie aby podjac probe wstawienia podmienionego obiektu
                                    podmieniony := False;
                                else
                                    Put_Line("Nie udalo sie podmienic sortownik czeka na miejsce");
                                    stan := czekanie; -- nie udalo sie podmienic, wieć musi czekać na miejsce w odpowiednim buforze
                                end if;
                                    
                                --end if;
                            else
                                BOs (dane).Wstaw(dane);
                                Put_Line("SORTOWNIK WSTAWIŁ " & dane'Img &" DO BOs(" & dane'Img & ")=" & BOs(dane).Wyswietl);
                                stan := pobieranie;
                            end if;
                        when czekanie =>  -- czeka aż pojawi się miejsce w buforze na dany obiekt, następnie wstawia go i przechodzi w stan pobieranie
                            if not BOs (dane).Pelny then
                                BOs (dane).Wstaw(dane);
                                Put_Line("SORTOWNIK sie doczeka i WSTAWIŁ " & dane'Img &" DO BOs(" & dane'Img & ")=" & BOs(dane).Wyswietl);
                                stan := pobieranie;
                            end if;
                    end case;

                    -- pobierz nową próbkę jeśli nie nastąpiła podmiana
                    --if not BS.Pusty then
                    --    BS.Pobierz (dane);
                    --    delay 0.1;
                    --    Put_Line(" SORTOWNIK POBRAŁ " & dane'Img & " Z BS()=" & BS.Poka);
                    --    -- jeśli nie ma miejsca dla danego elementu to spróbuj go podmienić na inny
                    --    if BOs (dane).Pelny then
                    --        Put_Line(" BUFOR POBRANEGO PRZEZ SORTOWNIK OBIEKTU JEST PRZEPEŁNIONY, PODMIENIAM...");
                    --        BS.Podmien (dane, podmieniony);
-- jeśli podmiana si--ę nie udała to poczekaj kiedy zwolni się miejsce w buforze
                    --        if not podmieniony then
                    --            Put_Line(" SORTOWNIK NIE PODMIENIŁ WIEC CZEKA NA MIEJSCE");
                    --            while BOs(dane).Pelny loop
                    --                delay 0.01;
                    --            end loop;
                    --        else
                    --            Put_Line(" SORTOWNIK PODMIENIŁ ELEMENT NA " & dane'Img);
                    --            if BOs (dane).Pelny then
                    --                Put_Line(" SORTOWNIK PODMIENIŁ, ALE CZEKA NA WOLNE MIEJSCE ");
                    --                while BOs (dane).Pelny loop
                    --                    delay 0.01;
                    --                end loop;
                    --            end if;
                    --            podmieniony := False;
                    --        end if;
                    --    end if;
                    --    BOs (dane).Wstaw (dane);
                    --    Put_Line(" SORTOWNIK WSTAWIŁ " & dane'Img &" DO BOs(" & dane'Img & ")=" & BOs (dane).Poka);
                    --end if;
                end if;
            end select;
        end loop;
        
        -- sortownik gdy ma zakończyć pracę czeka aż Pakerzy zapakują wszystkie obiekty
        Stop_Loop :
        for BO of BOs loop
            while not BO.Pusty loop
                null;
            end loop;
        end loop Stop_Loop;

        --gdy nie ma już obiektów do spakowania, zakańcza pracę Pakerów
        Stop_Loop1 :
        for P of Ps loop
            P.Stop;
        end loop Stop_Loop1;

        Put_Line ("SORTOWNIK OBIEKTOW KONCZY PRACE");
        B.Stop; -- wszystkie taski już kończą pracę dlatego można wyłączyć kontrolę bezpieczeństwa 
    end SortownikObiektow;

    -- task pakera obiektu danego typu - implementacja
    task body PakerObiektu is
        nazwa : String  := "BLANK";
        numer : Integer := 0; -- numer pakera, identyfikujący go
        typ   : Obiekt; -- typ obiektów, które będzie pakował
        dane  : Obiekt; -- zmienna przechowująca aktualnie pakowany obiekt
        pauza : Boolean := False;
    begin
        accept Start (typO : in Obiekt; nazwaO : in String; numerO : in integer) do
            typ   := typO;
            nazwa := nazwaO;
            numer := numerO;
        end Start;
        Put_Line
           ("     PAKER OBIEKTU " & nazwa & " DLA " & typ'Img & " ROZPOCZYNA PRACE");
        PsON(numer) := True; -- w tablicy statusów pracy pakerów ustawiamy wartość na True czyli pracujący
        loop
            select
                accept Stop;
                exit;
            or
                accept Wstrzymaj do -- wyjscie pakera na przerwe
                    Put_Line ("     ------ PAKER " & nazwa & " MA PRZERWĘ ------");
                    pauza := True;
                end Wstrzymaj;
            or
                accept Wznow do -- powrot pakera do pracy
                    Put_Line ("     ------ PAKER " & nazwa & " WRÓCIŁ ------");
                    pauza := False;
                end Wznow;
            else
                if not pauza then
                -- sprawdza czy bufor nie jest pusty, jeśli nie jest pobiera obiekt do spakowania
                    if not BOs (typ).Pusty then
                        BOs (typ).Pobierz (dane);
                        delay 1.5; -- czas przeznaczony na spakowanie obiektu
                        Put_Line("     PAKER OBIEKTU " & nazwa & " SPAKOWAŁ " & dane'Img & " BOs(" & dane'Img & ")=" & BOs(typ).Wyswietl);
                    end if;
                end if;
            end select;
        end loop;
        Put_Line("     PAKER OBIEKTU " & nazwa & " DLA " & typ'Img & " KONCZY PRACE");
        PsON(numer) := False; -- zmiana statusu pracownika na False czyli niepracujący
    end PakerObiektu;

    -- task bezpieczeństwo - implementacja
    task body Bezpieczenstwo is
        mozeZakonczyc : Boolean := False; -- zmienna pomocnicza okreslajaca czy wszystkie jednostki skonczyly juz prace i mozna zakonczyc kontrole bezpieczenstwa
    begin
        accept Start;
        Put_Line ("!! STEROWNIK BEZPIECZENSTWA ROZPOCZAL DZIALANIE !!");
        on := True;
        loop
            select
                accept Stop;
                exit;
            or
                accept Sygnalizuj; -- awaryjne wstrzymanie pracy maszyn
                Put_Line ("!! POCZATEK E-STOP !!");
                T.Wstrzymaj;
                for S of Ss loop
                    S.Wstrzymaj;
                end loop;
            or
                accept Wznow; -- wznowienie pracy maszyn
                Put_Line ("!! KONIEC E-STOP !!");
                T.Wznow;
                for S of Ss loop
                    S.Wznow;
                end loop;
            else
                null;
            end select;
        end loop;

        Put_Line ("!! STEROWNIK BEZPIECZENSTWA OCZEKUJE NA ZAKONCZENIE PRACY NA HALI !!");
        SprawdzPakerow: loop -- pętla czekania na zakonczenie pracy pakerów
            mozeZakonczyc := True;
            for stan of PsON loop
                if stan then -- jesli ktorykolwiek z pakerow jeszcze pracuje - funkcja bezpieczenstwa dalej jest włączona
                    mozeZakonczyc := False;
                    exit;
                end if;
            end loop;
            exit SprawdzPakerow when mozeZakonczyc;
        end loop SprawdzPakerow;
        -- wyjscie z pętli - czyli można bezpiecznie zakończyć symulator pakowania i sortowania
        Put_Line ("!! STEROWNIK BEZPIECZENSTWA ZAKONCZYL DZIALANIE !!");
        on := False; -- funkcja bezpieczenstwa wyłączona
    end Bezpieczenstwo;

begin
    Put_Line ("***** SYMULATOR SORTOWANIA I PAKOWANIA *****");
    B.Start; -- uruchomienie modułu bezpieczenstwa
    while on /= True loop --?????????
        null;
    end loop;
    -- startowanie i inicjacja pakerów
    for indeks in Ps'Range loop
        Ps(indeks).Start(Obiekt'Val (indeks mod iloscTypow),"Pkr" & indeks'Img, indeks);
    end loop;
    --startowanie sortowników
    for S of Ss loop
        S.Start;
    end loop;
    -- startowanie taśmociągu z podaniem ilosci obiektow do wygenerowania
    delay 0.01;
    T.Start (50);
    Put_Line (" ");

    delay 2.0;
    -- wyslanie pakerow na przerwe - pokazanie wlasciwego dzialania symulatora w przypadku przepelnien buforow
    Przerwa_Pakerow_typu1 :
    for I in Ps'Range loop
        if (True) then
            Ps (I).Wstrzymaj;
        end if;
    end loop Przerwa_Pakerow_typu1;

    delay 5.0;
    -- powrot pakerow do pracy
    Powrot_Pakerow_typu1 :
    for I in Ps'Range loop
        if (True) then
            Ps (I).Wznow;
        end if;
    end loop Powrot_Pakerow_typu1;

    -- awaryjne nacisniecie przycisku bezpieczenstwa - pokazanie wlasciwego dzialania symulatora - maszyny wstrzymują dzialanie, pakerzy moga dokonczyc pakowanie tego co już do nich przyszło
    B.Sygnalizuj;
    delay 5.0;
    B.Wznow;

    -- czekaj na wyłączenie modułu bezpieczeństwa
    while on = True loop
        null;
    end loop;
    
    -- wyswietlenie koncowej zawartosci buforow - pokazanie ze dzialanie symulatora przebiegło poprawnie, wszystko zostało posortowane i spakowane
    Put_Line("***** SYMULATOR SORTOWANIA I PAKOWANIA BEZPIECZNIE ZAKOŃCZYŁ DZIAŁANIE *****");
    Put_Line(" BS()=" & BS.Wyswietl);
    for BOtype in BOs'Range loop
        Put_Line(" BO(" & BOtype'img & ")=" & BOs(BOtype).Wyswietl);
    end loop;

end kontrolerobiektu;
