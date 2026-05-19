
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
		"utilizationp": """
1. Introducere

Aplicația Fit’O Polis respectă confidențialitatea utilizatorilor.

Această politică explică ce date colectăm, cum le folosim și cum le protejăm.

2. Ce date colectăm

Aplicația poate colecta următoarele date:

=> adresa de email a părintelui
=> orele activităților zilnice (ora de trezire, mese, exerciții, ora de somn)
=> progresul copilului (activități completate, steluțe)
=> parola dedicată secțiunii parentale (stocată securizat)
=> date necesare procesării plăților (ex: informații legate de tranzacții, fără a stoca direct datele complete ale cardului)

Nu colectăm:

=> nume reale
=> adresă fizică
=> locație GPS
=> date sensibile

3. Scopul colectării datelor

Datele sunt colectate pentru:

=> funcționarea corectă a aplicației
=> monitorizarea progresului copilului
=> trimiterea de rapoarte zilnice către părinți
=> îmbunătățirea experienței utilizatorului
=> procesarea plăților pentru serviciile premium

4. Temeiul legal al prelucrării

Prelucrarea datelor se realizează în baza:

=> consimțământului părintelui sau tutorelui legal
=> executării contractului (furnizarea serviciilor aplicației – servicii ale societății informaționale)

5. Consimțământul parental

Aplicația este destinată copiilor și poate fi utilizată doar cu acordul unui părinte sau tutore legal.

6. Utilizarea adresei de email

Adresa de email este utilizată exclusiv pentru:

=> trimiterea rapoartelor zilnice privind activitățile copilului
=> confirmarea plăților destinate programelor premium

7. Stocarea și securitatea datelor

Datele sunt protejate prin măsuri de securitate adecvate, cum ar fi:

=> stocarea securizată a informațiilor
=> criptarea parolelor
=> utilizarea conexiunilor securizate

8. Durata stocării datelor

Datele sunt păstrate doar atât timp cât este necesar pentru funcționarea aplicației.

Datele utilizate pentru procesarea plăților sunt păstrate conform obligațiilor legale aplicabile.

Utilizatorii pot șterge datele prin dezinstalarea aplicației.

9. Drepturile utilizatorilor

Părinții au dreptul să:

=> acceseze datele colectate
=> modifice datele
=> solicite ștergerea datelor
=> retragă consimțământul

10. Partajarea datelor

Nu vindem și nu distribuim datele către terți.

Datele pot fi folosite doar în cadrul funcționării aplicației.

11. Scop educativ

Aplicația are scop educativ și nu înlocuiește sfatul medical sau nutrițional oferit de specialiști.

12. Modificări ale politicii

Ne rezervăm dreptul de a modifica această politică.

Utilizarea aplicației după modificări reprezintă acceptarea acestora.

13. Contact

Pentru întrebări sau solicitări:

Email: fitopolis.channel@gmail.com
		""",
		"utilizationt": """Ultima actualizare: [05.04.2026]

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
		"Wake Up Time:": "Ora de Trezire:",
		"Morning exercises:": "Exercitii dimineata:",
		"Breakfast:": "Masa de dimineata:",
		"Lunch:": "Masa de pranz:",
		"Afternoon exercises:": "Exercitii dupa-amiaza:",
		"Dinner:": "Masa de seara:",
		"Bedtime:": "Ora de culcare:",
		"Parental control time:": "Ora verificare parentală:",
		"Start the Game": "Incepe Jocul",
		"Save": "Salvează",
		"between 06:30 and 07:30": "intre 06:30 si 07:30",
		"between 07:00 and 08:00": "intre 07:00 si 08:00",
		"between 07:20 and 09:00": "intre 07:20 si 09:00",
		"between 13:00 and 15:45": "intre 13:00 si 15:45",
		"between 16:00 and 19:00": "intre 16:00 si 19:00",
		"between 20:00 and 20:30": "intre 20:00 si 20:30",
		"between 20:40 and 22:00": "intre 20:40 si 22:00",
		"between 22:00 and 00:00": "intre 22:00 si 00:00",
		"intro_email" : "Introduceți emailul dumneavoastră",
		"email_code": "Verificați adresa de email și introduceți codul de verificare.",
		"parrent_pass": "Introduceți parola cu care veți accesa secțiunea de părinte",
		"character": "Apasa pe personajul care te reprezintă:",
		"Invalid format (HH:MM)":"Format invalid (HH:MM)",
		"Invalid minutes (0–59)":"Minute invalide (0–59)",
		"Outside the interval (06:30–07:30)":"În afara intervalului (06:30–07:30)",
		"Outside the interval (07:00–08:00)":"În afara intervalului (07:00–08:00)",
		"Outside the interval (07:20–09:00)":"În afara intervalului (07:20–09:00)",
		"Outside the interval (13:00–15:45)":"În afara intervalului (13:00–15:45)",
		"Outside the interval (16:00–19:00)":"În afara intervalului (16:00–19:00)",
		"Outside the interval (20:00–20:30)":"În afara intervalului (20:00–20:30)",
		"Outside the interval (20:40–22:00)":"În afara intervalului (20:40–22:00)",
		"Outside the interval (22:00–00:00)":"În afara intervalului (22:00–00:00)",
		"Respect the order of activities":"Respectati ordinea activităților",
		"Delete and complete the previous boxes.":"Stergeti si completati casetele anterioare.",
		"There must be at least 15 minutes between activities.":"Intre activitati trebuie sa fie minim 15 minute.",
		"There are not 10 hours of sleep in the selected range.":"Nu sunt 10 ore de somn in intervalul selectat."
		
	},
	"en": {
		"greeting": "Hello!",
		"start_game": "Start Game",
		"utilizationp": """
