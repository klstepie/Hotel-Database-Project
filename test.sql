
exec p_DodajPracownika @Id_Pracownik = 8,
@Imie = 'Marian', 
@Nazwisko = 'Oleksy',
@Stanowisko = 'Recepcjonista/ka' , 
@Ulica ='ul. Koœciuszki 21', 
@Miasto= 'Nowy Targ', 
@KodPocztowy='11-111', 
@Kraj='Polska',
@NumerTelefonu='982664123', 
@PESEL='76312312312';


select * from Pracownicy

exec sp_helpconstraint pracownicy





exec p_AwansujPracownika @Id_pracownik = 8, 
@Stanowisko = 'Kierownik recepcji'




exec p_ZwolnijPracownika @Id_pracownik = 8






DELETE FROM Pracownicy
where ID_Pracownik = 8

select * from Pracownicy