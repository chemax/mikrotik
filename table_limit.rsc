:local queuename;
:local ftpaddr; 
:set $ftpaddr "192.168.0.1";
:local ftpuser;
set $ftpuser mikrotik;
:local ftppass;
set $ftppass mikrotik;
:local queueip;
:local queueiparray;
:local limit;
:local queuespeed;
:local routername;
:local schet;
:set schet ([/queue simple print count-only]-1);
:set routername [/system identity get name];
:local limitfull;
:set limitfull 0;
:for y from=0 to=$schet do={
:set $comment [/queue simple get number=$y comment];
if ($comment != "no") do={
:set queuename [/queue simple get number=$y name];
:set queueiparray [:toarray [/queue simple get number=$y target]];
:do {:set $findslash [:find $comment "/"];} on-error={:put "error";}
	#if we have "/", lets go parse comment from comment
	if ( $findslash > 0) do={
		:set $limit [:pick $comment ([:find $comment "/"]+1) [:len $comment]];
		} else={
		:set $limit [/queue simple get "$n" comment];
		}
:put $limit;
:set limitfull ($limitfull + $limit);
:set queuespeed [/queue simple get number=$y max-limit];
for i from 0 to=([:len [/queue simple get number=$y target]]-1) do={
:set queueip [:pick $queueiparray $i];
:put ("$queuename|$queueip|$limit|$queuespeed|");
:set tofile "$tofile\r|$queuename|$queueip|$limit|$queuespeed|";
:set queuename ":::";
:set limit ":::";
:set queuespeed ":::";
}

}
}
:set tofile "=====$routername=====\r\n^Name^ip^limit^speed^$tofile\\\\Limit full: $limitfull";
/file print file=$routername;
:delay delay-time=2;
/file set "$routername.txt" contents=$tofile;
:put $tofile;
:delay delay-time=2;
/tool fetch address=$ftpaddr src-path="$routername.txt" user=$ftpuser mode=ftp password=$ftppass dst-path="/$routername.txt" upload=yes; 