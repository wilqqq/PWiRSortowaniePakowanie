generic 
    type TypElementu is private; -- typ elementów, dla których będzie bufor
	with function Obraz (X : TypElementu) return String; --pomocnicza funkcja do tworzenia Stringa aby wyświetlić zawartość bufora 
package bufor is
    N: constant Natural := 3; -- rozmiar bufora
	type TypBufora is array(Integer range 0..(N-1)) of TypElementu; --tworzymy bufor(tablicę) długości N i zdefiniowanym wyżej typie elementów
	type indexerType is mod N; -- indeksery są typu modulo, potrzebne aby przeładowanie powodowało przeskok na początek kolejki
	protected type BuforP is
		entry Wstaw(X: in TypElementu);
		entry Pobierz(X: out TypElementu);
		entry Podmien(X : in out TypElementu; sukces : out Boolean);
		function Wyswietl return String;
		function Ile return Integer;
		function Pusty return Boolean;
		function Pelny return Boolean;
	private 
		Bufor: TypBufora; --nasz bufor - tablica(realizująca funkcję kolejki)
		Pierwszy: indexerType := 0; --indeks pierwszego elementu w kolejce
		Ostatni: indexerType := 0; --indeks ostatniego elementu w kolejce
	end BuforP;
end bufor;
