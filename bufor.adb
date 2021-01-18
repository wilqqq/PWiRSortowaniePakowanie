with Ada.Strings.Unbounded;
use Ada.Strings.unbounded;
with Ada.Text_IO;
use Ada.Text_IO;

package body bufor is
    protected body BuforP is

        entry Wstaw (X : in TypElementu) --wejście do wstawiania elementow danego typu do bufora
           when (Ile < N)
        is -- jesli bufor nie jest pelny to rozpocznij wstawianie, jeśli jest to poczekaj
        begin
            Bufor (Integer (Ostatni)) := X; --wstawienie wartosci do bufora na indeks "Ostatni"
            Ostatni := Ostatni + 1; --uaktualnienie indeksu dla kolejnej wstawianej wartości
        end Wstaw;

        entry Pobierz (X : out TypElementu) when (Ile > 0)
        is  -- jesli bufor nie jest pusty to rozpocznij pobieranie, jeśli jest to poczekaj
        begin
            X := Bufor (Integer (Pierwszy)); -- pobranie wartości z indeksu "Pierwszy"
            Pierwszy := Pierwszy + 1; -- uaktualnienie indeksu kolejnego elementu do pobrania
        end Pobierz;
        -- podmiana elementu 
        --jak w mechaniźmie karuzelowym(w przypadku przepełnionego bufora Pakera 
        --tego elementu) przez co można pakować elementy innego typu bez potrzeby czekania
        entry Podmien (X : in out TypElementu; sukces : out Boolean)
            when (Ile > 0) is -- jesli bufor nie jest pusty to rozpocznij próbe podmienienia obiektu, jeśli jest to poczekaj
            indeks : indexerType := Pierwszy;
            tmp : TypElementu;
        begin
            sukces := False;
            --przeglądnij cały bufor w poszukiwaniu elementu innego typu, jeśli uda się podmienić ustaw zwracany sukces na True
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

        -- pokaż aktualną zawartość bufora
        function Wyswietl return String is
            indeks : indexerType := Pierwszy;
            Temp_Unbounded_String : Unbounded_String;
        begin
            Append(Temp_Unbounded_String, " [");
            while indeks /= Ostatni loop -- dodaj wszystkie elementy bufora do naszego Stringa
                Append(Temp_Unbounded_String, ' ');
                Append(Temp_Unbounded_String, Obraz(Bufor(Integer (indeks))));
                indeks := indeks + 1;
            end loop;
            Append(Temp_Unbounded_String, " ] ");
            return To_String(Temp_Unbounded_String);
        end;

        --pomocnicze funkcje zwracające informacje na temat bufora:

        --ilość elementów w buforze
        function Ile return Integer is (Integer (Ostatni - Pierwszy));

        --czy bufor pusty lub pełny
        function Pusty return Boolean is (Ile = 0);

        function Pelny return Boolean is (Ile = N - 1);

    end BuforP;
end bufor;
