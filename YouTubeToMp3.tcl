# YouTube To Mp3

# Configurations:
set YouTube2Mp3(Version) "2.2.9";				# Version du Script.
set YouTube2Mp3(Author) "MvK, JynX, MalaGaM";	# Version du Script.
set YouTube2Mp3(LastMod) "23/07/2011";			# Date de la derniere modification.
set YouTube2Mp3(lang) "fr";				# Langue du clavier pour la navigation
set YouTube2Mp3(Links_Max) "5";			# Limite d'affichage des liens.
set YouTube2Mp3(HTTP_TimeOut) "10000";	# Temps avant qu'une page/lien est consideré en DEAD.
set YouTube2Mp3(HTTP_UserAgent) {Mozilla/5.0 ($platfrm; U; $tcl_platform(os) $tcl_platform(machine); $YouTube2Mp3(lang); rv:1.9.0.3) YourTube $YouTube2Mp3(Version)" -accept "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8};

# Package requis au fonctionement du script:
package require http;
package require tls;

# Variable init
if {$tcl_platform(os) eq "Linux"} { set platfrm "X11"; } else { set platfrm $tcl_platform(os); }

######################
#  * * * Code * * *  #
######################
bind pubm - "*youtube.com/*" YouTube2MP3_Module
proc YouTube2MP3_Module { nick uhost hand chan arg } {

	# Récupération du lien YouTube, ainsi que le Link_ID YouTbe
	if { [regexp -nocase -- {(?:http://www\.)?youtube\.com/watch\?v=([-_0-9A-Za-z=]+)} $arg - Link_ID] != "1" } { 
		putserv "privmsg $chan :01\[04Erreur01\] 06YouTube2MP3 -> Lien YouTube est incorrect.";
		return 0; 
	}

	# Envois message au channel :
	putserv "privmsg $chan :06Titre YouTube14: [YouTube_Get_Titre $Link_ID]";
	putserv "privmsg $chan :7,12Video2Mp314    ->07 http://www.video2mp3.net/?v=$Link_ID";
	putserv "privmsg $chan :12YouTube1-2Mp314  ->07 http://www.youtube-mp3.org/#v=$Link_ID";
}

# Fonction d'envois de message 'RAPIDE' :
proc putfast { arg } {
	append arg "\n";
	putdccraw 0 [string length $arg] $arg;
}

# Fonction qui recupere les resultats YouTube:
proc YouTube_Get_Search { words } {
	set words [string map { " " "+" } $words];
	set tok [http::geturl http://www.youtube.com/results?search_query=$words&aq=f -timeout $::YouTube2Mp3(HTTP_TimeOut)];
	set data [http::data $tok];
	http::cleanup $tok
	regsub -all "<b>" $data "" data;
	regsub -all "</b>" $data "" data;
	set list {}
	set a "0"
	while {[regexp -- {</div><h3 id="video-long-title-(.*?)"><a href="(.*?)" dir="ltr" title="(.*?)" >(.*?)</a></h3>(.*)$} $data -> number lien title - data]} {
		if { $a == $::YouTube2Mp3(Links_Max) } { break; }
		append list "[list $title $number]\n";
		incr a;
	}
	if {![info exists title]} { return "\002Error:\002 Nothing found for '$words'"; }
	return $list;
}
bind pub - !yousearch YouTube_Search
proc YouTube_Search { nick uhost hand chan arg } {
	set data [YouTube_Get_Search "$arg"];
	foreach { Titre Link_ID } $data { 
		YouTube2MP3_Module $nick $uhost $hand $chan "http://www.youtube.com/watch?v=$Link_ID";
	}
}

# Fonction qui recupere le titre YouTube:
proc YouTube_Get_Titre { Link_ID } {
	http::config -useragent $::YouTube2Mp3(HTTP_UserAgent);
	set token [http::geturl http://www.youtube.com/watch?v=$Link_ID -timeout $::YouTube2Mp3(HTTP_TimeOut)];
	upvar #0 $token state;
	set data $state(body);
	regsub -all {\n|\t} $data "" data
	set ncode "";
	regexp {[0-9]{3}} $state(http) ncode;
	if {$ncode eq ""} { set ncode $state(http); }
	set list {};
	switch -- $ncode {
		"200" {
			regexp -nocase -- {(<meta name="title" content=")(.+)(">)(.+)(<meta name="description")} $data - - Titre;
			http::cleanup $token;
			set Titre [string map $::escapes $Titre];
			return $Titre;
		}
		"404" {
			http::cleanup $token;
			return "Sans titre";
		}
		default {
			http::cleanup $token
			return "Résponse du serveur YouYube incorrect.."
		}
	}
}
set escapes {
 &nbsp; \x20 &quot; \x22 &amp; \x26 &apos; \x27 &ndash; \x2D
 &lt; \x3C &gt; \x3E &tilde; \x7E &euro; \x80 &iexcl; \xA1
 &cent; \xA2 &pound; \xA3 &curren; \xA4 &yen; \xA5 &brvbar; \xA6
 &sect; \xA7 &uml; \xA8 &copy; \xA9 &ordf; \xAA &laquo; \xAB
 &not; \xAC &shy; \xAD &reg; \xAE &hibar; \xAF &deg; \xB0
 &plusmn; \xB1 &sup2; \xB2 &sup3; \xB3 &acute; \xB4 &micro; \xB5
 &para; \xB6 &middot; \xB7 &cedil; \xB8 &sup1; \xB9 &ordm; \xBA
 &raquo; \xBB &frac14; \xBC &frac12; \xBD &frac34; \xBE &iquest; \xBF
 &Agrave; \xC0 &Aacute; \xC1 &Acirc; \xC2 &Atilde; \xC3 &Auml; \xC4
 &Aring; \xC5 &AElig; \xC6 &Ccedil; \xC7 &Egrave; \xC8 &Eacute; \xC9
 &Ecirc; \xCA &Euml; \xCB &Igrave; \xCC &Iacute; \xCD &Icirc; \xCE
 &Iuml; \xCF &ETH; \xD0 &Ntilde; \xD1 &Ograve; \xD2 &Oacute; \xD3
 &Ocirc; \xD4 &Otilde; \xD5 &Ouml; \xD6 &times; \xD7 &Oslash; \xD8
 &Ugrave; \xD9 &Uacute; \xDA &Ucirc; \xDB &Uuml; \xDC &Yacute; \xDD
 &THORN; \xDE &szlig; \xDF &agrave; \xE0 &aacute; \xE1 &acirc; \xE2
 &atilde; \xE3 &auml; \xE4 &aring; \xE5 &aelig; \xE6 &ccedil; \xE7
 &egrave; \xE8 &eacute; \xE9 &ecirc; \xEA &euml; \xEB &igrave; \xEC
 &iacute; \xED &icirc; \xEE &iuml; \xEF &eth; \xF0 &ntilde; \xF1
 &ograve; \xF2 &oacute; \xF3 &ocirc; \xF4 &otilde; \xF5 &ouml; \xF6
 &divide; \xF7 &oslash; \xF8 &ugrave; \xF9 &uacute; \xFA &ucirc; \xFB
 &uuml; \xFC &yacute; \xFD &thorn; \xFE &yuml; \xFF &#39; \x27
};

putlog "\00304YouTube To Mp3 Version: $YouTube2Mp3(Version) - Last modified: $YouTube2Mp3(LastMod) - Coded By $YouTube2Mp3(Author)";

