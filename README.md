tecweb2014
==========

Progetto Tecweb

ALBERO DIRECTORY:

STRUTTURA PROVVISORIA:
    
                          ____|___  admin
                         /    |
       viewB  ______    /_____|___  login 
                    \  /      |
       load  _____  UTILS  ___|___  prenota
                              |
           
- 5 CGI importano il modulo UTILS che contiene funzioni di utilità
- viewB e load => funzionamento sito
- admin e prenota => aree riservate, attraverso login

TODO:

	+++++ LAYOUT +++++

- transition su Opera
- media="handheld, screen and (max-width:480px), only screen and (max-device-width:480px)" per i dispositivi mobile
- css per aural
- css per stampa
- css mobile prenotazioni
- accessibilità tabelle
- margin collapsing (per margini che entrano in contatto)

  	+++++ PERL +++++

- Sessioni, login etc.
- Eliminazione prenotazione.
- Area amministrativa.
- Templating
- Considerare HTML::Restrict per il controllo URL/forms, strip html semplice