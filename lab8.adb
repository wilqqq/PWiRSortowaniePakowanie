with Ada.Text_IO, Ada.Numerics.Float_Random, bufor;
use Ada.Text_IO, Ada.Numerics.Float_Random;

procedure lab8 is

package pBufor is new bufor(10,Float); -- definiujemy długość bufora i typ jego elementów

task type Producent is
	entry Start;
	entry Stop;
end Producent;

task Konsument is
	entry Start;
	entry Stop;
end Konsument;

task body Producent is
G: Generator; -- generator do generowania wartości typu float
Wartosc: Float;
begin
	accept Start;
	Put_Line("PRODUCENT ROZPOCZYNA PRODUKCJĘ");
	loop
		select
			accept Stop;
			Put_Line("PRODUCENT KOŃCZY PRODUKCJĘ");
			exit;
		else
			if(pBufor.BuforN.IleWstawionych > 20) then --zakonczenie dzialania jesli mielismy do wyprodukowania 20 wartosci i juz skonczylismy
				Put_Line("PRODUCENT KOŃCZY PRODUKCJĘ");
				exit;
			end if;
			--Put_Line("Pobrano juz: " & pBufor.BuforN.IlePobranych'Img);
			--Put_Line("Wstawiono juz: " & pBufor.BuforN.IleWstawionych'Img);
			Reset(G);
			Wartosc := Random(G); 
			pBufor.BuforN.Wstaw(Wartosc); -- polecenie wstawienia wylosowanej wartości do bufora, zadanie sie zawiesi dopóki nie zajdą warunki aby to się wykonało
			Put_Line("Wyprodukowałem " & Wartosc'Img); -- pokazanie wyprodukowanej wartosci którą już udało się wstawić
			delay 1.0;
		end select;
	end loop;
end Producent;

task body Konsument is
Wartosc: Float;
begin
	accept Start;
	Put_Line("KONSUMENT ROZPOCZYNA KONSUMPCJĘ");
	loop
		select
			accept Stop;
			Put_Line("KONSUMENT KOŃCZY KONSUMPCJĘ");
			exit;
		else
			if(pBufor.BuforN.IlePobranych > 20) then --zakonczenie dzialania jesli mielismy do skonsumowania 20 wartosci i juz skonczylismy
 				Put_Line("KONSUMENT KOŃCZY KONSUMPCJĘ");
				exit;
			end if;
			pBufor.BuforN.Pobierz(Wartosc);-- polecenie pobrania wartości z bufora, zadanie sie zawiesi dopóki nie zajdą warunki aby to się wykonało
			Put_Line("--Skonsumowałem: " & Wartosc'Img);-- pokazanie skonsumowanej już wartosci
			delay 1.0;
		end select;
	
	end loop;
end Konsument;

Producent1: Producent;

begin
--Konsument.Start; -- aby sprawdzic czy klient nie probuje pobrac z pustego bufora
--delay 3.0;
--Producent1.Start;
Producent1.Start;
delay 11.0; -- aby sprawdzic czy nie dochodzi do przepełnienia bufora
Konsument.Start;
end lab8;
