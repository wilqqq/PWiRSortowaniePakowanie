# PWiRSortowaniePakowanie
Projekt zaliczeniowy w ADA na programowanie współbieżne i rozproszone

Celem naszego projektu jest symulowanie elementu linii produkcyjnej
mającego za zadanie odbiór oraz rozdysponowanie różnego typu produktów
do odpowiednich dyspenserów.

Występujące elementy logiczne procesu to:
    a. taśmociąg, będący źródłem elementów w losowej kolejności,
    b. bufor wejściowy, skąd sortownik pobiera elementy
    c. sortownik, który przekazuje elementy w dół linii do odpowiednich
    buforów
    d. bufory wyjściowe, czyli pojemniki zawierające elementy jednego typu
    e. pakerzy, czyli pracownicy fabryki lub maszyny odpowiedzialni za
    pakowanie konkretnego typu obiektów

Dodatkowo nad całym procesem czuwa moduł bezpieczeństwa, do którego
podłączone są czujniki mające za zadanie wstrzymanie linii, w wypadku
zajścia mogącego potencjalnie prowadzić do wypadku, natomiast po
zażegnaniu niebezpieczeństwa, wznowić jej działanie. Ponadto wstrzymuje
on całkowite wyłączenie hali dopóki występują na niej pracujący robotnicy.