#!/rwasics_apps/gnu/bin/perl -w

# $Id$

use strict;
use lib ".";
use Getopt::ExPar;
use Reference_Parser;

my($OPT) = {};
$OPT->{'versionNumber'} = "1.00";

&parse_command_line($OPT);

print STDOUT "\$OPT = " .
  &Reference_Tree_String($OPT, "\$OPT = ") . "\n\n";

#########################################################################
# Routine to parse the command line parameters.
#########################################################################
sub parse_command_line {
  my($OPT) = @_;
  my(@PDT,@MM);

@PDT = split /\n/, <<'end-of-PDT';
PDT sample
  integer01, int01 : integer
  integer02        : integer
  integer03, int03 : integer (5 <  # <  9)
  integer04, int04 : integer (5 <= # <  9)
  integer05, int05 : integer (5 <  # <= 9)
  integer06, int06 : integer (5 <= # <= 9)
  integer07        : integer (5 <  # <  9)
  integer08        : integer (5 <= # <  9)
  integer09        : integer (5 <  # <= 9)
  integer10        : integer (5 <= # <= 9)
  integer11, int11 : integer = 7
  integer12        : integer = 7
  integer13, int13 : integer (5 <  # <  9) = 7
  integer14, int14 : integer (5 <= # <  9) = 7
  integer15, int15 : integer (5 <  # <= 9) = 7
  integer16, int16 : integer (5 <= # <= 9) = 7
  integer17        : integer (5 <  # <  9) = 7
  integer18        : integer (5 <= # <  9) = 7
  integer19        : integer (5 <  # <= 9) = 7
  integer20        : integer (5 <= # <= 9) = 7
  integer21, int21 : list of integer
  integer22        : list of integer
  integer23, int23 : list of integer (5 <  # <  9)
  integer24, int24 : list of integer (5 <= # <  9)
  integer25, int25 : list of integer (5 <  # <= 9)
  integer26, int26 : list of integer (5 <= # <= 9)
  integer27        : list of integer (5 <  # <  9)
  integer28        : list of integer (5 <= # <  9)
  integer29        : list of integer (5 <  # <= 9)
  integer30        : list of integer (5 <= # <= 9)
  integer31, int31 : list of integer = (7, 8)
  integer32        : list of integer = (7, 8)
  integer33, int33 : list of integer (5 <  # <  9) = (7, 8)
  integer34, int34 : list of integer (5 <= # <  9) = (7, 8)
  integer35, int35 : list of integer (5 <  # <= 9) = (7, 8)
  integer36, int36 : list of integer (5 <= # <= 9) = (7, 8)
  integer37        : list of integer (5 <  # <  9) = (7, 8)
  integer38        : list of integer (5 <= # <  9) = (7, 8)
  integer39        : list of integer (5 <  # <= 9) = (7, 8)
  integer40        : list of integer (5 <= # <= 9) = (7, 8)
  integer41, int41 : integer (5 <= # <= 9, 10, =12, ==14, >20) = 10
  integer42        : list of integer (5 <= # <= 9, 10, =12, ==14, >20) = (10, 12)
  integer43, int43 : integer (5 <= # <= 9, 10, =12, ==14, >20) = ENV:D_int43
  integer44        : list of integer (5 <= # <= 9, 10, =12, ==14, >20) = (ENV:D_int44, 12)
  integer45, int45 : integer (5 <= # <= 9, 10, =12, ==14, >ENV:D_int45) = 100
  integer46        : list of integer (5 <= # <= 9, ENV:D_int46, =12, ==14, (#>20 and #%2==0)) = (42, 12)
  integer47, int47 : integer = $required
  integer48        : integer = $required
  integer49, int49 : integer (5 <  # <  19, #%2==0) = $required
  integer50, int50 : integer (5 <= # <  19) = $required
  integer51, int51 : integer (5 <  # <= 19) = $required
  integer52, int52 : integer (5 <= # <= 19) = $required
  integer53        : integer (5 <  # <  19) = $required
  integer54        : integer (5 <= # <  19) = $required
  integer55        : integer (5 <  # <= 19) = $required
  integer56        : integer (5 <= # <= 19) = $required
  integer57, int57 : list of integer = $required
  integer58        : list of integer = $required
  integer59, int59 : list of integer (5 <  # <  19) = $required
  integer60, int60 : list of integer (5 <= # <  19) = $required
  integer61, int61 : list of integer (5 <  # <= 19) = $required
  integer62, int62 : list of integer (5 <= # <= 19) = $required
  integer63        : list of integer (5 <  # <  19) = $required
  integer64        : list of integer (5 <= # <  19) = $required
  integer65        : list of integer (5 <  # <= 19) = $required
  integer66        : list of integer (5 <= # <= 19) = $required
  integer67, int67 : integer = ENV:D_int67
  integer68        : integer = ENV:D_int68
  integer69, int69 : list of integer = ENV:D_int69
  integer70        : list of integer = ENV:D_int70
  real01, re01 : real
  real02       : real
  real03, re03 : real (5.0 <  # <  9.0)
  real04, re04 : real (5.0 <= # <  9.0)
  real05, re05 : real (5.0 <  # <= 9.0)
  real06, re06 : real (5.0 <= # <= 9.0)
  real07       : real (5.0 <  # <  9.0)
  real08       : real (5.0 <= # <  9.0)
  real09       : real (5.0 <  # <= 9.0)
  real10       : real (5.0 <= # <= 9.0)
  real11, re11 : real = 7.0
  real12       : real = 7.0
  real13, re13 : real (5.0 <  # <  9.0) = 7.0
  real14, re14 : real (5.0 <= # <  9.0) = 7.0
  real15, re15 : real (5.0 <  # <= 9.0) = 7.0
  real16, re16 : real (5.0 <= # <= 9.0) = 7.0
  real17       : real (5.0 <  # <  9.0) = 7.0
  real18       : real (5.0 <= # <  9.0) = 7.0
  real19       : real (5.0 <  # <= 9.0) = 7.0
  real20       : real (5.0 <= # <= 9.0) = 7.0
  real21, re21 : list of real
  real22       : list of real
  real23, re23 : list of real (5.0 <  # <  9.0)
  real24, re24 : list of real (5.0 <= # <  9.0)
  real25, re25 : list of real (5.0 <  # <= 9.0)
  real26, re26 : list of real (5.0 <= # <= 9.0)
  real27       : list of real (5.0 <  # <  9.0)
  real28       : list of real (5.0 <= # <  9.0)
  real29       : list of real (5.0 <  # <= 9.0)
  real30       : list of real (5.0 <= # <= 9.0)
  real31, re31 : list of real = (7.0, 8.0)
  real32       : list of real = (7.0, 8.0)
  real33, re33 : list of real (5.0 <  # <  9.0) = (7.0, 8.0)
  real34, re34 : list of real (5.0 <= # <  9.0) = (7.0, 8.0)
  real35, re35 : list of real (5.0 <  # <= 9.0) = (7.0, 8.0)
  real36, re36 : list of real (5.0 <= # <= 9.0) = (7.0, 8.0)
  real37       : list of real (5.0 <  # <  9.0) = (7.0, 8.0)
  real38       : list of real (5.0 <= # <  9.0) = (7.0, 8.0)
  real39       : list of real (5.0 <  # <= 9.0) = (7.0, 8.0)
  real40       : list of real (5.0 <= # <= 9.0) = (7.0, 8.0)
  real41, re41 : real (5.0 <= # <= 9.0, 10.0, =12.0, ==14.0, >20.0) = 22.234
  real42, re42 : list of real (5.0 <= # <= 9.0, 10.0, =12.0, ==14.0, >20.0) = (6.0, 12.0)
  real43, re43 : real (5 <= # <= 9, 10, =12, ==14, >20) = ENV:D_real43
  real44       : list of real (5 <= # <= 9, 10, =12, ==14, >20) = (ENV:D_real44, 12)
  real45, re45 : real (5 <= # <= 9, 10, =12, ==14, >ENV:D_real45) = 100
  real46       : list of real (5 <= # <= 9, ENV:D_real46, =12, ==14, >20) = (44, 12)
  real47, re47 : real = $required
  real48       : real = $required
  real49, re49 : real (5.0 <  # <  19.0) = $required
  real50, re50 : real (5.0 <= # <  19.0) = $required
  real51, re51 : real (5.0 <  # <= 19.0) = $required
  real52, re52 : real (5.0 <= # <= 19.0) = $required
  real53       : real (5.0 <  # <  19.0) = $required
  real54       : real (5.0 <= # <  19.0) = $required
  real55       : real (5.0 <  # <= 19.0) = $required
  real56       : real (5.0 <= # <= 19.0) = $required
  real57, re57 : list of real = $required
  real58       : list of real = $required
  real59, re59 : list of real (5.0 <  # <  19.0) = $required
  real60, re60 : list of real (5.0 <= # <  19.0) = $required
  real61, re61 : list of real (5.0 <  # <= 19.0) = $required
  real62, re62 : list of real (5.0 <= # <= 19.0) = $required
  real63       : list of real (5.0 <  # <  19.0) = $required
  real64       : list of real (5.0 <= # <  19.0) = $required
  real65       : list of real (5.0 <  # <= 19.0) = $required
  real66       : list of real (5.0 <= # <= 19.0) = $required
  real67, re67 : real = ENV:D_real67
  real68       : real = ENV:D_real68
  real69, re69 : list of real = ENV:D_real69
  real70       : list of real = ENV:D_real70
  boolean01, bo01 : boolean
  boolean02       : boolean
  boolean03, bo03 : boolean = 1
  boolean04       : boolean = true
  boolean05, bo05 : list of boolean
  boolean06       : list of boolean
  boolean07, bo07 : list of boolean = (1, "true")
  boolean08       : list of boolean = (0, "on", "false", "no")
  switch01, sw01 : switch
  switch02       : switch
  switchg, g : switch
  switchx, x : switch
  switchz, z : switch
  switchc, c : switch
  switchd, d : switch
  string01, str01 : string
  string02        : string
  string03, str03 : string ('string03?')
  string04        : string ('string04')
  string05, str05 : string ('string05') = "string05"
  string06        : string ('string06') = "string06"
  string07, str07 : string ('string07') = 'string07'
  string08        : string ('string08') = ENV:D_string08, 'string08'
  string09, str09 : list of string
  string10        : list of string
  string11, str11 : list of string ('string11')
  string12        : list of string ('string12')
  string13, str13 : list of string ('string13') = ("string13a")
  string14        : list of string ('string14') = ("string14a", "string14b")
  string15, str15 : list of string ('string15') = ('string15a')
  string16        : list of string ('string16') = ('string16a', 'string16b', )
  string17        : list of string ('s(?:tring)?17') = ENV:D_string17, ('string17a', 'string17b')
  string18        : list of string ("s(?:tring)?18") = ENV:D_string18, ('string18a', 'string18b', )
  string19        : list of string ('s(?:tring)?19') = ENV:D_string19, ('string19a', ENV:D_string19b)
  string20        : list of string ("s(?:tring)?20") = ENV:D_string20, (ENV:D_string20a, 'string20b')
  string21, str21 : string ('^\d{2,3}\w\d{2,8}$') = "333x29445"
  name01, nm01 : name
  name02       : name
  name03, nm03 : name ('name03?')
  name04       : name ('name04')
  name05, nm05 : name ('name05') = "name05"
  name06       : name ('name06') = "name06"
  name07, nm07 : name ('name07') = 'name07'
  name08       : name ('name08') = ENV:D_name08, 'name08'
  name09, nm09 : list of name
  name10       : list of name
  name11, nm11 : list of name ('name11')
  name12       : list of name ('name12')
  name13, nm13 : list of name ('name13') = ("name13a")
  name14       : list of name ('name14') = ("name14a", "name14b")
  name15, nm15 : list of name ('name15') = ('name15a')
  name16       : list of name ('name16') = ('name16a', 'name16b', )
  name17       : list of name ('n(?:ame)?17') = ENV:D_name17, ('name17a', 'name17b')
  name18       : list of name ("n(?:ame)?18") = ENV:D_name18, ('name18a', 'name18b', )
  name19       : list of name ('n(?:ame)?19') = ENV:D_name19, ('name19a', ENV:D_name19b)
  name20       : list of name ("n(?:ame)?20") = ENV:D_name20, (ENV:D_name20a, 'name20b')
  name21, nm21 : name ('^\d{2,3}\w\d{2,8}$') = "333x29445"
  file01, fl01 : file
  file02       : file
  file03, fl03 : file
  file04       : file
  file05, fl05 : file = "~"
  file06       : file = "$HOME/bin"
  file07, fl07 : file = '~mgshakal/bin'
  file08       : file = ENV:D_file08, 'file08'
  file09, fl09 : list of file
  file10       : list of file
  file11, fl11 : list of file
  file12       : list of file
  file13, fl13 : list of file = ("file13a")
  file14       : list of file = ("file14a", "file14b")
  file15, fl15 : list of file = ('file15a')
  file16       : list of file = ('file16a', 'file16b', )
  file17       : list of file = ENV:D_file17, ('file17a', 'file17b')
  file18       : list of file = ENV:D_file18, ('file18a', 'file18b', )
  file19       : list of file = ENV:D_file19, ('file19a', ENV:D_file19b)
  file20       : list of file = ENV:D_file20, (ENV:D_file20a, 'file20b')
  application01, app01 : application
  application02        : application
  application03, app03 : application
  application04        : application
  application05, app05 : application = `date`
  application06        : application = `cal`
  application07, app07 : application = `time ls`
  application08        : application = ENV:D_application08, `cal`
  application09, app09 : list of application
  application10        : list of application
  application11, app11 : list of application
  application12        : list of application
  application13, app13 : list of application = ("`time ls`")
  application14        : list of application = ("`time ls`", "date")
  application15, app15 : list of application = ('`cal`')
  application16        : list of application = ('`cal`', '`date`', )
  application17        : list of application = ENV:D_application17, ('`ls`', '`ps`')
  application18        : list of application = ENV:D_application18, ('`ps`', '`time ls`', )
  application19        : list of application = ENV:D_application19, ('`time ls`', ENV:D_application19b)
  application20        : list of application = ENV:D_application20, (ENV:D_application20a, '`date`')
  set01, st01 : set of
    : integer (5 <= # <= 9)
    : real (5.0 <= # <= 9.0)
    : string ('setpat01')
    : key ak, bk, ck, dk, keyend
  end set
  set02, st02 : set of = $required
    : integer
    : real
    : string
  end set
  set03, st03 : set of
    : integer = 4
    : real = 5.5
    : string = "asdf"
    : key ak, bk, ck, dk, keyend = dk
  end set
  set04, st04 : set of = $required
    : integer
    : real
    : string
  end set
  set05, st05 : list of set of
    : integer = (4)
    : real = (5.5)
    : string = ("asdf")
    : key ak, bk, ck, dk, keyend = ("bk")
  end set
  set06, st06 : list of set of = $required
    : integer
    : real
    : string
    : key ak, bk, ck, dk, keyend
  end set
  set07, st07 : list of set of
    : integer = (4, 5)
    : real = (5.5, 10)
    : string = ("asdf", "fdsa")
  end set
  key01, k01: key plotter, postscript, text, printer, keyend = printer
  key02     : key plotter, postscript, text, printer, keyend = printer
  key03, k03: list of key plotter, postscript, text, printer, keyend = ("printer")
  key04     : list of key plotter, postscript, text, printer, keyend = ("text")
  key05, k05: list of key plotter, postscript, text, printer, keyend = ("printer", "text")
  key06     : list of key plotter, postscript, text, printer, keyend = ("printer", "text")
  key07, k07: key plotter, postscript, text, printer, keyend
  key08     : key plotter, postscript, text, printer, keyend
  key09, k09: list of key plotter, postscript, text, printer, keyend
  key10     : list of key plotter, postscript, text, printer, keyend
  key11, k11: list of key plotter, postscript, text, printer, keyend = ENV:D_key11
  key12     : list of key plotter, postscript, text, printer, keyend = ENV:D_key12, ("printer")
  key13     : list of key ENV:D_keys13, keyend = ENV:D_key13, ("printer", ENV:D_key13b, ENV:D_keys13c)

PDTEND no_file_list abbreviations switchglomming pdt_warnings
end-of-PDT

@MM = split /\n/, <<'end-of-MM';
expar_test.pl

       This script simply tests the ExPar option parsing package.

       Examples:

         expar_test.pl
         expar_test.pl -usage_help
         expar_test.pl -help
         expar_test.pl -full_help
         expar_test.pl -partial_help

 .integer01
        Integer option #01.
 .integer02
        Integer option #02.
 .integer22
        Integer option #22.
end-of-MM

  ExPar \@PDT, \@MM, $OPT;

}

