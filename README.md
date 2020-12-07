# PWiRSortowaniePakowanie
Projekt zaliczeniowy w ADA na programowanie współbierzne i rozproszone

> Taśmociąg - tworzy losowo pary obiektów z zadaną częstotliwością, przesyła wylosowane obiekty do sortownika, do momentu zakończenia pracy
> Sortownik - w zależności od typu obiektu przekazuje do odpowiedniego bufora
> Bufor1 - bufor, jeżeli się przepełni to wstrzyma pracę taśmociągu 
> Bufor2 - to samo tylko dla drugiego typu obiektu
> Paker1 - ściąga z taśmociągu i pakuje dany obiekt wolniej niż są one generowane
> Paker2 - to samo dla drugiego typu
> ESTOP - task zajmujący się awaryjnym zatrzymaniem taśmy (czujniczki guziczki)
> Główny kontroler - START, STOP ... obsługa aplikacji
