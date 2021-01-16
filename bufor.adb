with Ada.Strings.Unbounded;
use Ada.Strings.unbounded;
with Ada.Text_IO;
use Ada.Text_IO;

package body bufor is
    protected body BuforN is

        entry Wstaw (X : in TypElementu; IleWBuforze : out Integer)
           when (Ile < N)
        is -- jesli bufor nie jest pelny to rozpocznij wstawianie, jeśli jest to poczekaj
        begin
            Bufor (Integer (Ostatni)) := X; --wstawienie wartosci do bufora
            Ostatni := Ostatni + 1; --nowy indeks wierzchu stosu
            IleWBuforze               := Ile;
            --delay 0.5;
            --Put_Line("Liczba elementów w buforze: " & Index'Img); --aktualna liczba elementów w buforze
            --LiczbaWstawionych := LiczbaWstawionych+1;
        end Wstaw;

        entry Pobierz (X : out TypElementu) when (Ile > 0)
        is  -- jesli bufor nie jest pusty to rozpocznij pobieranie, jeśli jest to poczekaj
        begin
            X :=
               Bufor
                  (Integer (Pierwszy)); -- pobranie wartości z wierzchu stosu
            Pierwszy := Pierwszy + 1; -- uaktualnienie indeksu wierzchu stosu
            --Put_Line("Liczba elementów w buforze: " & Index'Img);
            --LiczbaPobranych := LiczbaPobranych + 1;
        end Pobierz;

        -- podmiana elementu jak w mechaniźmie karuzelowym przez co można pakować elementy innego typu bez potrzeby czekania
        entry Podmien (X : in out TypElementu; sukces : out Boolean)
           when (Ile > 0) is
            tmp : TypElementu;
        begin
            sukces := False;
            for indeks in Pierwszy .. Ostatni loop
                if Bufor (Integer (indeks)) /= X then
                    tmp                      := X;
                    X                        := Bufor (Integer (indeks));
                    Bufor (Integer (indeks)) := tmp;
                    sukces                   := True;
                    exit;
                end if;
            end loop;
        end Podmien;

        function Ile return Integer is (Integer (Ostatni - Pierwszy));

        function Pusty return Boolean is (Ile = 0);

        function Pelny return Boolean is (Ile = N - 1);

    end BuforN;

    -- testowy
    protected body BuforP is

        entry Wstaw (X : in TypElementu; IleWBuforze : out Integer)
           when (Ile < N)
        is -- jesli bufor nie jest pelny to rozpocznij wstawianie, jeśli jest to poczekaj
        begin
            Bufor (Integer (Ostatni)) := X; --wstawienie wartosci do bufora
            Ostatni := Ostatni + 1; --nowy indeks wierzchu stosu
            IleWBuforze               := Ile;
            --delay 0.05; -- jak nie ma tego delaya to sie nie zakancza jak powinno
            --Put_Line("Liczba elementów w buforze: " & Index'Img); --aktualna liczba elementów w buforze
            --LiczbaWstawionych := LiczbaWstawionych+1;
            --Put_Line(Obraz(X) & ">>" & Poka);
        end Wstaw;

        entry Pobierz (X : out TypElementu) when (Ile > 0)
        is  -- jesli bufor nie jest pusty to rozpocznij pobieranie, jeśli jest to poczekaj
        begin
            X :=
               Bufor
                  (Integer (Pierwszy)); -- pobranie wartości z wierzchu stosu
            Pierwszy := Pierwszy + 1; -- uaktualnienie indeksu wierzchu stosu
            --Put_Line("Liczba elementów w buforze: " & Index'Img);
            --LiczbaPobranych := LiczbaPobranych + 1;
            --delay 1.5;
            --Put_Line(Obraz(X) & "<<" & Poka);
        end Pobierz;

        -- podmiana elementu jak w mechaniźmie karuzelowym przez co można pakować elementy innego typu bez potrzeby czekania
        entry Podmien (X : in out TypElementu; sukces : out Boolean)
            when (Ile > 0) is
            indeks : indexerType := Pierwszy;
            tmp : TypElementu;
        begin
            sukces := False;
            --for indeks in Pierwszy .. Ostatni loop
            while indeks /= Ostatni loop
                if Bufor (Integer (indeks)) /= X then
                    tmp                      := X;
                    X                        := Bufor (Integer (indeks));
                    Bufor (Integer (indeks)) := tmp;
                    sukces                   := True;
                    exit;
                end if;
                indeks := indeks + 1;
            end loop;
        end Podmien;

        -- pokaż zawartość bufora
        function Poka return String is
            indeks : indexerType := Pierwszy;
        --entry Poka (s : out String) when Ile>0 is
            --tmp : String := " [ ";
            Temp_Unbounded_String : Unbounded_String;
        begin
        --    Put_Line("   >");
            Append(Temp_Unbounded_String, " [");
        --    for indeks in Pierwszy .. Ostatni loop
            while indeks /= Ostatni loop
                --tmp := tmp & Obraz(Bufor(Integer (indeks))) & " "; -- tutaj img nie działa ...
                Append(Temp_Unbounded_String, ' ');
                Append(Temp_Unbounded_String, Obraz(Bufor(Integer (indeks))));
                --Put("." & Obraz(Bufor(Integer (indeks))));
                indeks := indeks + 1;
            end loop;
            Append(Temp_Unbounded_String, " ] ");
        --    --s := To_String(Temp_Unbounded_String);
        --    Put_Line("<");
        --    return "ok";
            return To_String(Temp_Unbounded_String);
            --return tmp & "]";
            --return Ile'img;
        end;
        -- zwroc tablice 
--        function ZwrocCaly return TypBufora is
--            Objs : TypBufora;--array(Integer range 0..(Ile-1)) of TypElementu;
--            indeksWyjsciowy : Integer := 0;
--        begin
--            -- TODO zmienić typ pętli na iteracje po elementach
--            for indeks in Pierwszy .. Ostatni loop
--                Objs(indeksWyjsciowy) := (Bufor(Integer (indeks)));
--                indeksWyjsciowy := indeksWyjsciowy + 1;
--                --tmp := tmp & Obj'Val & " "; 
--            end loop;
--            return Objs;-- tmp & "]";
--        end;

        function Ile return Integer is (Integer (Ostatni - Pierwszy));

        function Pusty return Boolean is (Ile = 0);

        function Pelny return Boolean is (Ile = N - 1);

    end BuforP;
end bufor;
