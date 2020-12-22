-- kontroler.adb

with Ada.Text_IO, Ada.Numerics.Float_Random, bufor;
use Ada.Text_IO, Ada.Numerics.Float_Random;

procedure kontroler is
    -- typ danych określający sortowane obiekty
    type Obiekt is (typ1, typ2);

    package BuforA is new bufor(Float);
    package BuforB is new bufor(Float);
    package BuforS is new bufor(Float);

    -- -- wersja z typem protected
    -- package BuforObjektow is new bufor(Obiekt);
    -- BuforA : BuforObjektow.BuforN;
    
    task type Tasmociag is
        entry Start;
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end Tasmociag;

    task type Sortownik is
        entry Start;
        entry Przyjmij(dane : in Float);
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end Sortownik;

    task type PakerA is
        entry Start;
        entry Przyjmij(dane : in Float);
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end PakerA;

    task type PakerB is
        entry Start;
        entry Przyjmij(dane : in Float);
        entry Wstrzymaj;
        entry Wznow;
        entry Stop;
    end PakerB;

    task type Bezpieczenstwo is
        entry Start;
        entry Sygnalizuj;
        entry Stop;
    end Bezpieczenstwo;

    T : Tasmociag;
    S : Sortownik;
    PA : PakerA;
    PB : PakerB;
    P : array(Obiekt) of PakerA; -- tak można stworzyć kilka odbiorników
    B : Bezpieczenstwo;

    task body Tasmociag is
        G : Generator;
        L : Integer := 30;
    begin
        accept Start;
        loop
            select 
                accept Stop;
                Put_Line(" Tasmociag baj baj");
                exit;
            or
                accept Wstrzymaj;
                while True loop
                    accept Wznow;
                    exit;
                end loop;
            else 
                --S.Przyjmij(Float(Random(G)*5.0));
                if not BuforS.BuforN.Pelny then
                    Put_Line(" Tasmociag wstawia do bufora sortownika");
                    BuforS.BuforN.Wstaw(Float(Random(G)*5.0));
                    L := L - 1;
                    delay 0.1;
                end if;

                exit when L <= 0;
            end select;
        end loop;
        -- poniższy kod nie jest ssący! zamienić uśmiercanie na sprawdzanie czy tasmociag zyje i pusty buforS        # # # # # # # 
        -- poczekaj do opróżnienia buforu sortownika
        while not BuforS.BuforN.Pusty loop
           null;
        end loop;
         -- uśmierć sortownik
         S.Stop;
    end Tasmociag;

    task body Sortownik is
        dane : Float;
        podmieniony : Boolean := True;
    begin
        accept Start;
        loop
            select 
                accept Stop;
                Put_Line(" SORT baj baj");
                exit;
            or
                accept Wstrzymaj;
                while True loop
                    accept Wznow;
                    exit;
                end loop;
            or
                -- STARE
                accept Przyjmij(dane : Float) do
                    Put_Line(" SORT przyjmuje " & dane'Img);
                    if dane > 0.0 then
                        -- wstaw na bufor a jeśli ten niepełny
                        -- jeśli pełny wstaw do wewnętrzzego bufora? 
                        --PA.Przyjmij(dane);
                        if not BuforA.BuforN.Pelny then
                            Put_Line(" SORT przekazuje do PAKA ");
                            BuforA.BuforN.Wstaw(dane);
                        end if;
                    --else
                        --PB.Przyjmij(dane);
                    end if;
                end Przyjmij;
            else
                -- pobierz nową próbkę jeśli nie nastąpiła podmiana
                if not BuforS.BuforN.Pusty then
                    BuforS.BuforN.Pobierz(dane);
                -- end if;
                
                    -- tutaj następuje sortowanie 
                    Put_Line(" SORT przyjmuje " & dane'Img);
                    -- #TODO tylko sortownik może ściągnąć z tego bufora (blokować taśmociąg jeśli jest prawie pełny) 
                    if dane > 0.0 then
                        if not BuforA.BuforN.Pelny then --jeśli bufor A może przyjmować wyślij
                            Put_Line(" SORT przekazuje do PAKA ");
                            BuforA.BuforN.Wstaw(dane);
                        elsif not BuforS.BuforN.Pelny then -- jeśli bufor A pełny a S ma miejsce - odstaw na koniec i pobierz kolejny 
                            BuforS.BuforN.Wstaw(dane);
                        else 
                            BuforS.BuforN.Podmien (dane, podmieniony);
                            if not podmieniony then
                                -- jeśli bufor S ani A nie mają miejsca - czekaj aż A się zwolni
                                while BuforA.BuforN.Pelny loop
                                    null;
                                end loop;
                                BuforA.BuforN.Wstaw(dane);
                            end if;
                        end if;
                    --else
                        --PB.Przyjmij(dane);
                    end if;
                end if;
            end select;
        end loop;
    end Sortownik;

    task body PakerA is
        dane : Float;
    begin
        accept Start;
        loop
            select 
                accept Stop;
                Put_Line(" PAKA baj baj");
                exit;
            or
                accept Wstrzymaj;
                while True loop
                    accept Wznow;
                    exit;
                end loop;
            or
                accept Przyjmij(dane : Float) do
                    Put_Line(" PAKA przyjmuje");
                end Przyjmij;
            else
                -- sprawdzaj czy bufor nie jest pusty, jeśli nie jest pobierz
                if not BuforA.BuforN.Pusty then
                    Put_Line(" PAKA pobiera z bufora");
                    BuforA.BuforN.Pobierz(dane);
                    Put_Line(" PakerA pobrał " & dane'Img);
                    delay 1.0;
                end if;
            end select;
        end loop;
    end PakerA;

    task body PakerB is
    begin
        accept Start;
        loop
            select 
                accept Stop;
                Put_Line(" PAKB baj baj");
                exit;
            or
                accept Wstrzymaj;
                while True loop
                    accept Wznow;
                    exit;
                end loop;
            or
                accept Przyjmij(dane : Float) do
                    Put_Line(" PAKB przyjmuje");
                end Przyjmij;
            end select;
        end loop;
    end PakerB;

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
                Put_Line("BEZP");
                T.Wstrzymaj;
                delay 2.0;
                T.Wznow;
            end select;
        end loop;
    end Bezpieczenstwo;

begin
    Put_Line("SYMULATOR SORTOWANIA I PAKOWANIA");
    B.Start;
    PB.Start;
    PA.Start;
    S.Start;
    T.Start;
    delay 2.0;
    B.Sygnalizuj;
end kontroler;