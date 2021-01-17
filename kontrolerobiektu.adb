-- kontrolerobiektu.adb

with Ada.Text_IO, Ada.Numerics.Float_Random, Ada.Numerics
   .Discrete_Random, bufor;
use Ada.Text_IO, Ada.Numerics.Float_Random;

procedure kontrolerobiektu is
    -- typ danych określający sortowane obiekty
    type Obiekt is (typ1, typ2, typ3);
    iloscTypow : constant Integer := 3;
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
        entry Start (typO : in Obiekt; nazwaO : in String; numerO : in integer);
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end PakerObiektu;

    -- task bezpieczeństwa definicja
    task type Bezpieczenstwo is
        entry Start;
        entry Sygnalizuj;
        entry Wznow;
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
    Ss : array (Integer range 0 .. 2) of SortownikObiektow;
    -- tworzenie pakerów (nie zainicjowanych!)
    Ps : array (Integer range 0 .. 8) of PakerObiektu;
    -- tworzenie tablicy zmiennych informujących czy dany paker jest w pracy
    PsON : array (Ps'range) of Boolean := ( others => False);
    -- tworzenie sterownika bezpieczeństwa
    B : Bezpieczenstwo;
    -- zmienna bezpiecznego działania procesu
    on : Boolean := False;

    -- task taśmociągu / generatora implementacja
    task body TasmociagObiektow is
        G                : LosObiekt.Generator;
        L                : Integer;
        pauza            : Boolean := False;
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
            or
                accept Wznow do
                    Put_Line ("TASMOCIAG WZNOWIONY");
                    pauza := False;
                end Wznow;
            else
                if not pauza then
                    if not BS.Pelny then
                        dane := LosObiekt.Random (G);
                        --Put_Line
                        --   (" TASMOCIAG UMIESCZCZA DANE TYPU »" & dane'Img &
                        --    "« DO BUFORA SORTOWNIKA");
                        BS.Wstaw (dane);--, IloscWSortowniku);
                        Put_Line(" (" & L'Img &" ) TASMOCIAG WSTAWIA " & dane'Img & " DO BS()=" & BS.Poka);
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
            or
                accept Wznow do
                    Put_Line ("SORTOWNIK WZNOWIONY");
                    pauza := False;
                end Wznow;

            else
                if not pauza then
                    -- pobierz nową próbkę jeśli nie nastąpiła podmiana
                    if not BS.Pusty then
                        delay 0.1;
                        BS.Pobierz (dane);
                        Put_Line(" SORTOWNIK POBRAŁ " & dane'Img & " Z BS()=" & BS.Poka);
                        -- jeśli nie ma miejsca dla danego elementu to spróbuj go podmienić na inny
                        if BOs (dane).Pelny then
                            Put_Line(" BUFOR POBRANEGO PRZEZ SORTOWNIK OBIEKTU JEST PRZEPEŁNIONY, PODMIENIAM...");
                            BS.Podmien (dane, podmieniony);
-- jeśli podmiana się nie udała to poczekaj kiedy zwolni się miejsce w buforze
                            if not podmieniony then
                                Put_Line(" SORTOWNIK NIE PODMIENIŁ WIEC CZEKA NA MIEJSCE");
                                while BOs(dane).Pelny loop
                                    delay 0.01;
                                end loop;
                            else
                                Put_Line(" SORTOWNIK PODMIENIŁ ELEMENT NA " & dane'Img);
                                if BOs (dane).Pelny then
                                    Put_Line(" SORTOWNIK PODMIENIŁ, ALE CZEKA NA WOLNE MIEJSCE ");
                                    while BOs (dane).Pelny loop
                                        delay 0.01;
                                    end loop;
                                end if;
                                podmieniony := False;
                            end if;
                        end if;
                        BOs (dane).Wstaw (dane);
                        Put_Line(" SORTOWNIK WSTAWIŁ " & dane'Img &" DO BOs(" & dane'Img & ")=" & BOs (dane).Poka);
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
        numer : Integer := 0;
        typ   : Obiekt;
        dane  : Obiekt;
        pauza : Boolean := False;
    begin
        accept Start (typO : in Obiekt; nazwaO : in String; numerO : in integer) do
            typ   := typO;
            nazwa := nazwaO;
            numer := numerO;
        end Start;
        Put_Line
           (" PAKER OBIEKTU " & nazwa & " DLA " & typ'Img &
            " ROZPOCZYNA PRACE");
        PsON(numer) := True;
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
            or
                accept Wznow do
                    Put_Line ("------ PAKER " & nazwa & " WRÓCIŁ ------");
                    pauza := False;
                end Wznow;
            else
                if not pauza then
                -- sprawdzaj czy bufor nie jest pusty, jeśli nie jest pobierz
                    if not BOs (typ).Pusty then
                        BOs (typ).Pobierz (dane);
                        Put_Line(" PAKER OBIEKTU " & nazwa & " SPAKOWAŁ " & dane'Img & "BOs(" & dane'Img & ")=" & BOs (typ).Poka);
                    end if;
                end if;
            end select;
        end loop;
        Put_Line(" PAKER OBIEKTU " & nazwa & " DLA " & typ'Img & " KONCZY PRACE");
        PsON(numer) := False;
    end PakerObiektu;

    -- task bezpieczeństwo implementacja
    task body Bezpieczenstwo is
        hlpr : Boolean := False;
    begin
        accept Start;
        Put_Line (" STEROWNIK BEZPIECZENSTWA ROZPOCZAL DZIALANIE");
        on := True;
        loop
            select
                accept Stop;
                exit;
            or
                accept Sygnalizuj;
                Put_Line ("POCZATEK E-STOP");
                T.Wstrzymaj;
                for S of Ss loop
                    S.Wstrzymaj;
                end loop;
            or
                accept Wznow;
                Put_Line ("KONIEC E-STOP");
                T.Wznow;
                for S of Ss loop
                    S.Wznow;
                end loop;
            else
                null;
            end select;
        end loop;
        Put_Line (" STEROWNIK BEZPIECZENSTWA OCZEKUJE NA ZAKONCZENIE PRACY NA HALI");
        Check_Workers: loop
            hlpr := True;
            for stan of PsON loop
                if stan then
                    hlpr := False;
                    exit;
                end if;
            end loop;
            exit Check_Workers when hlpr;
        end loop Check_Workers;
        Put_Line (" STEROWNIK BEZPIECZENSTWA ZAKONCZYL DZIALANIE");
        on := False;
    end Bezpieczenstwo;

begin
    Put_Line ("***** SYMULATOR SORTOWANIA I PAKOWANIA *****");
    -- startowanie sterownika bezpieczeństwa
    B.Start;
    while on /= True loop
        null;
    end loop;
    -- startowanie i inicjacja pakerów
    for indeks in Ps'Range loop
        Ps(indeks).Start(
            Obiekt'Val (indeks mod iloscTypow),
            "Pkr" & indeks'Img,
             indeks);
    end loop;
    --startowanie sortowników
    for S of Ss loop
        S.Start;
    end loop;
    -- startowanie taśmociągu
    delay 0.01;
    T.Start (20);
    -- test bezpieczeństwa
    delay 2.0;

    Przerwa_Pakerow_typu1 :
    for I in Ps'Range loop
        if (True) then
            Ps (I).Wstrzymaj;
        end if;
    end loop Przerwa_Pakerow_typu1;

    delay 5.0;

    Powrot_Pakerow_typu1 :
    for I in Ps'Range loop
        if (True) then
            Ps (I).Wznow;
        end if;
    end loop Powrot_Pakerow_typu1;

    B.Sygnalizuj;
    delay 1.0;
    B.Wznow;

    -- czekaj jak wszystkie maszyny przestaną działać i wyłączą moduł bezpieczeństwa
    while on = True loop
        null;
    end loop;
    
    Put_Line("***** SYMULATOR SORTOWANIA I PAKOWANIA BEZPIECZNIE ZAKOŃCZYŁ DZIAŁANIE *****");

end kontrolerobiektu;
