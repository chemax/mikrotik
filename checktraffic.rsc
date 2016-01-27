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

	:set $realtraff [/queue simple get "$n" byte];
	:put ("Src traff: ".$realtraff);
	
	:set $upload [:pick $realtraff 0 ([:find $realtraff "/"])];
	:put ("Upload: ".($upload / 1048576));
	:set download [:pick $realtraff ([:find $realtraff "/"]+1) [:len $realtraff]];
	:put ("Download: ".($download / 1048576 ));
	:set totaltraf (($upload + $download) + $totaltraf + $traficnow);
	:put ("Total: ".($totaltraf / 1048576));
	:put ("Limit: ".$limit);
	/queue simple reset-counters "$n";
	/queue simple set comment="$totaltraf/$limit" "$n"
	############################################
		:if (($totaltraf / 1048576) >= $limit) do={
			:set clientiparray [/queue simple get number=$y target];
			for i from 0 to=([:len [/queue simple get number=$y target]]-1) do={
				:set clientip [:pick $clientiparray $i];
				:set clientip [:pick $clientip 0 [find $clientip "/32"]];
				:do {
				:if ([/ip arp get value-name=disabled [find address=$clientip]] = false) do={
					/ip arp set [find address=$clientip] disable=yes;
					#/ip arp set [find address=[:pick $clientip 0 [:find $clientip "/32"]]] disable=yes;
					:put ("zablokirovano ".$clientip);
				}
				} on-error={:put ($clientip." block error");}
			}
		} else={
			:set clientiparray [/queue simple get number=$y target];
			for i from 0 to=([:len [/queue simple get number=$y target]]-1) do={
				:set clientip [:pick $clientiparray $i];
				:put $clientip;
				:set clientip [:pick $clientip 0 [find $clientip "/32"]];
				:put $clientip;
				:do {
				:if ([/ip arp get value-name=disabled [find address=$clientip]] = true) do={
					/ip arp set [find address=$clientip] disable=no;
					:put ("razblokirovano ".$clientip);
				}
				} on-error={:put ($clientip." unblock error");}
			}
		}
	############################################
	}
}