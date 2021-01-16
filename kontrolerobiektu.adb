-- kontrolerobiektu.adb

with Ada.Text_IO, Ada.Numerics.Float_Random, Ada.Numerics
   .Discrete_Random, bufor;
use Ada.Text_IO, Ada.Numerics.Float_Random;

procedure kontrolerobiektu is
    -- typ danych określający sortowane obiekty
    type Obiekt is (typ1, typ2);
    iloscTypow : constant Integer := 2;
    function Obraz (o : Obiekt) return String is
        (o'Img);
    package LosObiekt is new Ada.Numerics.Discrete_Random (Obiekt);
    -- wersja z typem protected
    package BuforObjektow is new bufor (Obiekt,Obraz => Obraz);

    -- task taśmociągu / generatora obiektów definicja
    task type TasmociagObiektow is
        entry Start (liczbaObiektow : in Integer);
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end TasmociagObiektow;

    -- task sortownika definicja
    task type SortownikObiektow is
        entry Start;
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end SortownikObiektow;

    -- task pakera definicja (może zmienić na generyczny pakiet?)
    task type PakerObiektu is
        entry Start (typO : in Obiekt; nazwaO : in String);
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end PakerObiektu;

    -- task bezpieczeństwa definicja
    task type Bezpieczenstwo is
        entry Start;
        entry Sygnalizuj;
        entry Stop;
    end Bezpieczenstwo;

    function Ktory_Elem (X : Integer) return Integer is (51 - X);

    -- bufory wyjściowe z sortownika
    BOs : array (Obiekt) of BuforObjektow.BuforP;
    -- bufor wejściowy sortownika
    BS : BuforObjektow.BuforP;
    -- tworzenie taśmociągu
    T : TasmociagObiektow;
    -- tworzenie sortowników
    Ss : array (Integer range 0 .. 0) of SortownikObiektow;
    -- tworzenie pakerów (nie zainicjowanych!)
    Ps : array (Integer range 0 .. 4) of PakerObiektu;
    -- tworzenie sterownika bezpieczeństwa
    B : Bezpieczenstwo;

    -- task taśmociągu / generatora implementacja
    task body TasmociagObiektow is
        G                : LosObiekt.Generator;
        L                : Integer;
        pauza            : Boolean := False;
        IloscWSortowniku : Integer := 0;
        dane             : Obiekt;
    begin
        accept Start (liczbaObiektow : in Integer) do
            L := liczbaObiektow;
        end Start;
        Put_Line (" TASMOCIAG ROZPOCZYNA PRACE");
        loop
            select
                accept Stop;
                exit;
            or
                -- TEST  TAK SIE POWINNO JE ZATRZYMYWAĆ - POZOSTAŁE TRZEBA TAK PRZEROBIĆ       # # # #
                accept Wstrzymaj do
                    Put_Line ("TASMOCIAG WSTRZYMANY");
                    pauza := True;
                end Wstrzymaj;
                -- while True loop
            or
                accept Wznow do
                    Put_Line ("TASMOCIAG WZNOWIONY");
                    pauza := False;
                end Wznow;
                --     exit;
                -- end loop;
            else
                -- -- zamiast else wykorzystany timed-entry
                -- or
                --     delay 0.05;
                if not pauza then
                    --S.Przyjmij(Float(Random(G)*5.0));
                    if not BS.Pelny then
                        dane := LosObiekt.Random (G);
                        Put_Line
                           (" TASMOCIAG UMIESCZCZA DANE TYPU »" & dane'Img &
                            "« DO BUFORA SORTOWNIKA");
                        BS.Wstaw (dane, IloscWSortowniku);
                        Put_Line
                           ("+++++ Ilosc elem w sortowniku po wstawieniu elem nr " &
                            Ktory_Elem (L)'Img & ": " & BS.Ile'Img);

                        L := L - 1;
                        delay 0.5;
                    else
                        Put_Line ("TAŚMOCIĄG CZEKA NA MIEJSCE W SORTOWNIKU");
                        while True loop
                            if not BS.Pelny then
                                exit;
                            end if;
                        end loop;
                    end if;
                    -- jak ujemne to generuje w nieskonczonosc
                    exit when L = 0;
                end if;
            end select;
        end loop;
        Put_Line (" TASMOCIAG KONCZY PRACE");
        -- -- poczekaj do opróżnienia buforu sortownika
        while not BS.Pusty loop
            null;
        end loop;
        -- -- uśmierć sortowniki
        for S of Ss loop
            S.Stop;
        end loop;
    end TasmociagObiektow;

    -- task sortownika implementacja
    task body SortownikObiektow is
        dane          : Obiekt;
        podmieniony   : Boolean := False;
        numer_obiektu : Integer := 0;
        pauza         : Boolean := False;
        ilosc_elem    : Integer := 0;
        ilosc_sort    : Integer := 0;
        s             : String (1..256);
    begin
        accept Start;
        Put_Line (" SORTOWNIK OBIEKTOW ROZPOCZYNA PRACE");
        loop
            select
                accept Stop;
                Stop_Loop :
                for I in Obiekt loop

                    while not BOs (I).Pusty loop
                        delay 0.01;
                    end loop;

                end loop Stop_Loop;

                Stop_Loop1 :
                for I in Ps'Range loop

                    Ps (I).Stop;

                end loop Stop_Loop1;

                exit;
            or
                accept Wstrzymaj do
                    Put_Line ("SORTOWNIK WSTRZYMANY");
                    pauza := True;
                end Wstrzymaj;
                -- while True loop
            or
                accept Wznow do
                    Put_Line ("SORTOWNIK WZNOWIONY");
                    pauza := False;
                end Wznow;
                --     exit;
                -- end loop;

            else
                if not pauza then
                    -- pobierz nową próbkę jeśli nie nastąpiła podmiana
                    if not BS.Pusty then
                        delay 0.1;
                        BS.Pobierz (dane);
                        --Put_Line(" SORTOWNIK OBIEKTOW POBRAŁ " & dane'Img);
                        Put_Line
                           ("------- Ilosc elem w sortowniku po pobraniu elem: " &
                            BS.Ile'Img);
            -- jeśli nie ma miejsca dla danego elementu to spróbuj go podmienić
                        if BOs (dane).Pelny then
                            Put_Line ("jestem tuuuu");
                            BS.Podmien (dane, podmieniony);
                            Put_Line
                               (" SORTOWNIK OBIEKTOW PODMIENIA ELEMENT NA" &
                                dane'Img);
-- jeśli podmiana się nie udała to poczekaj kiedy zwolni się miejsce w buforze
                            if not podmieniony then
                                Put_Line (" SORTOWNIK NIE PODMIENIŁ ");
                                BS.Wstaw (dane, ilosc_sort);
                                Put_Line ("OBIEKT WRÓCIŁ DO SORTOWNIKA");
                                -- TODO być może nie potrzebne ze względu na guarda                                 # # # #
                                --while BOs(dane).Pelny loop
                                --    delay 0.01;
                                --end loop;
                                -- doczekał się więc wrzuca
                                --BOs(dane).Wstaw(dane, ilosc_elem);
                                --numer_obiektu := numer_obiektu +1;
                                --Put_Line(numer_obiektu'Img & " <--- NUMER OBIEKTU POSŁANEGO DO ODPOWIEDNIEGO POJEMNIKA | " & dane'Img &" <--- JEGO TYP | " & ilosc_elem'Img & "<--- ILOSC ELEM ");
                            else
                                if not BOs (dane).Pelny then
                                    BOs (dane).Wstaw (dane, ilosc_elem);
                                    numer_obiektu := numer_obiektu + 1;
                                    Put_Line
                                       (numer_obiektu'Img &
                                        " <--- NUMER OBIEKTU PODMIENIONEGO POSŁANEGO DO ODPOWIEDNIEGO POJEMNIKA | " &
                                        dane'Img & " <--- JEGO TYP " &
                                        ilosc_elem'Img & "<--- ILOSC ELEM ");
                                    podmieniony := False;
                                else
                                    Put_Line
                                       (" SORTOWNIK PODMIENIŁ, ALE CZEKA NA WOLNE MIEJSCE ");
                                    while BOs (dane).Pelny loop
                                        delay 0.01;
                                    end loop;
                                    -- doczekał się więc wrzuca
                                    BOs (dane).Wstaw (dane, ilosc_elem);
                                    podmieniony   := False;
                                    numer_obiektu := numer_obiektu + 1;
                                    Put_Line
                                       (numer_obiektu'Img &
                                        " <--- NUMER OBIEKTU PODMIENIONEGO POSŁANEGO DO ODPOWIEDNIEGO POJEMNIKA | " &
                                        dane'Img & " <--- JEGO TYP " &
                                        ilosc_elem'Img & "<--- ILOSC ELEM ");
                                end if;
                            end if;
                        else
                            BOs (dane).Wstaw (dane, ilosc_elem);
                            numer_obiektu := numer_obiektu + 1;
                            Put_Line
                               (numer_obiektu'Img &
                                " <--- NUMER OBIEKTU POSŁANEGO DO ODPOWIEDNIEGO POJEMNIKA | " &
                                dane'Img & " <--- JEGO TYP " & ilosc_elem'Img &
                                "<--- ILOSC ELEM ");
                        end if;
                        -- numer obiektu plus wyświetlanie a nawet wstawianie można przenieść poza IF
                        --BOs (dane).Poka (s);
                        --Put_Line("BOs(" & dane'Img & ")=" & s);
                        Put_Line("BOs(" & dane'Img & ")=" & BOs (dane).Poka);
                        
                    end if;
                end if;
            end select;
        end loop;
        Put_Line (" SORTOWNIK OBIEKTOW KONCZY PRACE");
        B.Stop;
    end SortownikObiektow;

    -- PRZEMIENIĆ NA PAKIET GENERYCZNY O WEJŚCIACH NAZWA I TYP
    task body PakerObiektu is
        nazwa : String  := "BLANK";
        typ   : Obiekt;
        dane  : Obiekt;
        pauza : Boolean := False;
    begin
        accept Start (typO : in Obiekt; nazwaO : in String) do
            typ   := typO;
            nazwa := nazwaO;
        end Start;
        Put_Line
           (" PAKER OBIEKTU " & nazwa & " DLA " & typ'Img &
            " ROZPOCZYNA PRACE");
        loop
            select
                accept Stop;
                exit;
            or
                -- TODO jaktechnika powyżej działa to zmień                                                 # # # #
                accept Wstrzymaj do
                    Put_Line ("------ PAKER " & nazwa & " MA PRZERWĘ ------");
                    pauza := True;
                end Wstrzymaj;
                -- while True loop
            or
                accept Wznow do
                    Put_Line ("------ PAKER " & nazwa & " WRÓCIŁ ------");
                    pauza := False;
                end Wznow;
                --     exit;
                -- end loop;

            else
                if not pauza then
                -- sprawdzaj czy bufor nie jest pusty, jeśli nie jest pobierz
                    if not BOs (typ).Pusty then
                        BOs (typ).Pobierz (dane);
                        Put_Line
                           (" PAKER OBIEKTU " & nazwa & " SPAKOWAŁ " &
                            dane'Img);

                    end if;
                end if;
            end select;
        end loop;
        Put_Line
           (" PAKER OBIEKTU " & nazwa & " dla " & typ'Img & " KONCZY PRACE");
    end PakerObiektu;

    -- task bezpieczeństwo implementacja
    task body Bezpieczenstwo is
    begin
        accept Start;
        Put_Line (" STEROWNIK BEZPIECZENSTWA ROZPOCZAL DZIALANIE");
        loop
            select
                accept Stop;
                --Put_Line("ZATRZYMANIE LINI");
                --T.Stop;
                --for S of Ss loop
                --    S.Stop;
                --end loop;
                --for P of Ps loop
                --    P.Stop;
                --end loop;
                exit;
            or
                accept Sygnalizuj;
                Put_Line ("E-STOP");
                T.Wstrzymaj;
                for S of Ss loop
                    S.Wstrzymaj;
                end loop;
                -- for P of Ps loop
                --     P.Wstrzymaj;
                -- end loop;

                delay 5.0;
                Put_Line ("KONIEC E-STOP");
                T.Wznow;
                for S of Ss loop
                    S.Wznow;
                end loop;

                -- for P of Ps loop
                --     P.Wznow;
                -- end loop;
            end select;
        end loop;
        Put_Line (" STEROWNIK BEZPIECZENSTWA ZAKONCZYL DZIALANIE");
        Put_Line
           ("***** SYMULATOR SORTOWANIA I PAKOWANIA BEZPIECZNIE ZAKOŃCZYŁ DZIAŁANIE *****");
    end Bezpieczenstwo;

begin
    Put_Line ("***** SYMULATOR SORTOWANIA I PAKOWANIA *****");
    -- startowanie sterownika bezpieczeństwa
    B.Start;
    -- startowanie i inicjacja pakerów
    for indeks in Ps'Range loop
        -- Put_Line(Obiekt'Val(indeks mod iloscTypow)'Img & " " & indeks'Img);
        Ps (indeks).Start
           (Obiekt'Val (indeks mod iloscTypow), "Pkr" & indeks'Img);
    end loop;
    --startowanie sortowników
    for S of Ss loop
        S.Start;
    end loop;
    -- startowanie taśmociągu
    delay 0.01;
    T.Start (50);
    -- test bezpieczeństwa
    delay 2.0;

    Przerwa_Pakerow_typu1 :
    for I in Ps'Range loop
        if (True) then
            Ps (I).Wstrzymaj;
        end if;
    end loop Przerwa_Pakerow_typu1;

    delay 25.0;

    Powrot_Pakerow_typu1 :
    for I in Ps'Range loop
        if (True) then
            Ps (I).Wznow;
        end if;
    end loop Powrot_Pakerow_typu1;

    B.Sygnalizuj;

end kontrolerobiektu;
