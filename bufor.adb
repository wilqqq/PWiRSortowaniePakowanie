with Ada.Text_IO;
use Ada.Text_IO;

package body bufor is
protected body BuforN is

	entry Wstaw(X: in TypElementu)
		when (Index <N)  is -- jesli bufor nie jest pelny to rozpocznij wstawianie, jeśli jest to poczekaj
	begin
		Index := Index +1; --nowy indeks wierzchu stosu
		Bufor(Index) := X; --wstawienie wartosci do bufora
		Put_Line("Liczba elementów w buforze: " & Index'Img); --aktualna liczba elementów w buforze
		LiczbaWstawionych := LiczbaWstawionych+1;		
	end Wstaw;
	
	entry Pobierz(X: out TypElementu)
		when (Index > 0) is  -- jesli bufor nie jest pusty to rozpocznij pobieranie, jeśli jest to poczekaj
	begin
		X := Bufor(Index); -- pobranie wartości z wierzchu stosu
		Index := Index - 1; -- uaktualnienie indeksu wierzchu stosu
		Put_Line("Liczba elementów w buforze: " & Index'Img);
		LiczbaPobranych := LiczbaPobranych + 1;
	end Pobierz;
	
	function IlePobranych return Integer is
	      begin
		 return LiczbaPobranych;
	end IlePobranych;

	function IleWstawionych return Integer is
	      begin
		 return LiczbaWstawionych;
	end IleWstawionych;
end BuforN;
end bufor;
