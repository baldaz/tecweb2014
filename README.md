tecweb2014
==========

Progetto Tecweb

ALBERO DIRECTORY:

* [cgi-bin/] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin)
	* [UTILS/] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/UTILS)
		* [Admin.pm] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/UTILS/Admin.pm)
        * [UTILS.pm] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/UTILS.pm)
	* [load.cgi] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/load.cgi)
	* [admin.cgi] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/admin.cgi)
	* [login.cgi] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/login.cgi)
	* [login.pl] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/login.pl)
	* [prenota.cgi] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/prenota.cgi)
	* [process.pl] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/process.pl)
	* [vbooked.pl] (https://github.com/baldaz/tecweb2014/tree/template_change/cgi-bin/vbooked.pl)
* [data/] (https://github.com/baldaz/tecweb2014/tree/template_change/data)
       * [corsi.xml] (https://github.com/baldaz/tecweb2014/tree/template_change/data/corsi.xml) 
       * [impianti.xml] (https://github.com/baldaz/tecweb2014/tree/template_change/data/impianti.xml)
       * [news.xml] (https://github.com/baldaz/tecweb2014/tree/template_change/data/news.xml)	
       * [profili.xml] (https://github.com/baldaz/tecweb2014/tree/template_change/data/profili.xml)
       * [sezioni.xml] (https://github.com/baldaz/tecweb2014/tree/template_change/data/sezioni.xml)
       * [prenotazioni.xml] (https://github.com/baldaz/tecweb2014/tree/template_change/data/prenotazioni.xml)

* [public_html/] (https://github.com/baldaz/tecweb2014/tree/template_change/public_html)
  	      * [css/] (https://github.com/baldaz/tecweb2014/tree/template_change/public_html/css)
	           * [corsi.css]
		   * [impianti.css]
		   * [mobile.css]
		   * [prenotazioni.css]
		   * [print.css]
		   * [style.css]
		   * [tablet.css]
	       
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