1. Introduction

The Fit’O Polis app respects the privacy of its users.

This policy explains what data we collect, how we use it, and how we protect it.

2. What data do we collect

The application may collect the following data:

=> parent's email address
=> daily activity times (wake-up time, meals, exercises, bedtime)
=> child's progress (completed activities, stars)
=> password dedicated to the parental section (stored securely)
=> data necessary to process payments (e.g. transaction information, without directly storing full card data)

We do not collect:

=> real names
=> physical address
=> GPS location
=> sensitive data

3. Purpose of data collection

Data is collected for:

=> correct operation of the application
=> monitoring the child's progress
=> sending daily reports to parents
=> improving the user experience
=> processing payments for premium services

4. Legal basis for processing

Data processing is carried out based on:

=> consent parent or legal guardian
=> execution of the contract (provision of application services - information society services)

5. Parental consent

The application is intended for children and can only be used with the consent of a parent or legal guardian.

6. Use of email address

The email address is used exclusively for:

=> sending daily reports on the child's activities
=> confirming payments for premium programs

7. Data storage and security

Data is protected by appropriate security measures, such as:

=> secure storage of information
=> encryption of passwords
=> use of secure connections

8. Duration of data storage

Data is only kept for as long as necessary for the operation of the application.

Data used for payment processing is kept in accordance with applicable legal obligations.

Users can delete data by uninstalling the application.

9. User rights

Parents have the right to:

=> access collected data
=> modify data
=> request deletion of data
=> withdraw consent

10. Data sharing

We do not sell or distribute data to third parties.

The data can only be used within the operation of the application.

11. Educational purpose

The application has educational purposes and does not replace medical or nutritional advice provided by specialists.

12. Policy changes

We reserve the right to change this policy.

Using the application after changes represents acceptance of them.

13. Contact

For questions or requests:

Email: fitopolis.channel@gmail.com

		""",
		"utilizationt": """Last updated: [05.04.2026]

1. Introduction

Welcome to the Fit’O Polis app. This app is an educational game for children, which promotes a healthy lifestyle through interactive daily activities.
Use of the app is permitted only with the consent and supervision of a parent or legal guardian.

2. Acceptance of terms

By using the app, the parent or legal guardian confirms that they have read, understood and accepted these Terms and Conditions.

If you do not agree to these terms, please do not use the app.

3. Service Description

Fit’O Polis offers:

=> daily activities (exercises, meals, morning and evening programs)
=> reward system (stars and stickers)
=> monitoring of the child’s daily progress
=> the possibility of sending reports by email to parents
=> educational content about nutrition and healthy lifestyle

4. Parental account

A parental account is required for full use of the application.

The parent is responsible for:

=> setting and keeping the password safe
=> checking the child’s activities
=> the correctness of the entered data

The application is not responsible for unauthorized access resulting from failure to protect the password.

5. Use of the application

Users agree to:

=> use the application for educational purposes
=> not attempt to modify, copy or compromise the application
=> not use the application for illegal or abusive activities

6. Reward system

Stars and stickers:

=> have exclusively educational and motivational purposes
=> have no monetary value
=> cannot be converted into money or other real benefits

7. Emails and notifications

The application can send emails with the child's progress and confirmation of payments for premium versions.

Email address:

=> is used exclusively for sending reports
=> is not used for marketing

8. Data protection

User data is collected and processed in accordance with:

General Data Protection Regulation

For more information, see the Privacy Policy.

9. Application Security

Data protection is achieved by:
=> using secure connections
=> protecting passwords
=> limiting access to information

10. Payments and subscriptions

The Fit’O Polis application offers both free and paid features.

The following programs are available:

Super Saver Program:
=> access to double the number of physical exercises
=> access to 16 more recipes for parents (activation code is available on the website)
=> 3 additional chances to avoid losing points

Ultimate Saver Program:
=> unlocking additional sticker designs
=> access to advanced statistics for parents
=> access to more Fit’O Polis city maps (5 additional maps)
=> removing ads from the application
=> the ability to change the duration of activities

Access to these programs is for a fee and is allowed only to parents or legal guardians.

Payments:

=> are processed through secure services provided by third parties
=> can be recurring (subscription) or one-time, depending on the option chosen
=> are non-refundable, except in cases provided for by applicable law

The parent or legal guardian is responsible for managing the subscription, including its cancellation before renewal.

We reserve the right to change prices or program structure, with prior notice to users.

11. Changes to the application

We reserve the right to:

=> change the functionality of the application
=> update these terms

