--Zapytanie 1-- 
SELECT 
    UPPER(nazwisko) AS Nazwisko_Duze,
    LOWER(imie) AS Imie_Male,
    CONCAT(SUBSTRING(imie, 1, 1), '. ', nazwisko) AS Inicjal_Nazwisko,
    LEN(email) AS Dlugosc_Emaila,
    CASE 
        WHEN email LIKE '%gmail.com' THEN 'Google'
        WHEN email LIKE '%yahoo.com' THEN 'Yahoo'
        ELSE 'Inny' 
    END AS Dostawca_Poczty
FROM Klienci
WHERE telefon IS NOT NULL;


--Zapytanie 2--
SELECT 
    id_zamowienia,
    data_zamowienia,
    FORMAT(data_zamowienia, 'dd.MM.yyyy') AS Data_Polska,
    DATENAME(month, data_zamowienia) AS Nazwa_Miesiaca,
    DATEPART(hour, data_zamowienia) AS Godzina_Zakupu
FROM Zamowienia
WHERE data_zamowienia BETWEEN '2023-01-01' AND '2025-12-31';


--Zapytanie 3--
SELECT 
    nazwa,
    REPLACE(nazwa, ' ', '_') AS Nazwa_URL,
    cena_bazowa
FROM Produkty
WHERE nazwa LIKE '%Koszulka%' OR nazwa LIKE '%Buty%';


--Zapytanie 4--
SELECT 
    k.nazwa AS Kategoria,
    COUNT(p.id_produktu) AS Liczba_Produktow,
    SUM(pz.ilosc * pz.cena_w_chwili_zakupu) AS Utarg_Calkowity
FROM Kategorie k
JOIN Produkty p ON k.id_kategorii = p.id_kategorii
JOIN Warianty_Produktow w ON p.id_produktu = w.id_produktu
JOIN Pozycje_Zamowienia pz ON w.id_wariantu = pz.id_wariantu
GROUP BY k.nazwa
ORDER BY Utarg_Calkowity DESC;


--Zapytanie 5--
SELECT TOP 5
    k.imie,
    k.nazwisko,
    COUNT(z.id_zamowienia) AS Liczba_Zamowien,
    SUM(z.wartosc_calkowita) AS Suma_Wydatkow
FROM Klienci k
JOIN Zamowienia z ON k.id_klienta = z.id_klienta
GROUP BY k.imie, k.nazwisko
ORDER BY Suma_Wydatkow DESC;


--Zapytanie 6
SELECT 
    m.nazwa AS Marka,
    SUM(pz.ilosc) AS Sprzedane_Sztuki
FROM Marki m
JOIN Produkty p ON m.id_marki = p.id_marki
JOIN Warianty_Produktow w ON p.id_produktu = w.id_produktu
JOIN Pozycje_Zamowienia pz ON w.id_wariantu = pz.id_wariantu
GROUP BY m.nazwa
HAVING SUM(pz.ilosc) > 10;


--Zapytanie 7--
SELECT 
    k.imie,
    k.nazwisko,
    k.email
FROM Klienci k
LEFT JOIN Zamowienia z ON k.id_klienta = z.id_klienta
WHERE z.id_zamowienia IS NULL;


--Zapytanie 8
SELECT 
    p.nazwa,
    p.cena_bazowa
FROM Produkty p
LEFT JOIN Zdjecia_Produktow zdj ON p.id_produktu = zdj.id_produktu
WHERE zdj.id_zdjecia IS NULL;


--Zapytanie 9
SELECT nazwa AS Nazwa_Podmiotu, 'Marka' AS Typ FROM Marki
UNION
SELECT CONCAT(imie, ' ', nazwisko), 'Klient' FROM Klienci;


--Zapytanie 10
SELECT 
    nazwa,
    cena_bazowa,
    (SELECT AVG(cena_bazowa) FROM Produkty) AS Srednia_Cena_Sklepu,
    cena_bazowa - (SELECT AVG(cena_bazowa) FROM Produkty) AS Roznica
FROM Produkty;


--Zapytanie 11
SELECT 
    p.nazwa,
    (SELECT COUNT(*) FROM Warianty_Produktow w WHERE w.id_produktu = p.id_produktu) AS Liczba_Wariantow
FROM Produkty p;


--Zapytanie 12
SELECT 
    id_zamowienia,
    wartosc_calkowita,
    (SELECT MAX(wartosc_calkowita) FROM Zamowienia) AS Najwyzsze_Zamowienie_W_Historii
FROM Zamowienia;


--Zapytanie 13
SELECT 
    id_zamowienia,
    id_klienta,
    data_zamowienia,
    wartosc_calkowita,
    ROW_NUMBER() OVER(PARTITION BY id_klienta ORDER BY data_zamowienia DESC) AS Nr_Zamowienia_Klienta
FROM Zamowienia;


--Zapytanie 14 
SELECT 
    id_zamowienia,
    data_zamowienia,
    wartosc_calkowita,
    SUM(wartosc_calkowita) OVER(ORDER BY data_zamowienia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Sprzedaz_Narastajaco
FROM Zamowienia;


--Zapytanie 15
SELECT * FROM (
    SELECT 
        s.nazwa AS Status_Zamowienia,
        z.id_zamowienia
    FROM Zamowienia z
    JOIN Statusy_Zamowien s ON z.id_statusu = s.id_statusu
) AS SourceTable
PIVOT (
    COUNT(id_zamowienia)
    FOR Status_Zamowienia IN ([Nowe], [Opłacone], [Wysłane], [Dostarczone], [Zwrócone])
) AS PivotTable;


--Zapytanie 16
WITH WartosciKoszyka AS (
    SELECT id_klienta, SUM(wartosc_calkowita) as Suma
    FROM Zamowienia
    GROUP BY id_klienta
)
SELECT AVG(Suma) AS Srednia_Wartosc_Zyciowa_Klienta
FROM WartosciKoszyka;


--Zapytanie 17 
SELECT * FROM Zamowienia
WHERE id_zamowienia IN (
    SELECT pz.id_zamowienia 
    FROM Pozycje_Zamowienia pz
    JOIN Warianty_Produktow w ON pz.id_wariantu = w.id_wariantu
    JOIN Produkty p ON w.id_produktu = p.id_produktu
    JOIN Marki m ON p.id_marki = m.id_marki
    WHERE m.nazwa = 'Nike'
);


--Zapytanie 18 
SELECT imie, nazwisko 
FROM Klienci k
WHERE EXISTS (
    SELECT 1 
    FROM Zamowienia z 
    JOIN Zwroty zw ON z.id_zamowienia = zw.id_zamowienia
    WHERE z.id_klienta = k.id_klienta
);


--Zapytanie 19 
SELECT nazwa, cena_bazowa, id_kategorii
FROM Produkty p1
WHERE cena_bazowa > (
    SELECT AVG(cena_bazowa) 
    FROM Produkty p2 
    WHERE p2.id_kategorii = p1.id_kategorii
);


--Zapytanie 20
SELECT id_produktu, nazwa, cena_bazowa
FROM Produkty
ORDER BY cena_bazowa DESC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;	








