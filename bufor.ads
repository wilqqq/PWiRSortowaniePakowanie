generic 
    --N: Natural; --liczba typu integer w przedziale 0..Ostatnia_wartość_integer 
    type TypElementu is private; -- dowolny typ 
	with function Obraz (X : TypElementu) return String;
package bufor is
    N: constant Natural := 10; -- rozmiar bufora
	type TypBufora is array(Integer range 0..(N-1)) of TypElementu; --tworzymy bufor(tablicę) długości N i zdefiniowanym wyżej typie elementów
	type indexerType is mod N; -- indeksery są typu modulo, żeby przeładowanie powodowało przeskok na początek kolejki
	protected type BuforP is
		entry Wstaw(X: in TypElementu);--; IleWBuforze: out Integer);
		entry Pobierz(X: out TypElementu);
		entry Podmien(X : in out TypElementu; sukces : out Boolean);
		function Poka return String;
		function Ile return Integer;
		function Pusty return Boolean;
		function Pelny return Boolean;
	private 
		Bufor: TypBufora; -- nasz bufor - tablica(realizująca funkcję kolejki)
		Pierwszy: indexerType := 0;
		Ostatni: indexerType := 0;
	end BuforP;
end bufor;
