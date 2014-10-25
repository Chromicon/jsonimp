=setup
[Configuration] 
ListFileExtension = TXT

[Window]
Head = JSONIMP - Import Hydstra JSON data from a webservice

[Labels]
SERVICE 	= END   10 10 Web service 
REP 		= END   +0 +2 Report File
QUERY 		= END   +0 +2 JSON query

[Fields]
SERVICE     = 11 10 INPUT   LIST       25  0  FALSE   TRUE   0.0 0.0 'Thiess' $IN.jsonimp.ini [.*.config$] 
REP        	= +0 +2 INPUT   CHAR       40  0  FALSE   TRUE   0.0 0.0 '#PRINT(P           )'
QUERY 		= +0 +2 INPUT   MEMO       80  15 FALSE   FALSE  0.0 0.0  ''

[Perl]
OUTFOLDER  = 21  +1 INPUT   CHAR       60  0  FALSE   FALSE  0.0 0.0 '&hyd-ptmppath.jsonimp' $OP

[Documentation]
Script imports data from a webservice which returns data from the Hydstra dllp.
Keep webservice location in INI file. 

TODO - Import to Hydstra ts and db Routines


[Published By]
Name: Sholto Maud
Email: sholto.maud@gmail.com
Mobile: +61424094227
Twitter: @Sholtomaud
Skype: Sholtomaud
GitHub: shotlom

[License]
MIT
http://opensource.org/licenses/MIT

=cut


use strict;
use warnings;

use File::Copy;
use File::stat;
use File::Path qw(make_path remove_tree);
use File::Fetch;
use FileHandle; 
use FindBin qw($Bin);
use Cwd;
use LWP::UserAgent;
use CGI;
use JSON; 
use Try::Tiny;
  
require 'hydlib.pl';
require 'hydtim.pl';

my $prtdest_scr   = '-LSR';   #the Prt() print destination for screen messages
my $prtdest_log   = '-LT';    #the Prt() print destination for log messages
my $prtdest_debug = '-T';     #the Prt() print destination for debug messages
my $prtdest_data  = '-T';     #the Prt() print destination for the data hash
my $_debug = defined( $ENV{HYDEBUG} );
my $DEFBUFFER = 1950;

my (%params, %ini, $dll);


main: { 
  
  IniCrack($ARGV[0],\%params);
  IniHash( $ARGV[0],      \%ini, 0, 0);
  my $script     = lc(FileName($0));
  my $inifile = "$script.ini";
  IniHash( $inifile, \%ini );
  
  my $temp          = HyconfigValue('TEMPPATH');
  my $reportfile    = $ini{perl_parameters}{rep};
  my $jsonquery     = $ini{'perl_parameters'}{'query'};
  my $service    		= lc($ini{'perl_parameters'}{'service'});
  my $service_config = "$service.config";
  my $url           = $ini{$service_config}{'url'};
	
  $jsonquery        =~ s{\\013\\010}{}sg;
	my $jsonstr       = JSON::XS->new->encode(eval($jsonquery));
	
  my $jsonquer      = eval($jsonquery);
  
  OpenFile(*hREPORT,$reportfile,'>');
  Prt(*hREPORT,NowStr()." Starting $0\n");
  	
  if ( !exists($ini{$service_config}{'url'}) ) {
    Prt( $prtdest_scr, "$script - The service [$service] does not have a url setting. Please configure the INI file with a correct url" );
    exit;
  }
  
	my $req = HTTP::Request->new(POST => $url);
	$req->content_type('application/json');
	$req->content($jsonstr);

	Prt( $prtdest_scr, NowStr()." - Starting Thiess Webservice Query\n");
	my $start = NowRel();
	my $ua = LWP::UserAgent->new();
	my $response = $ua->request($req);
	my $end = NowRel();
	
  my $content  = $response->decoded_content();
	my $duration = 60*($end - $start);
	Prt( $prtdest_scr, NowStr()."  - Response recieved\n");
	Prt('-R', NowStr()."  - Query took [$duration] seconds\n");
	
  #Print to screen
  my $json = JSON->new->allow_nonref;
	my $perl_scalar = $json->decode( $content );
	my $pretty_printed = $json->pretty->encode( $perl_scalar ); # pretty-printing
	Prt( $prtdest_scr, NowStr()." - Response \n$pretty_printed");
  
  #############
  #TODO - Import to Hydstra ts and db Routines
  #############
  close(hREPORT);
} 