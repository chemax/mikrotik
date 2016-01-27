/system script run dozor;
:do {:local lastreset [/file get value-name=contents rest.txt];} on-error={:set $lastreset "jan/01/1970";}; 
:if ($lastreset != [/system clock get date]) do={:put "test";}

:local n;
:local upload;
:local download;
:local totaltraf;
:local realtraff;
:local limit;
:local clientip;
:local clientiparray;
:local traficnow;
 
:for y from=0 to=([/queue simple print count-only]-1) do={
:put "====================================================================";
############nulling variables#############
:set $upload 0;
:set $download 0;
:set $totaltraf 0;
:set $realtraff 0;
:set $limit 0;
:set $traficnow 0;
############################################

:set n [/queue simple get number=$y name]; #get queue name

:put ($y.") ".$n); #put queue number and name

:set $data [/queue simple get "$n" comment]; #get saved data

#:put [:typeof $data];

:if (data != "no") do={
	:do {:set $findslash [:find $data "/"];} on-error={:put "error";}
	
	#if we have "/", lets go parse data from comment
	if ( $findslash > 0) do={
		:set $traficnow [:pick $data 0 ([:find $data "/"])];
		:set $limit [:pick $data ([:find $data "/"]+1) [:len $data]];
		:put ("Trafic Now: ".$traficnow );
		:put ("traf: ".$traf." limit: ".$download); :put [:find $data "/"];
	} else={
		:put "net slesha";
		:set $limit [/queue simple get "$n" comment];
	}
	:put [:typeof $limit];
	if ($limit = "") do={
		:set $limit 1;
		:put ($limit." vistavlen limit");
	}
	/queue simple reset-counters "$n";
	/queue simple set comment="0/$limit" "$n"
	:do {/file print file=rest.txt;} on-error={:put "error"}
	:do {/file set rest.txt contents=[/system clock get date];} on-error={:put "error"}
}
}
/system script run dozor;