generic 
    N: Natural; --liczba typu integer w przedziale 0..Ostatnia_wartość_integer 
    type TypElementu is digits <>; -- dowolny typ zmiennoprzecinkowy
package bufor is
	type TypBufora is array(Integer range 1..N) of TypElementu; --tworzymy bufor(tablicę) długości N i zdefiniowanym wyżej typie elementów

	protected BuforN is
		entry Wstaw(X: in TypElementu);
		entry Pobierz(X: out TypElementu);
			function IlePobranych return Integer;
			function IleWstawionych return Integer;
		private 
			Bufor: TypBufora; -- nasz bufer - tablica(realizująca funkcję stosu)
			LiczbaWstawionych: Integer := 0;--liczba ogółem wstawionych do bufora elementów
			LiczbaPobranych: Integer := 0; --liczba ogółem pobranych z bufora elementów
			Index: Integer := 0; --indeks w tablicy (do elementu na wierzchu stosu), jesli == 0, to oznacza ze bufor jest pusty
			
	end BuforN;
end bufor;
