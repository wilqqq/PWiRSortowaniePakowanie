package body bufor is
	protected body BuforN is

		entry Wstaw(X: in TypElementu) when (Ile < N) is -- jesli bufor nie jest pelny to rozpocznij wstawianie, jeśli jest to poczekaj
		begin
			Bufor(Integer(Ostatni)) := X; --wstawienie wartosci do bufora
			Ostatni := Ostatni + 1; --nowy indeks wierzchu stosu
			--Put_Line("Liczba elementów w buforze: " & Index'Img); --aktualna liczba elementów w buforze
			--LiczbaWstawionych := LiczbaWstawionych+1;		
		end Wstaw;
		
		entry Pobierz(X: out TypElementu) when (Ile > 0) is  -- jesli bufor nie jest pusty to rozpocznij pobieranie, jeśli jest to poczekaj
		begin
			X := Bufor(Integer(Pierwszy)); -- pobranie wartości z wierzchu stosu
			Pierwszy := Pierwszy + 1; -- uaktualnienie indeksu wierzchu stosu
			--Put_Line("Liczba elementów w buforze: " & Index'Img);
			--LiczbaPobranych := LiczbaPobranych + 1;
		end Pobierz;

		-- podmiana elementu jak w mechaniźmie karuzelowym przez co można pakować elementy innego typu bez potrzeby czekania
		entry Podmien(X: in out TypElementu; sukces : out Boolean) when (Ile > 0) is
			tmp : TypElementu;
		begin
			sukces := False;
		    for indeks in Pierwszy..Ostatni loop
			    if Bufor(Integer(indeks)) /= X then
					tmp := X;
					X := Bufor(Integer(indeks));
					Bufor(Integer(indeks)) := tmp;
					sukces := True;
					exit;
			    end if;
			end loop;
		end Podmien;

		function Ile return Integer is
			(Integer(Ostatni - Pierwszy));

		function Pusty return Boolean is
			(Ile = 0);

		function Pelny return Boolean is
			(Ile = N-1);
			
	end BuforN;

	-- testowy
	protected body BuforP is

		entry Wstaw(X: in TypElementu) when (Ile < N) is -- jesli bufor nie jest pelny to rozpocznij wstawianie, jeśli jest to poczekaj
		begin
			Bufor(Integer(Ostatni)) := X; --wstawienie wartosci do bufora
			Ostatni := Ostatni + 1; --nowy indeks wierzchu stosu
			--Put_Line("Liczba elementów w buforze: " & Index'Img); --aktualna liczba elementów w buforze
			--LiczbaWstawionych := LiczbaWstawionych+1;		
		end Wstaw;
		
		entry Pobierz(X: out TypElementu) when (Ile > 0) is  -- jesli bufor nie jest pusty to rozpocznij pobieranie, jeśli jest to poczekaj
		begin
			X := Bufor(Integer(Pierwszy)); -- pobranie wartości z wierzchu stosu
			Pierwszy := Pierwszy + 1; -- uaktualnienie indeksu wierzchu stosu
			--Put_Line("Liczba elementów w buforze: " & Index'Img);
			--LiczbaPobranych := LiczbaPobranych + 1;
		end Pobierz;

		-- podmiana elementu jak w mechaniźmie karuzelowym przez co można pakować elementy innego typu bez potrzeby czekania
		entry Podmien(X: in out TypElementu; sukces : out Boolean) when (Ile > 0) is
			tmp : TypElementu;
		begin
			sukces := False;
		    for indeks in Pierwszy..Ostatni loop
			    if Bufor(Integer(indeks)) /= X then
					tmp := X;
					X := Bufor(Integer(indeks));
					Bufor(Integer(indeks)) := tmp;
					sukces := True;
					exit;
			    end if;
			end loop;
		end Podmien;

		function Ile return Integer is
			(Integer(Ostatni - Pierwszy));

		function Pusty return Boolean is
			(Ile = 0);

		function Pelny return Boolean is
			(Ile = N-1);
			
	end BuforP;
end bufor;
