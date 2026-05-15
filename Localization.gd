
extends Node

var current_language := "ro"

var translations := {
	"ro": {
		"greeting": "Bună ziua!",
		"start_game": "Începe jocul",
		"settings": "Setări",
		"Enter your email": "Introduceți emailul dumneavoastră",
		"SAVE": "SALVEAZĂ",
		"START": "START",
		"info":"""La deschiderea jocului apar două butoane: START și ?. Butonul ? oferă informații despre modul de funcționare al jocului, iar butonul START pornește procesul de configurare.

Configurarea aplicației (setup)
Apăsând START, veți fi direcționat către Termenii și condițiile și Politica de confidențialitate ale jocului. Citiți-le cu atenție și bifați acordul pentru a continua.
În continuare, va trebui să introduceți adresa de email, necesară pentru a primi mesaje legate de progresul copilului și pentru validări viitoare. După introducerea emailului, veți primi un cod de confirmare pe acea adresă, pe care va trebui să îl introduceți pentru a continua.
Următorul pas este programarea activităților zilnice ale copilului, în format HH:MM. Activitățile care trebuie setate sunt: trezirea, culcarea, mesele principale, exercițiile fizice și verificarea parentală. Pentru fiecare activitate, există o marjă de 7 minute în care copilul o poate realiza.
Va trebui să setați și o parolă pentru secțiunea părinților, care îl împiedică pe copil să modifice orele sau să valideze activitățile în locul dumneavoastră. Această parolă poate fi schimbată ulterior prin adresa de email.
În final, copilul își va alege personajul preferat: Miss Nutri (feminin) sau Santos (masculin).
Odată finalizați acești pași, veți ajunge la pagina principală (Home Page). Important de reținut: această configurare se realizează o singură dată, la prima deschidere a aplicației.

Utilizarea aplicației
Aplicația are două zone distincte: una pentru copil și una pentru părinți.
Apăsând butonul Părinți și introducând parola setată, puteți accesa oricând secțiunea dedicată controlului parental. Aici puteți modifica orele activităților și, la ora stabilită pentru verificarea parentală, puteți valida progresul copilului din ziua respectivă.
Apăsând butonul Oraș, copilul ajunge în Fit'O Polis, un oraș împărțit în 9 zone, fiecare deblocându-se progresiv, câte una pe lună. Programul este conceput pentru o durată de 9 luni.
Apăsând butonul Exerciții, copilul va vedea un set de 5 exerciții alese aleatoriu, fiecare cu o durată de 1 minut și jumătate.
Apăsând butonul Stickere, copilul poate achiziționa stickere folosind steluțele acumulate din activități.
Apăsând butonul Începe Misiunea:

Dacă este ora stabilită pentru o activitate, copilul va fi direcționat automat către activitatea corespunzătoare.
Dacă nu este ora unei activități, copilul va fi îndrumat către secțiunea de exerciții.


Sistemul de recompense

  +200 steluțe pentru fiecare activitate realizată
  -50 steluțe pentru fiecare activitate nerealizată

Steluțele acumulate pot fi folosite pentru a cumpăra stickere în secțiunea dedicată.
""",
		"How does the game work?": "Cum funcționează jocul?",
		"utilization": """Ultima actualizare: [05.04.2026]

1. Introducere

Bine ați venit în aplicația Fit’O Polis. Această aplicație este un joc educativ destinat copiilor, care promovează un stil de viață sănătos prin activități zilnice interactive.

Utilizarea aplicației este permisă doar cu acordul și sub supravegherea unui părinte sau tutore legal.

2. Acceptarea termenilor

Prin utilizarea aplicației, părintele sau tutorele legal confirmă că a citit, înțeles și acceptat acești Termeni și condiții.

Dacă nu sunteți de acord cu acești termeni, vă rugăm să nu utilizați aplicația.

3. Descrierea serviciului

Fit’O Polis oferă:

=> activități zilnice (exerciții fizice, mese, programe de seară și dimineață)
=> sistem de recompense (steluțe și stickere)
=> monitorizarea progresului zilnic al copilului
=> posibilitatea trimiterii de rapoarte prin email către părinți
=> conținut educativ despre nutriție și stil de viață sănătos

4. Contul parental

Pentru utilizarea completă a aplicației, este necesar un cont parental.

Părintele este responsabil pentru:

=> setarea și păstrarea parolei în siguranță
=> verificarea activităților copilului
=> corectitudinea datelor introduse

Aplicația nu este responsabilă pentru accesul neautorizat rezultat din neprotejarea parolei.

5. Utilizarea aplicației

Utilizatorii se obligă:

=> să folosească aplicația în scop educativ
=> să nu încerce modificarea, copierea sau compromiterea aplicației
=> să nu utilizeze aplicația pentru activități ilegale sau abuzive

6. Sistemul de recompense

Steluțele și stickerele:

=> au scop exclusiv educativ și motivațional
=> nu au valoare monetară
=> nu pot fi convertite în bani sau alte beneficii reale

7. Emailuri și notificări

Aplicația poate trimite emailuri cu progresul copilului și confirmarea plăților variantelor premium.

Adresa de email:

=> este utilizată exclusiv pentru trimiterea rapoartelor
=> nu este folosită pentru marketing

8. Protecția datelor

Datele utilizatorilor sunt colectate și procesate în conformitate cu:
Regulamentul General privind Protecția Datelor

Pentru mai multe informații, consultați Politica de confidențialitate.

9. Securitatea aplicației

Este realizata protejarea datelor prin:
=> utilizarea conexiunilor securizate
=> protejarea parolelor
=> limitarea accesului la informații

10. Plăți și abonamente

Aplicația Fit’O Polis oferă atât funcționalități gratuite, cât și funcționalități disponibile prin programe plătite.

Sunt disponibile următoarele programe:

Program Super Saver:
=> acces la un număr dublu de exerciții fizice
=> acces la încă 16 rețete destinate părinților (codul de activare este disponibil pe site)
=> 3 șanse suplimentare pentru a evita pierderea punctelor

Program Ultimate Saver:
=> deblocarea unor modele suplimentare de stickere
=> acces la statistici avansate pentru părinți
=> acces la mai multe hărți ale orașelor Fit’O Polis (5 hărți suplimentare)
=> eliminarea reclamelor din aplicație
=> posibilitatea de a modifica durata activităților

Accesul la aceste programe se face contra cost și este permis doar părinților sau tutorilor legali.

Plățile:

=> sunt procesate prin servicii securizate furnizate de terți
=> pot fi recurente (abonament) sau unice, în funcție de opțiunea aleasă
=> nu sunt rambursabile, cu excepția cazurilor prevăzute de legislația în vigoare

Părintele sau tutorele legal este responsabil pentru gestionarea abonamentului, inclusiv pentru anularea acestuia înainte de reînnoire.

Ne rezervăm dreptul de a modifica prețurile sau structura programelor, cu informarea utilizatorilor în prealabil.

11. Modificări ale aplicației

Ne rezervăm dreptul de a:

=> modifica funcționalitățile aplicației
=> actualiza acești termeni

Utilizarea continuă a aplicației reprezintă acceptarea modificărilor.

12. Încetarea utilizării

Utilizatorul poate înceta utilizarea aplicației în orice moment prin dezinstalare.

Ne rezervăm dreptul de a restricționa accesul în caz de utilizare abuzivă.

13. Proprietate intelectuală

Toate elementele aplicației (grafică, personaje, conținut) sunt protejate și nu pot fi copiate sau distribuite fără permisiune.

14. Contact

Pentru întrebări sau solicitări:
Email: fitopolis.channel@gmail.com""",
		"Terms and conditions": "Termeni și condiții",
		"Attention parents!": "In atentia parintilor!",
		"To continue, you must accept:": "Pentru a continua, trebuie să acceptați:",
		"Privacy policy": "Politica de confidențialitate",
		"SeeTerms": """Vezi
Termenii""",
		"Continue": "Continua",
		"SeePolicy": """Vezi
Politica""",
		"Wake Up Time:": "",
		"Morning exercises:": "",
		"Breakfast:": "",
		"Lunch:": "",
		"Afternoon exercises:": "",
		"Dinner:": "",
		"Bedtime:": "",
		"Parental control time:": "",
		"Start the Game": "",
		"Save": "",
		"": "",
		"": "",
		"": "",
		"": "",
		"": "",
		"": "",
		"": "",
		
	},
	"en": {
		"greeting": "Hello!",
		"start_game": "Start Game",
		"settings": "Settings"
	}
}

signal language_changed

func get_text(key: String) -> String:
	if translations[current_language].has(key):
		return translations[current_language][key]
	return key  # returnează cheia dacă nu găsește traducerea

func set_language(lang: String) -> void:
	if translations.has(lang):
		current_language = lang
		language_changed.emit()
