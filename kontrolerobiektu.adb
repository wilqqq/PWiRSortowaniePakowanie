-- kontrolerobiektu.adb

with Ada.Text_IO, Ada.Numerics.Float_Random, Ada.Numerics.Discrete_Random, bufor;
use Ada.Text_IO, Ada.Numerics.Float_Random;

procedure kontrolerobiektu is
    -- typ danych określający sortowane obiekty
    type Obiekt is (typ1, typ2);
    iloscTypow : Integer := 2;
    -- wersja z typem protected
    package LosObiekt is new Ada.Numerics.Discrete_Random(Obiekt);
    package BuforObjektow is new bufor(Obiekt);

    -- task taśmociągu / generatora obiektów definicja
    task type TasmociagObiektow is
        entry Start(liczbaObiektow : in Integer);
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
        entry Start(typO : in Obiekt; nazwaO : in String);
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
    
    -- bufory wyjściowe z sortownika
    BOs : array(Obiekt) of BuforObjektow.BuforP;
    -- bufor wejściowy sortownika
    BS : BuforObjektow.BuforP;
    -- tworzenie taśmociągu
    T : TasmociagObiektow;
    -- tworzenie sortowników
    Ss : array(Integer range 0..0) of SortownikObiektow;
    -- tworzenie pakerów (nie zainicjowanych!)
    Ps : array(Integer range 0..4) of PakerObiektu;
    -- tworzenie sterownika bezpieczeństwa
    B : Bezpieczenstwo;

    -- task taśmociągu / generatora implementacja
    task body TasmociagObiektow is
        G : LosObiekt.Generator;
        L : Integer := 30;
    begin
        accept Start(liczbaObiektow : in Integer) do
            L := liczbaObiektow;
        end Start;
        -- accept Start(L);
        loop
            select 
                accept Stop;
                Put_Line(" Tasmociag baj baj");
                exit;
            or
                -- TEST                                         # # # #
                accept Wstrzymaj;
                Put_Line("zatrzymuje T");
                while True loop
                    accept Wznow;
                    Put_Line("wznawiam T");
                    exit;
                end loop;
            else 
                --S.Przyjmij(Float(Random(G)*5.0));
                if not BS.Pelny then
                    Put_Line(" Tasmociag wstawia do bufora sortownika");
                    BS.Wstaw(LosObiekt.Random(G));
                    L := L - 1;
                    delay 0.1;
                end if;
                -- jak ujemne to generuje w nieskonczonosc
                exit when L = 0;
            end select;
        end loop;
        -- poniższy kod nie jest ssący! zamienić uśmiercanie na sprawdzanie czy tasmociag zyje i pusty buforS        # # # # # # # 
        -- poczekaj do opróżnienia buforu sortownika
        while not BS.Pusty loop
           null;
        end loop;
        -- uśmierć sortowniki
        for S of Ss loop
           S.Stop;
        end loop;
    end TasmociagObiektow;

    -- task sortownika implementacja
    task body SortownikObiektow is
        dane : Obiekt;
        podmieniony : Boolean := False;
    begin
        accept Start;
        Put_Line(" SORTOWNIK OBIEKTOW ROZPOCZYNA PRACE");
        loop
            select 
                accept Stop;
                exit;
            or
                -- TODO do stestowania czy ta metoda czekania działa                                        # # # #
                accept Wstrzymaj;
                while True loop
                    accept Wznow;
                    exit;
                end loop;
            else
                -- pobierz nową próbkę jeśli nie nastąpiła podmiana
                if not podmieniony and not BS.Pusty then
                    BS.Pobierz(dane);
                    Put_Line(" SORTOWNIK OBIEKTOW POBRAŁ " & dane'Img);
                end if;

                -- jeśli nie ma miejsca dla danego elementu to spróbuj go podmienić
                if BOs(dane).Pelny then
                    BS.Podmien(dane, podmieniony);
                    Put_Line(" SORTOWNIK OBIEKTOW PODMIENIA ELEMENT NA" & dane'Img);
                    -- jeśli podmiana się nie udała to poczekaj kiedy zwolni się miejsce w buforze
                    if not podmieniony then
                        Put_Line(" SORTOWNIK OBIEKTOW CZEKA NA WOLNE MIEJSCE ");
                        -- TODO być może nie potrzebne ze względu na guarda                                 # # # #
                        while BOs(dane).Pelny loop
                            delay 0.01;
                        end loop;
                        -- doczekał się więc wrzuca
                        BOs(dane).Wstaw(dane);    
                    end if;
                -- jeśli jest miejsce to wstaw element do buforu danego typu
                else
                    BOs(dane).Wstaw(dane);
                end if;
            end select;
        end loop;
        Put_Line(" SORTOWNIK OBIEKTOW KONCZY PRACE");
    end SortownikObiektow;

    -- PRZEMIENIĆ NA PAKIET GENERYCZNY O WEJŚCIACH NAZWA I TYP
    task body PakerObiektu is
        nazwa : String := "BLANK";
        typ : Obiekt;
        dane : Obiekt;
    begin
        accept Start(typO : in Obiekt; nazwaO : in String) do
            typ := typO;
            nazwa := nazwaO;
        end Start;
        Put_Line(" PAKER OBIEKTU " & nazwa & " dla " & typ'Img & " ROZPOCZYNA PRACE");
        loop
            select 
                accept Stop;
                exit;
            or
                -- TODO jaktechnika powyżej działa to zmień                                                 # # # # 
                accept Wstrzymaj;
                while True loop
                    accept Wznow;
                    exit;
                end loop;
            else
                -- sprawdzaj czy bufor nie jest pusty, jeśli nie jest pobierz
                if not BOs(typ).Pusty then
                    BOs(typ).Pobierz(dane);
                    Put_Line(" PAKER OBIEKTU " & nazwa & " pobrał " & dane'Img);
                    delay 1.0;
                end if;
            end select;
        end loop;
        Put_Line(" PAKER OBIEKTU " & nazwa & " dla " & typ'Img & " KONCZY PRACE");
    end PakerObiektu;

    -- task bezpieczeństwo implementacja
    task body Bezpieczenstwo is
    begin
        accept Start;
        loop
            select 
                accept Stop;
                Put_Line(" BEZP baj baj");
                exit;
            or
                accept Sygnalizuj;
                Put_Line("2s E-STOP");
                T.Wstrzymaj;
                for S of Ss loop
                    S.Wstrzymaj;
                end loop;
                for P of Ps loop
                    P.Wstrzymaj;
                end loop;
                delay 2.0;
                T.Wznow;
                for S of Ss loop
                    S.Wznow;
                end loop;
                for P of Ps loop
                    P.Wznow;
                end loop;
            end select;
        end loop;
    end Bezpieczenstwo;

begin
    Put_Line("SYMULATOR SORTOWANIA I PAKOWANIA");
    -- startowanie sterownika bezpieczeństwa
    B.Start;
    -- startowanie i inicjacja pakerów
    for indeks in Ps'range loop
        -- Put_Line(Obiekt'Val(indeks mod iloscTypow)'Img & " " & indeks'Img);
        Ps(indeks).Start(Obiekt'Val(indeks mod iloscTypow), "Pkr" & indeks'Img);
    end loop;
    --startowanie sortowników
    for S of Ss loop
        S.Start;
    end loop;
    -- startowanie taśmociągu
    T.Start(300);
    -- test bezpieczeństwa
    delay 2.0;
    B.Sygnalizuj;
end kontrolerobiektu;