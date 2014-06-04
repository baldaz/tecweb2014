tecweb2014
==========

Progetto Tecweb

ALBERO DIRECTORY:

* [cgi-bin/]
	* [UTILS/]
		* [Admin.pm]
        * [UTILS.pm]
	* [load.cgi]
	* [admin.cgi]
	* [login.cgi]
	* [login.pl]
	* [prenota.cgi]
	* [process.pl]
	* [vbooked.pl]
- data/
        corsi.xml
	impianti.xml
	news.xml
	profili.xml
	sezioni.xml
	prenotazioni.xml

- public_html/
	       css/
	            corsi.css
		    impianti.css
		    mobile.css
		    prenotazioni.css
		    print.css
		    style.css
		    tablet.css
	       
	       images/
		       border.png
		       campo-tennis.png
		       campo-calcetto.png
		       entrata-centro.png
		       fitness.jpg
		       footerbackground.png
		       headerbackground.png
		       seagal-3.png
		       shad2.png

	       js/
		   jquery.js
		   rtc_form.js
		   script.js

	       templates/
			  admin/
				 add_news.tmpl
				 edit_news.tmpl
				 edit_prenotation.tmpl
				 footer.tmpl
				 header.tmpl       

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