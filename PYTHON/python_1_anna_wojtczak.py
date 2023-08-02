data = """
monday;1250
tuesday;1405
wednesday;1750
thursday;1100
friday;0800
saturday;1225
sunday;1355
"""

data = {
    'monday':1250,
    'tuesday':1405,
    'wednesday':1750,
    'thursday':1100,
    'friday':800,
    'saturday':1225,
    'sunday':1355
}

dni = list(data.keys()) #lista dni

wskazania = list(data.values()) #lista wskazań

# funkcja przeliczająca wskazania czujnika na temperaturę, zwraca wynik z dokładnością 
# do 3 miejsca po przecinku (zgodnie z tabelą przeliczania) pkt.3 i pkt.4
def przelicz(w):
    if w >= 1400:
        return round(int(w)/22.5,3)
    elif 1200 < w < 1400:
        return round(int(w)/23.1,3)
    else:
        return round(int(w)/23.5,3)


#funkcja dla wizualizacji temperatury
def wiz(t):
    a=round(t*20/100) #przeliczamy temperaturę na odpowiednią ilosc znakow '#' na pasku
    b=20-a #przeliczamy temeraturę na odpowiednią ilosc zmakow '-' na pasku
    wizualizacja = '0\u2103'+' '+'|'+'#'*a + '-'*b + '|'+' '+'100\u2103'
    return print(wizualizacja)


print('Wybierz dzień tygodnia, dla którego ma zostac wyliczony raport: \n'
'MO, TU, WE, TH, FR, SA, SU')

dzien = input()
skrot = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU','mo', 'tu', 'we', 'th', 'fr', 'sa', 'su']

if dzien in skrot and dzien =='MO' or dzien =='mo':
    print(f'Dane dla {dni[0]}:')
    print(f'Wskazanie czujnika: {data.get("monday")}')
    print(f'Temperatura {przelicz(data.get("monday"))} ' u"\u2103")
    wiz(przelicz(data.get("monday")))
elif dzien in skrot and dzien == 'TU' or dzien =='tu':
    print(f'Dane dla {dni[1]}:')
    print(f'Wskazanie czujnika: {data.get("tuesday")}')
    print(f'Temperatura {przelicz(data.get("tuesday"))} ' u"\u2103")
    wiz(przelicz(data.get("tuesday")))
elif dzien in skrot and dzien == 'WE' or dzien =='we':
    print(f'Dane dla {dni[2]}:')
    print(f'Wskazanie czujnika: {data.get("wednesday")}')
    print(f'Temperatura {przelicz(data.get("wednesday"))} ' u"\u2103")
    wiz(przelicz(data.get("wednesday")))
elif dzien in skrot and dzien == 'TH' or dzien =='th':
    print(f'Dane dla {dni[3]}:')
    print(f'Wskazanie czujnika: {data.get("thursday")}')
    print(f'Temperatura {przelicz(data.get("thursday"))} ' u"\u2103")
    wiz(przelicz(data.get("thursday")))
elif dzien in skrot and dzien == 'FR' or dzien =='fr':
    print(f'Dane dla {dni[4]}:')
    print(f'Wskazanie czujnika: {data.get("friday")}')
    print(f'Temperatura {przelicz(data.get("friday"))} ' u"\u2103")
    wiz(przelicz(data.get("friday")))
elif dzien in skrot and dzien =='SA' or dzien =='sa':
    print(f'Dane dla {dni[5]}:')
    print(f'Wskazanie czujnika: {data.get("saturday")}')
    print(f'Temperatura {przelicz(data.get("saturday"))} ' u"\u2103")
    wiz(przelicz(data.get("saturday")))
elif dzien in skrot and dzien == 'SU' or dzien =='su':
    print(f'Dane dla {dni[6]}:')
    print(f'Wskazanie czujnika: {data.get("sunday")}')
    print(f'Temperatura {przelicz(data.get("sunday"))} ' u"\u2103")
    wiz(przelicz(data.get("sunday")))
else:
    print('Wprowadzies bledny dzien tygodnia...')