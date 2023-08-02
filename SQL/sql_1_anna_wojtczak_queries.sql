/*Treść zadania:
1. Wykonaj skrypt tworzący tabele i dodający do nich wartości – northwind_postgres.sql.*/

create database northwind_postgres

/*2. Wykonaj zapytania, które odpowiedzą na te pytania:*/

--a. Jakie są miasta, w których mieszka więcej niż 3 pracowników?
select e."City" , count(e."LastName") liczba_pracownikow_z_danego_miasta
from employees e 
group by e."City"  
having count(e."LastName")>3
order by liczba_pracownikow_z_danego_miasta

--b. Zakładając, że produkty, które kosztują (UnitPrice) mniej niż 10$ możemy uznać za tanie, 
--te między 10$ a 50$ za średnie, a te powyżej 50$ za drogie, ile produktów należy do poszczególnych przedziałów?

--ilosc produktow w poszegolnych przedziałach w podsumowaniu
select p."ProductID" , 
sum (case when p."UnitPrice" <10 then 1 else 0 end) tanie,
sum (case when p."UnitPrice" between 10 and 50 then 1 else 0 end) srednie,
sum (case when p."UnitPrice" >50 then 1 else 0 end) drogie 
from products p 
group by rollup (p."ProductID")
order by p."ProductID"  

--Czy najdroższy produkt z kategorii z największą średnią ceną to najdroższy produkt ogólnie?

--najdroższy produkt z kategorii z największą średnią ceną
select distinct p."CategoryID",
max (p."UnitPrice") over (partition by p."CategoryID") najdrozszy_produkt_z_danej_kategorii,
avg (p."UnitPrice") over (partition by p."CategoryID") srednia_cena_produktu_w_danej_kategorii
from products p 
order by srednia_cena_produktu_w_danej_kategorii desc

--najdroższy produkt ogólnie
select max(p."UnitPrice") from products p 

--d. Ile kosztuje najtańszy, najdroższy i ile średnio kosztuje produkt od każdego z dostawców? 
--UWAGA – te dane powinny być przedstawione z nazwami dostawców, nie ich identyfikatorami.

select distinct s."SupplierID" ,s."CompanyName" , 
min (p."UnitPrice") over (partition by p."SupplierID" order by p."SupplierID") cena_najtanszego_produktu_od_danego_sprzedawcy,
max (p."UnitPrice") over (partition by p."SupplierID" order by p."SupplierID") cena_najdrozszego_produku_od_danego_sprzedawcy,
avg (p."UnitPrice") over (partition by p."SupplierID" order by p."SupplierID") srednia_cena_produktow_od_danego_sprzedawcy
from products p 
join suppliers s on p."SupplierID" =s."SupplierID" 
order by s."SupplierID" 

--e. Jak się nazywają i jakie mają numery kontaktowe wszyscy dostawcy i klienci (ContactName) z Londynu? 
--Jeśli nie ma numeru telefonu, wyświetl faks.*/

select s."ContactName", s."Phone" , s."Fax",coalesce (nullif (s."Phone",''),s."Fax") as tel_fax, 'dostawca' as dostawca_czy_klient 
from suppliers s where s."City" ='London'
union
select c."ContactName", c."Phone" , c."Fax",coalesce (nullif(c."Phone",''), c."Fax") as tel_fax , 'klient' as dostawca_czy_klient 
from customers c where c."City" ='London'

--f. Które miejsce cenowo (od najtańszego) zajmują w swojej kategorii (CategoryID) wszystkie produkty?

select p."ProductID",p."UnitPrice" ,p."CategoryID" , c."CategoryName" ,
dense_rank () over (partition by p."CategoryID" order by p."UnitPrice")
from products p 
join categories c on c."CategoryID" =p."CategoryID" 

/*3. Wczytaj pliki Summary of Weather.csv i Weather Station Locations.csv. 
W przypadku problemów ze zrozumieniem danych spójrz tutaj: https://www.kaggle.com/smid80/weatherww2
4. Wykonaj zapytania, które odpowiedzą na te pytania:*/

--a.Jaka była i w jakim kraju miała miejsce najwyższa dzienna amplituda temperatury?

--mksymalna amplituda dla stopni Celcjusza
select distinct wsl."STATE/COUNTRY ID", 
max (sow.maxtemp-sow.mintemp) max_amplituda
from summary_of_weather sow 
full join weather_station_locations wsl on sow.sta = wsl.wban 
group by wsl."STATE/COUNTRY ID" 
having max (sow.maxtemp-sow.mintemp) is not null
order by max_amplituda desc

--maksymalna amplituda dla stopni Farenhajta
select distinct wsl."STATE/COUNTRY ID",
max (sow.max -sow.min) max_amplituda
from summary_of_weather sow 
full join weather_station_locations wsl on sow.sta = wsl.wban 
group by wsl."STATE/COUNTRY ID"
having max (sow.maxtemp-sow.mintemp) is not null
order by max_amplituda desc

--b. Z czym silniej skorelowana jest średnia dzienna temperatura dla stacji – szerokością (lattitude) czy długością (longtitude) geograficzną?

select 
corr(sow.mintemp,wsl.latitude) as korelacja_śr_tem_z_szerokoscia, 
corr(sow.mintemp,wsl.longitude) as korelacja_śr_tem_z_długoscia
from summary_of_weather sow 
join weather_station_locations wsl on sow.sta = wsl.wban 

--c. Pokaż obserwacje, w których suma opadów atmosferycznych (precipitation) przekroczyła sumę opadów z ostatnich 5 obserwacji na danej stacji.

/*dodanie kolomny rankujacej datę obserwacji dla kazdej stacji, przygotowanie danych dla zmiennej precipitation 
(założenie przyjęte dla wartosci 'T': If you must convert a trace to a numerical amount, it would equal 0)*/

create view v_summary_of_weather_opady_pozycja_obserwacji as 
select 
sow.sta , 
row_number () over (partition by sow.sta order by sow."Date" desc) as pozycja_obserwacji,
sow."Date" , 
sow.precip , 
(replace (sow.precip ,'T','0'))::numeric as opady 
from summary_of_weather sow 

--widok dla sumy opadow na danej stacji z 5 ostatnich obserwacji
create view v_5_ostatnich as
select sta, 
sum(opady) as suma_opadow_z_5_ostatnich_obserwaji_nadanej_stacji
from v_summary_of_weather_opady_pozycja_obserwacji
where pozycja_obserwacji between 1 and 5
group by sta
order by sta

--obserwacje, w których suma opadów atmosferycznych przekroczyła sumę opadów z ostatnich 5 obserwacji na danej stacji
select 
v_summary_of_weather_opady_pozycja_obserwacji."Date", 
v_summary_of_weather_opady_pozycja_obserwacji.sta, 
v_summary_of_weather_opady_pozycja_obserwacji.opady, 
sum(opady) suma_opadow, suma_opadow_z_5_ostatnich_obserwaji_nadanej_stacji
from v_summary_of_weather_opady_pozycja_obserwacji 
join v_5_ostatnich on v_5_ostatnich.sta= v_summary_of_weather_opady_pozycja_obserwacji.sta
group by v_summary_of_weather_opady_pozycja_obserwacji.sta, 
suma_opadow_z_5_ostatnich_obserwaji_nadanej_stacji, 
v_summary_of_weather_opady_pozycja_obserwacji."Date",
v_summary_of_weather_opady_pozycja_obserwacji.opady
having sum(opady)>suma_opadow_z_5_ostatnich_obserwaji_nadanej_stacji
order by v_summary_of_weather_opady_pozycja_obserwacji.sta




















