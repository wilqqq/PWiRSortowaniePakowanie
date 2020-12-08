-- kontroler.adb

with Ada.Text_IO, Ada.Numerics.Float_Random, bufor;
use Ada.Text_IO, Ada.Numerics.Float_Random;

procedure kontroler is
    package FloatBufor is new bufor(10, Float); 
    
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

    task body Tasmociag is
        G : Generator;
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
            end select;
        end loop;
    end Tasmociag;

    task body Sortownik is
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
                accept Przyjmij(dane : Float) do
                    Put_Line(" SORT przyjmuje");
                end Przyjmij;
            end select;
        end loop;
    end Sortownik;

    task body PakerA is
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
            end select;
        end loop;
    end Bezpieczenstwo;

    T : Tasmociag;
    S : Sortownik;
    PA : PakerA;
    PB : PakerB;
    B : Bezpieczenstwo;

begin
    Put_Line("SYMULATOR SORTOWANIA I PAKOWANIA");
   
end kontroler;