Continued use of the application constitutes acceptance of the changes.

12. Termination of use

The user may terminate use of the application at any time by uninstalling it.

We reserve the right to restrict access in case of abusive use.

13. Intellectual Property

All elements of the application (graphics, characters, content) are protected and cannot be copied or distributed without permission.

14. Contact

For questions or requests:
Email: fitopolis.channel@gmail.com
""",
		"Terms and conditions": "Terms and conditions",
		"How does the game work?": "How does the game work?",
		"info": """When you open the game, two buttons appear: START and ?. The ? button provides information about how the game works, and the START button starts the setup process.

Application setup
By pressing START, you will be directed to the Terms and Conditions and Privacy Policy of the game. Read them carefully and check the agreement to continue.
Next, you will need to enter your email address, which is required to receive messages related to your child's progress and for future validations. After entering your email, you will receive a confirmation code to that address, which you will need to enter to continue.
The next step is to schedule your child's daily activities, in HH:MM format. The activities that need to be set are: waking up, going to bed, main meals, physical exercises and parental verification. For each activity, there is a 7-minute window in which the child can complete it.
You will also need to set a password for the parents' section, which prevents the child from changing the hours or validating the activities for you. This password can be changed later via email.
Finally, the child will choose their favorite character: Miss Nutri (female) or Santos (male).
Once these steps are completed, you will reach the main page (Home Page). Important to remember: this configuration is done only once, the first time you open the application.

Using the application
The application has two distinct areas: one for the child and one for the parents.
By pressing the Parents button and entering the set password, you can access the section dedicated to parental control at any time. Here you can change the activity hours and, at the time set for parental verification, you can validate the child's progress for that day.
By pressing the City button, the child arrives in Fit'O Polis, a city divided into 9 areas, each of which is progressively unlocked, one per month. The program is designed for a duration of 9 months.
By pressing the Exercises button, the child will see a set of 5 randomly chosen exercises, each with a duration of 1 and a half minutes.
By pressing the Stickers button, the child can purchase stickers using the stars accumulated from the activities.
By pressing the Start Mission button:

If it is the set time for an activity, the child will be automatically directed to the corresponding activity.
If it is not the time for an activity, the child will be directed to the exercises section.

Reward system

+200 stars for each completed activity
-50 stars for each uncompleted activity

The accumulated stars can be used to purchase stickers in the dedicated section.""",
		"settings": "Settings",
		"Wake Up Time:": "Wake Up Time:",
		"Morning exercises:": "Morning exercises:",
		"Breakfast:": "Breakfast:",
		"Lunch:": "Lunch:",
		"Afternoon exercises:": "Afternoon exercises:",
		"Dinner:": "Dinner:",
		"Bedtime:": "Bedtime:",
		"Parental control time:": "Parental control time:",
		"Start the Game": "Start the Game",
		"Save": "Save",
		"between 06:30 and 07:30": "between 06:30 and 07:30",
		"between 07:00 and 08:00": "between 07:00 and 08:00",
		"between 07:20 and 09:00": "between 07:20 and 09:00",
		"between 13:00 and 15:45": "between 13:00 and 15:45",
		"between 16:00 and 19:00": "between 16:00 and 19:00",
		"between 20:00 and 20:30": "between 20:00 and 20:30",
		"between 20:40 and 22:00": "between 20:40 and 22:00",
		"between 22:00 and 00:00": "between 22:00 and 00:00",
		"Privacy policy": "Privacy policy",
		"Attention parents!": "Attention parents!",
		"To continue, you must accept:": "To continue, you must accept:",
		"SeeTerms": """See
		Terms""",
		"SeePolicy": """See
		Policy""",
		"Continue": "Continue",
		"intro_email": "Please enter your email",
		"email_code": "Verify your email address and enter the verification code.",
		"parrent_pass": "Enter the password with which you will access the parent section",
		"character": "Click on the character that represents you:",
		"Invalid format (HH:MM)":"Invalid format (HH:MM)",
		"Invalid minutes (0–59)":"Invalid minutes (0–59)",
		"Outside the interval (06:30–07:30)":"Outside the interval (06:30–07:30)",
		"Outside the interval (07:00–08:00)":"Outside the interval (07:00–08:00)",
		"Outside the interval (07:20–09:00)":"Outside the interval (07:20–09:00)",
		"Outside the interval (13:00–15:45)":"Outside the interval (13:00–15:45)",
		"Outside the interval (16:00–19:00)":"Outside the interval (16:00–19:00)",
		"Outside the interval (20:00–20:30)":"Outside the interval (20:00–20:30)",
		"Outside the interval (20:40–22:00)":"Outside the interval (20:40–22:00)",
		"Outside the interval (22:00–00:00)":"Outside the interval (22:00–00:00)",
		"Respect the order of activities":"Respect the order of activities",
		"Delete and complete the previous boxes.":"Delete and complete the previous boxes.",
		"There must be at least 15 minutes between activities.":"There must be at least 15 minutes between activities.",
		"There are not 10 hours of sleep in the selected range.":"There are not 10 hours of sleep in the selected range."
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
