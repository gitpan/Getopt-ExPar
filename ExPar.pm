$Getopt::ExPar::VERSION |= '0.01';

package Getopt::ExPar;

# ExPar.pm - Extended Parameters 0.01a
#
# Harlin L. Hamilton Jr. <mailto:hlhamilt@aud.alcatel.com>
#
# This package is free, and can be modified or redistributed under
# the same terms as Perl.

=head1 NAME

Getopt::ExPar - Extended Parameters command line parser.

=head1 SYNOPSIS

  use Getopt::ExPar;

  my(@PDT, @MM, %OPT);
  ExPar \@PDT, \@MM, $OPT;

=head1 EXPORT

C<use Getopt::ExPar> exports the sub C<ExPar> into your name space.

=head1 DESCRIPTION

B<ExPar> is a I<perl5> module used to parse command line parameters.  This package
uses the B<@PDT>, Parameter Description Table, and the B<@MM>, Message Module,
to return B<%OPT> which is a hash reference containing the command line option data.
The function of B<Getopt::ExPar> is based on B<Getopt::EvaP>, created by Stephen O. Lidie.

=head2 Introduction

The ExPar function parses a perl command line.  Using the option definitions in the
B<@PDT>, argument types are checked and the arguments themselves may be checked
against a specified range or pattern.  By using both B<@PDT> and B<@MM>, several
types of help may be retured to the user.  ExPar handles command lines with this
format:

  command [-parameters] [file_list]

where any parameters and file_list are optional.

=head2 Parameter Description Table (PDT) Syntax

Here is the PDT syntax.  Optional constructs are enclosed in [], and the
| character separates possible values in a list.

  PDT [program_name, alias]
    [parameter_name[, alias]: type [pattern | range] [ = [default_variable,] default_value]]
  PDTEND [flag_list]

I<flag_list> is one or more of the following flags:
  B<optional_file_list> | B<required_file_list> | B<no_file_list>:
    specifies condition of list of files at end of command line.  (only
    one of these may be specified)
  B<abbreviations>: allows for abbreviations of commands or aliases as long as
    enough of the command is given to make it distinguishable from all others.
    If not, a message is printed so the user may be more specific.
  B<switchglomming>: allows for multiple single-letter switch options
    to be specified as single option (must be first option).
  B<pdt_warnings>: for debugging a B<@PDT>, it prints out messages
    that are not necessarily errors, like inconsistent number of default
    values in a list, etc.

The I<default_variable> is an environment variable - see the section Usage Notes
for complete details.

So, the simplest possible PDT would be:

  PDT
  PDTEND

This PDT would simply define a I<-help> switch for the command, but is rather
useless.

A typical PDT would look more like this:

  PDT frog
    number, n: integer = 1
    chars, c: string = "default_string"
  PDTEND no_file_list

This PDT, for command frog, defines two parameters, number (or n), of type
integer with a default value of 1, and chars (or c), of type string with a
default value of "default_string".  The PDTEND I<no_file_list> indicator
indicates that no trailing file_list can appear on the command line.  Of
course, the I<-help> switch is defined automatically.

Each of these options may be further refined by using a range and a pattern,
respectively:

  PDT frog
    number, n: integer (((#<5) and (#%2==1)), ((#<20) and (#%2==0)), >100) = 1
    chars, c: string ('default_(optional_)?string') = "default_string"
  PDTEND no_file_list

Here, a I<range> is given for the number parameter.  This is a list of perl
conditional statements, separated with commas.  Each element in the list is
ORed together to construct a single condition with which the parameter value
is tested.  The '#' is substituted with the actual value, '1' in this instance.
For simple conditions like '>100', the '#' is implied.  Other simple conditions
are '<' and '==' (a single '=' is accepted as '==', not an assignment).
Ex:
  This condition:
    (#>10, #<-10, #==5, #=3, -5 < # <= 2)
  Can be reduced to:
    (>10, <-10, 5, 3, -5<#<=2)
  Notice that the compound condition, '-5<#<=2', MUST contain the '#'.

As for the 'number' parameter above, the range (or condition) is translated as:
(Less than 5 AND odd) OR (Less than 20 AND even) OR (Greater than 100)
So, '1' fits this condition.  These conditions may be as complex as you wish.
ENV variables may also be referenced within these range specifications.

The I<pattern> is a perl regular expression with which the value, in this case
"default_string", is tested.

=head2 Usage Notes

Currently, both B<@PDT> and B<@MM> are required, as is a reference to a
hash into which all parameter values are placed.  A call to ExPar *B<must>*
have this form:

  ExPar(\@PDT, \@MM, \%OPT);

An optional PDT flag can be included that tells ExPar whether or not
trailing file names can appear on the command line after all the
parameters.  It can read I<no_file_list>, I<optional_file_list> or
I<required_file_list> and, if not specified, defaults to optional.  Any flags
*B<must>* be on the PDTEND line, which is the last line of the B<@PDT> array.
Other flags include B<switchglomming> and B<pdt_warnings>.

The B<switchglomming> flag allows multiple single-letter switch parameters
to be specified as a single parameter.  Either the option name or its
alias must be a single letter to be used in the switch glom.
Ex: script.pl -x -f -c -a arga   --->    script.pl -xfc -a arga
The switch glo *B<must>* be the first option on the command line.
Note: this can be changed if heavily requested.

Additionally a Message Module is declared that describes the command
and provides examples.  Following the main help text an optional
series of help text messages can be specified for individual command
line parameters.  In the following sample program all the parameters
have this additional text which describes that type of parameter.  The
leadin character is a dot in column one followed by the full spelling
of the command line parameter.  Use I<-full_help> rather than I<-help>
to see this supplemental information.  This sample program illustrates
the various types and how to use B<ExPar()>.  The I<key> type is a
special type that enumerates valid values for the command line
parameter.  The I<boolean> type may be specified as TRUE/FALSE,
YES/NO, ON/OFF or 1/0.  Parameters of type I<file> have ~ and $HOME
expanded, and default values I<stdin> and I<stdout> converted to '-'
and '>-', respectively.  Of special note is the default value
I<$required>: when specified, ExPar will ensure a value is specified
for that command line parameter.

All types except I<switch> may be I<list of>, like the I<real70> parameter below.
A list parameter can be specified multiple times on the command line.
NOTE: in general you should ALWAYS quote components of your lists, even if
they are not type string, since Evaluate Parameters uses eval to parse them.
Doing this prevents eval from evaluating expressions that it should not, such
as file name shortcuts like $HOME, and backticked items like `hostname`.
Although the resulting PDT looks cluttered, Evaluate Parameters knows what
to do and eliminates superfluous quotes appropriately.
 
Finally, you can specify a default value via an environment variable.  If
a command line parameter is not specified and there is a corresponding
environment variable defined then Evaluate Parameters will use the value
of the environment variable.  Examine the I<command> parameter for the syntax.
With this feature users can easily customize command parameters to their
liking.   Although the name of the environment variable can be whatever you
choose,  the following scheme is suggested for consistency and to avoid
conflicts in names:  

=head1 EXAMPLE

@PDT = split /\n/, <<'end-of-PDT';
PDT expar_test
  switch01, sw01 : switch
  integer13, int13 : integer (5 < # <=  9) = 7
  real70 : list of real = ENV:D_real70, (45, 54)
  boolean07, bo07 : list of boolean = (1, "true")
  string17 : list of string ('s(?:tring)?17') = ENV:D_string17, ('string17a', 'string17b')
  string20        : list of string ("s(?:tring)?20") = \
    ENV:D_string20, (ENV:D_string20a, 'string20b')
  string21, str21 : string ("^\\\d{2,3}\\\w\\\d{2,8}\$") = "333x29445"
  name21, nm21 : name ('^\d{2,3}\w\d{2,8}') = $required
  file05, fl05 : file = "~"
  file06       : file = "$HOME/bin"
  file07, fl07 : file = '~other/bin'
  application08 : application = ENV:D_application08, `date`
  key13     : list of key ENV:D_keys13, keyend = ENV:D_key13, \
    ("printer", ENV:D_key13b, ENV:D_keys13c)
  set01, st01 : set of
    : integer (5 <= # <= 9)
    : real (5.0 <= # <= 9.0)
    : string ('pat01')
    : key ak, bk, ck, dk, keyend
  end set
  set02, st02 : list of set
    : integer (5 <= # <= 9) = (5, 7)
    : real (5.0 <= # <= 9.0) = (8.3, 5.0001)
    : string ('blah') = ("blah", "bbbbblahhhhh")
    : key ak, bk, ck, dk, keyend = ("ak", "dk")
  end set
PDTEND
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

 .switch01
    A switch type parameter is either off or on, returning a 0 or 1
    in the B<%OPT>: $OPT{'switch01'}.

 .integer13
    An integer type with a specified range and a default value.  Integers
    are checked against the pattern '[-+]?\d+', and, in this case, would
    check to make sure that any command line value is greater than 5 and
    less than or equal to 9.

 .real70
    An option of type real, checked against the following pattern:
    '[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?'.  The default
    values are 45 and 54.  There are two default values because this
    is a 'list of' type, which means that there may be multiple -real70
    options in the command line.  The value in B<%OPT> is an array
    reference: $OPT{'real70'} = [45, 54].
    Or, $OPT{'real70'}->[0] = 45, and
        $OPT{'real70'}->[1] = 54.

 .boolean07
    A boolean type, also a list, can have be given one of the following
    values: TRUE, FALSE, ON, OFF, 1, 0, YES, NO (case insensitive).
    Returns either a 1 or 0.

 .string17
    A string type, also a list, with a pattern with which to check any
    value specified in the command line.  Any default values are also
    checked against the specified pattern.  In this case, D_string17 is
    the default list, unless it does not exist, then the ending list
    is assigned as the default.  A string type is simply a string of
    characters surrounded by quotes, either single or double quotes.

 .string20
    Another list of string type, showing an ENV variable, D_string20a, in
    the default assignments.  Also, a \ character, backslash, can be placed
    at the end of a line in the B<@PDT> so that multiple lines may be used.

 .string21
    Still another string with a pattern surrounded by double-quotes.  Notice
    the use of multiple backslashes.  Always be careful when pattern matching
    on strings defined with single or double quotes.

 .name21
    The type name is treated identically to the type string.  It is included
    for backward compatibility with Getop::EvaP.

 .file05
    The type file is also the same as string type; however, $HOME and "~" are
    expanded to $ENV{'HOME'}.  Here the single '~' character is expanded.
    Patterns are also allowed in file declaraions.

 .file06
    Here, $HOME is expanded to $ENV{'HOME'}.

 .file07
    In this case, the '~' is followed by a non-slash character.  In UNIX, this
    generally refers to the home directory of another user, and the '~' is
    I<not> expanded. 

 .application08
    Treated as strings, but if surrounded by backtick characters, '`', it is
    assumed to be an application and the returned value of this application
    is stored.  In this case, if the ENV variable D_application08 is not
    defined, the default value of $OPT{'application08'} is set to what is
    returned from the 'date' command: 'Mon Nov  9 15:23:47 CST 1998'.

 .key13
    The type key is an enumerated type allowing the programmer to explicitly
    defined the possible values.  Although the key type is functionally
    equivalent to a string with a speicified pattern, it is left in for
    backward compatibility.  In this case, it is a list of keys whose
    key values are defined by the ENV variable D_keys13.

 .set01
    A new 'supertype'.  This allows for having multiple parameters for
    a single option.  From B<%OPT>, a set is an array of arrays, where each
    sub-array holds the value(s) of a sub-type.
    Ex:  script.pl -set01 6 6.5 'pppat011' ck
    $OPT{'set01'} = [ [ 6 ], [ 6.5 ], [ 'pppat011' ], [ 'ck' ] ];

 .set02
    A list of set.  Assuming to -set02 options specified on the command line:
    $OPT{'set01'} = [ [ 5, 7 ], [8.3, 5.0001], ["blah", "bbbbblahhhhh"], ["ak", "dk"] ];

end-of-MM

  ExPar \@PDT, \@MM, \%OPT; # evaluate parameters

=head1 HELP

There are several levels of help created from the B<@PDT> and B<@MM>.  It is
possible that the programmer may want to use one or more of these key options
in his B<@PDT>.  If this is the case, the built in functions can be accessed
by using two '-' characters instead of one.  Built in help functions include:

-help (-h)
-full_help (-fh)
-usage_help (-uh)
-partial_help (-ph)

Currently, with the 0.01 alpha version, there is not much variety in the help
options.  This author wanted to have a rudimentary help available, while getting
the package to end users for evaluation.  Using any one of these built in help
options outputs the B<@PDT> and B<@MM> in a text format.

=head2 Help

In development...

=head2 Full Help

In development...

=head2 Usage Help

In development...

=head2 Partial Help

=head1 PLANNED FEATURES

Here are a few ideas for future enhancements.  Currently, there is no support
for platforms other than UNIX and no support for languages other than Perl.
(What else could there be...:)

=head2 Partial Help Request

A user may only want help with a specific option or subset of options.  Using
I<-partial_help>, the user can view the help for only those options he/she
wishes.  This would be a subset of the I<-full_help>.

=head2 Required, A Better Specification

Whereas currently, to define an option to be required by the user, '= $required'
is placed at the end of a line in the PDT.  However, this method is limited.
A method of implementing a more explicit and elaborate definition of I<$required>
will be defined.  This is the current thought:

In the PDT, a I<$required> line may be placed in this manner:
  $required : ((opta and optb) or (opta and not optb and optc) or \
               (optc and optd and not optz))

This line is simply a Perl condition statement containing the names (or aliases)
of options defined in the PDT.  Multiple I<$required> lines may be ANDed together.

=head2 Command Parameter Completion

Some shells in UNIX allow for command completion where the first few letters of a
command is typed in and a completion-key, ESC or TAB, is pressed and the shell
determines if enough letters have been typed to distinguish from any other command.
Some shells allow a refinement of this by completing command parameters.  In I<tcsh>,
this is done with the I<complete> command.  For programs with a complex option set,
the I<complete> command can become near unmanagable.  This author proposes that by using
the B<@PDT>, a I<complete> command may be defined and returned to the user.

Perhaps by calling the perl script with a -complete (--complete) option only, a I<complete>
definition would be printed to STDOUT.

=head1 POSSIBLE FEATURES

=head2 Multiple Aliases

Although this would be fairly easy to do, it may not be necessary.  User feedback is
welcome.  Entries in B<@PDT> would resemble this:
  integer01, int01, i01, i1 : integer

=head2 User Requests

I will entertain any [sane] ideas that users may have...:)

=head1 NOTES

Currently, the help system is minimal, but I wanted to get this released to see
who might use it.

This is currently I<alpha> software.  There are no doubt bugs and shortcomings.
Please email me at B<hlhamilt@aud.alcatel.com> with questions, comments, feature
requests and bug reports.

=head1 VERSION HISTORY

=head2 0.01

First I<alpha> release.  Help funcions are minimal.  Might be buggy...:)

=head1 AUTHOR

Harlin L. Hamilton Jr.

=head2 Contact Info

B<mailto:hlhamilt@aud.alcatel.com>

=head2 Copyright

Copyright (C) 1998 Harlin L. Hamilton Jr..  All rights reserved.
This package is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut

#require 5.002;
use English;
use strict qw(refs subs);
use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(ExPar);
@EXPORT_OK = qw(expar);

*ExPar = \&expar;		# alias for Extended Parameters

sub expar {			# Parameter Description Table, Message Module

  my($ref_PDT, $ref_MM, $ref_OPT) = @ARG;

  #Make a local copy of the PDT and ARGV
  my($local_PDT);
  @{$local_PDT} = @{$ref_PDT};
  my($local_ARGV);
  @{$local_ARGV} = @ARGV;

  #Init various hashes
  my($PDT) = {};
  my($aliases) = {};

  #Define $pats and $types hashes.
  my($pats) = {};
  &expar_define_patterns($pats);
  my($types) = {};
  &expar_get_type_defs($pats, $types);

  #Define PDT entry pattern
  $pats->{'PDTentry'} =
    "(?i)$pats->{'optionName'}\\\s*:\\\s*(?:list\\\s+of\\\s+)?($pats->{'types'})";
  $pats->{'PDTsetentry'} = "(?i):\\\s*$pats->{'types'}";
  $pats->{'PDTsetof'} =
    "(?i)$pats->{'optionName'}\\\s*:\\\s*(?:list\\\s+of\\\s+)?" .
    "set(?:\\\s+of)?\\\s*(?:=\\\s*\$required\\\s*)?";

  #Define flags and initialize
  my(@flags) =
    ('abbreviations', 'switchglomming', 'optional_file_list',
     'required_file_list', 'no_file_list', 'pdt_warnings');
  my(%flags) = ();
  foreach (@flags) { $flags{$_} = 0; }

  my($line, $type); # vars for OPTIONS loop

OPTIONS:
  for ($i=0; $i <= $#{$local_PDT}; $i++) {

    #Assign current line in PDT to $line.
    $line = $local_PDT->[$i];
    while ($line =~ /\\\s*$/) {
      $line =~ s/\\\s*$/ /;
      $line .= $local_PDT->[++$i];
    }

    #Skip line if blank or first line
    next if (($line =~ /^\s*$/) or ($line =~ /^\s*PDT(?:\s+.+)\s*$/));

    #At PDTEND, check for flags and exit OPTIONS loop
    if ($line =~ /^\s*PDTEND/) {
      my($newline) = $line;
      foreach (keys %flags) {
        $flags{$_} = 1 if ($newline =~ s/\b($_)\b//);
      }
      &expar_PDTerr("*_file_list flags are mutually exclusive:", $i, $line)
        if (($flags{'optional_file_list'} +
             $flags{'required_file_list'} +
             $flags{'no_file_list'}) > 1);
      &expar_PDTerr("Unknown flag(s) '$1' in PDTEND:", $i, $line)
        if (($newline =~ /PDTEND(.*)$/) and ($1 !~ /^\s*$/));
      last OPTIONS;
    }

    #Check to see if this is the start of a set
    if (($option, $alias) = $line =~ /^\s*$pats->{'PDTsetof'}\s*/) {
      $alias = $option unless (defined $alias);

      #Warn user if option is already declared
      if (exists $PDT->{$option}) {
        &expar_PDTerr("$option redeclared, skipping set", $i, $line);
        while ($local_PDT->[$i] !~ /end\s+set/) { ++$i; }
        next OPTIONS;
      }

      #init some values
      $PDT->{$option} = {};
      $aliases->{$alias} = $option;
      $PDT->{$option}->{'alias'} = $alias;
      $PDT->{$option}->{'args'} = [];
      $PDT->{$option}->{'set'} = 1;
      $PDT->{$option}->{'list'} = ($line =~ /list\s+of/)? 1 : 0;
      $PDT->{$option}->{'required'} = ($line =~ s/\=\s*\$required\s*$//)? 1 : 0;
      my($setCnt) = 0;

      #Parse through each line of the set.
      while ($local_PDT->[++$i] !~ /^\s*end\s+set\s*$/) {
        $line = $local_PDT->[$i];
        next if ($line =~ /^\s*$/); # skip blank lines
	#If line matches a predefined type
        if (($type) = $line =~ /^\s*:\s*($pats->{'types'})\s*/) {
          #Add 'list of' to each line of set
          $line =~ s/:/: list of /
            if (($PDT->{$option}->{'list'}) and ($line !~ /:\s*list\s+of\s+/));

          #Can't have a switch in a set (doesn't make sense)
          &expar_PDTerr("type 'switch' found in set", $i, $line) and next
            if ($type eq 'switch');

          #Parse line in PDT by calling routine for specified type
          push(@{$PDT->{$option}->{'args'}},
            &{$types->{$type}->{'sub'}}($pats, $line, $i));

        #Error if didn't match predefined type
        } else {
          &expar_PDTerr("syntax error found in set", $i, $line);
        }
      }

    } elsif (($option, $alias, $type) = $line =~ /^\s*$pats->{'PDTentry'}\s*/) {

      #Warn user if option already declared
      &expar_PDTerr("$option redeclared", $i, $line) and next OPTIONS
        if (exists $PDT->{$option});

      #init some values
      $PDT->{$option} = {};
      $alias = $option unless (defined $alias);
      $PDT->{$option}->{'alias'} = $alias;
      $PDT->{$option}->{'list'} = ($line =~ /list\s+of\s+/)? 1 : 0;
      $aliases->{$alias} = $option;
      $PDT->{$option}->{'required'} = ($line =~ s/\=\s*\$required\s*$//)? 1 : 0;

      #If it's a switch, initialize to zero
      $ref_OPT->{$option} = 0 if ($type eq 'switch');

      #Parse line in PDT by calling routine for specified type
      $PDT->{$option}->{'args'} = &{$types->{$type}->{'sub'}}($pats, $line, $i);

    } else {

      &expar_PDTerr("syntax error", $i, $line);

    }

  }

  #Check for inconsistencies in PDT
  &expar_PDTchecks($PDT, $aliases, \%flags);

  my(@argMatch, $argument);
ARGUMENTS:
  for ($i=0; $i <= $#{$local_ARGV}; $i++) {
    $option = $local_ARGV->[$i];

    #Make sure argument starts with a '-'.  If not, then assume end of arg
    # list and check to see if trailing file names are permitted.
    if ($option !~ /^\-/) {
      if ($flags{'optional_file_list'} or $flags{'required_file_list'}) {
        @{$ref_OPT->{'file_list'}} = @{$local_ARGV}[$i .. $#{$local_ARGV}];
        last;
      }
      &expar_ARGEerr("bare word found in arguments: $option");
    } else {
      #Remove '-' from $option
      $option =~ s/^\-//;
    }

    #If option isn't found, check for abbreviations if allowed
    if ((not exists $PDT->{$option}) and
        (not exists $aliases->{$option}) and
        ($flag->{'abbreviations'})) {
      @argMatch = ();
      #Loop through all options and find all options that begin with $option
      foreach (keys %{$PDT}) {
        push(@argMatch, $_) if (/^$option/);
      }

      #Error if option string matches multiple options
      &expar_ARGVerr( "$option matches multiple options: " . join(',',@argMatch) )
        if ($#argMatch > 0);

      #Assign $option if one and only one match was found above
      $option = $argMatch[0] if ($#argMatch == 0);
    }

    #For first arg, see if it switch-glomming is allowed
    if ((not exists $PDT->{$option}) and
        (not exists $aliases->{$option}) and
        ($i == 0) and
        ($flags{'switchglomming'})) {
      my($opt) = $option; # local copy to be altered
      #Loop through all options to find the options of type switch
      foreach (keys %{$PDT}) {
        next if (exists $PDT->{$_}->{'set'}); # skip sets
        if ($PDT->{$_}->{'args'}->{'type'} eq 'switch') {
          if ((length($_) == 1) and ($opt =~ /$_/)) {
            $ref_OPT->{$_} = 1 if ($opt =~ s/$_//);
          } elsif ((length($PDT->{$_}->{'alias'}) == 1)  and ($opt =~ /$PDT->{$_}->{'alias'}/)) {
            $ref_OPT->{$_} = 1 if ($opt =~ s/$PDT->{$_}->{'alias'}//);
          }
        }
      }
      #Error if there were some left over switches
      &expar_ARGVerr("unknown option $option, \$opt = $opt") if (length($opt));
      next ARGUMENTS;
    }

    #Parse arguments, then check for validity, range, etc.
    if ((exists $PDT->{$option}) or
        ((exists $aliases->{$option}) and ($option = $aliases->{$option}))) {
      if ((not $PDT->{$option}->{'set'}) and
          (exists $PDT->{$option}->{'args'}->{'type'}) and
          ($PDT->{$option}->{'args'}->{'type'} eq 'switch')) {
        $ref_OPT->{$option} = 1;
      } elsif (exists $PDT->{$option}->{'set'}) { # If this is a set
        foreach (0 .. $#{$PDT->{$option}->{'args'}}) {
          $argument = $local_ARGV->[++$i];
          &expar_ARGVerr("$argument isn't the correct type for $option: " .
                         "$PDT->{$option}->{'args'}->[$_]->{'type'}")
           if ((exists $pats->{$PDT->{$option}->{'args'}->[$_]->{'type'}}) and
                ($argument !~ /^$pats->{$PDT->{$option}->{'args'}->[$_]->{'type'}}$/));
          &expar_ARGVerr("$argument doesn't match specified pattern: " .
                         "$PDT->{$option}->{'args'}->[$_]->{'pattern'}")
            if ((exists $PDT->{$option}->{'args'}->[$_]->{'pattern'}) and
                ($argument !~ /$PDT->{$option}->{'args'}->[$_]->{'pattern'}/));
          &expar_ARGVerr("$argument doesn't match specified key: " .
                         join(', ',keys %{$PDT->{$option}->{'args'}->[$_]->{'keys'}}))
            if ((exists $PDT->{$option}->{'args'}->[$_]->{'keys'}) and
                (not exists $PDT->{$option}->{'args'}->[$_]->{'keys'}->{$argument}));
          &expar_ARGVerr("$argument isn't in specified range for $option: " .
                         "$PDT->{$option}->{'args'}->[$_]->{'rangeStr'}")
            if ((exists $PDT->{$option}->{'args'}->[$_]->{'range'}) and
                (not &{$PDT->{$option}->{'args'}->[$_]->{'range'}}($argument)));
          if ($PDT->{$option}->{'list'}) {
            push(@{$ref_OPT->{$option}->[$_]}, $argument); # assign value
          } else {
            $ref_OPT->{$option}->[$_] = $argument; # assign value
          }
        }
      } else {
        $argument = $local_ARGV->[++$i];
        &expar_ARGVerr("$argument isn't the correct type: $PDT->{$option}->{'args'}->{'type'}")
          if ((exists $pats->{$PDT->{$option}->{'args'}->{'type'}}) and
              ($argument !~ /^$pats->{$PDT->{$option}->{'args'}->{'type'}}$/));
        &expar_ARGVerr("$argument doesn't match specified pattern: $PDT->{$option}->{'args'}->{'pattern'}")
          if ((exists $PDT->{$option}->{'args'}->{'pattern'}) and
              ($argument !~ /$PDT->{$option}->{'args'}->{'pattern'}/));
        &expar_ARGVerr("$argument doesn't match specified key: " .
                       join(', ',keys %{$PDT->{$option}->{'args'}->{'keys'}}))
          if ((exists $PDT->{$option}->{'args'}->{'keys'}) and
              (not exists $PDT->{$option}->{'args'}->{'keys'}->{$argument}));
        &expar_ARGVerr("$argument isn't in specified range for $option: $PDT->{$option}->{'args'}->{'rangeStr'}")
          if ((exists $PDT->{$option}->{'args'}->{'range'}) and
              (not &{$PDT->{$option}->{'args'}->{'range'}}($argument)));
          if ($PDT->{$option}->{'list'}) {
            push(@{$ref_OPT->{$option}}, $argument); # assign value
          } else {
            $ref_OPT->{$option} = $argument; # assign value
          }
      }
    } else {
      &expar_ARGVerr("-$option is not a defined option.");
    }

  }

  #Error if mssing a 'required' option
  foreach $option (keys %{$PDT}) {
    &expar_ARGVerr("Parameter $option is required but was omitted")
      if (($PDT->{$option}->{'required'}) and (not exists $ref_OPT->{$option}));
  }

  #Assign default value if exists
  foreach $option (keys %{$PDT}) {
    if ($PDT->{$option}->{'set'}) {
    } elsif ($PDT->{$option}->{'list'}) {
      @{$ref_OPT->{$option}} = @{$PDT->{$option}->{'args'}->{'default'}}
        if ((exists $PDT->{$option}->{'args'}->{'default'}) and
            (not exists $ref_OPT->{$option}));
    } else {
      $ref_OPT->{$option} = $PDT->{$option}->{'args'}->{'default'}
        if ((exists $PDT->{$option}->{'args'}->{'default'}) and
            (not exists $ref_OPT->{$option}));
    }
  }

  #Release some memory...
  $PDT = {};
  $aliases = {};
  $pats = {};

}

#################################################################################
# Routine to define the types: their patterns, and routines.  Hopefully, this
#  may make it easier to add types later on...
#################################################################################
sub expar_get_type_defs {
  my($pats, $types) = @_;
  my($type, $env);

  #Switch type
  $types->{'switch'}->{'sub'} = 
    sub {
        my($pats, $line, $i) = @_;
  
        #Check overall line for syntax error.
        &expar_PDTerr("Switch syntax error", $i, $line)
          unless ($line =~ /$pats->{'switchOption'}\s*$/);

        #Store option definition
        my($optionPtr) =
          { 'type' => 'switch',
          };

        #Return pointer to hash
        return $optionPtr;
    };

  #Key type
  $types->{'key'}->{'sub'} = 
    sub {
        my($pats, $line, $i) = @_;
        my($keyList, $default);
  
        #Check overall line for syntax error.
        &expar_PDTerr("Key syntax error", $i, $line)
          unless (($keyList, $default) =
                  $line =~ /$pats->{'keyOption'}\s*$/);

        #Store option definition
        my($optionPtr) =
          { 'type' => 'key',
            'list' => ($line =~ /:\s*list\s+of\s+/)? 1 : 0,
          };

        #Make a hash from a list of keys.
        $keyList =~ s/\s//g; # remove spaces

	#If keys are defined by ENV var:
        if (($env) = $keyList =~ /^ENV:(\w+)\s*,?$/) {
          &expar_PDTerr("ENV var $env is not defined\n\t", $i, $line)
            unless (exists $ENV{$env});
          foreach (eval $ENV{$env}) { $optionPtr->{'keys'}->{$_} = 1; }
        } else {
          %{$optionPtr->{'keys'}} =
            split(/,/, join(",1,", split(/,/, $keyList)) . ",1");
        }

        #If a default ENV var is given
        if ((defined $default) and ($default =~ /^\s*ENV:(\w+)(?:\s*,\s*(.+?))?\s*$/)) {
          &expar_PDTerr("ENV var $1 is not defined\n\t", $i, $line)
            if ((not exists $ENV{$1}) and (not defined $2));
          $default = (exists $ENV{$1})? $ENV{$1} : (defined $2)? $2 : undef;
        }

        #Assign default value(s)
        if (defined $default) {
          #Check for syntax error in default value if exists
          &expar_PDTerr("syntax error in default '$default'", $i, $line)
            if ((($optionPtr->{'list'}) and
                 ($default !~ /$pats->{'keyListDefault'}/)) or
                ((not $optionPtr->{'list'}) and
                 ($default !~ /$pats->{'keyDefault'}/)));

          #Check default keys to make sure that they match one of specified keys
          if ($optionPtr->{'list'}) {
            while (($env) = $default =~ /ENV:(\w+)/) {
              &expar_PDTerr("ENV var $env is not defined\n\t", $i, $line)
                unless (exists $ENV{$env});
              $env = $ENV{$env};
              #In case an element of the list is an ENV var defined as another list
              # Ex:
              # Assuming these ENV vars are set:
              #  setenv D_keys13 '("text", "plotter", "printer")'
              #  setenv D_key13b '"text"'
              #  setenv D_keys13c '("text", "plotter", "printer")'
              # This line:
              #  key13 : list of key ENV:D_keys13, keyend = ENV:D_key13, ("printer", ENV:D_keys13c)
              # Becomes:
              #  key13 : list of key text, plotter, printer, keyend = ("printer", ("text", "plotter", "printer"))
              $env =~ s/^\s*(?:[\"\']?\()?(.+?)(?:\)[\"?\'])\s*$/$1/;
              $default =~ s/ENV:\w+/$env/;
            }
            #Add to default array unless they don't match a valid key
            foreach (eval $default) {
              &expar_PDTerr("default '$_' does not match a specified key\n\t", $i, $line)
                unless (exists $optionPtr->{'keys'}->{$_});
              push(@{$optionPtr->{'default'}}, $_);
            }
          } else {
            #Set default unless it doesn't match a valid key
            &expar_PDTerr("default '$default' does not match a specified key\n\t", $i, $line)
              unless (exists $optionPtr->{'keys'}->{$default});
            $optionPtr->{'default'} = $default;
          }
        }

        #Return pointer to hash
        return $optionPtr;
    };

  #String, File, Name and Application types are handled identically...
  foreach $type (qw(string file name application)) {
    $types->{$type}->{'sub'} = 
      sub {
          my($pats, $line, $i) = @_;
          my($pattern, $default);
    
          #Check overall line for syntax error.
          &expar_PDTerr("$type syntax error", $i, $line)
            unless (($pattern, $default) =
                    $line =~ /$pats->{"${type}Option"}\s*$/);
  
          #Check pattern for syntax error
          &expar_PDTerr("syntax error in pattern: $pattern", $i, $line)
            if ((defined $pattern) and ($pattern !~ /$pats->{"${type}Pattern"}/));
  
          #Remove quotes if present
          $pattern =~ s/^[\'\"]?(.+?)[\'\"]?$/$1/ if (defined $pattern);
  
          #Store option definition
          my($optionPtr) =
            { 'type' => $type,
              'list' => ($line =~ /:\s*list\s+of\s+/)? 1 : 0,
            };
  
  	#If pattern is defined by ENV var:
          if ((defined $pattern) and (($env) = $pattern =~ /^ENV:(\w+)?$/)) {
            &expar_PDTerr("ENV var '$env' is not defined\n\t", $i, $line)
              unless (exists $ENV{$env});
            $pattern = $ENV{$env};
          }
  
          #Assign pattern if defined
          $optionPtr->{'pattern'} = $pattern if (defined $pattern);
  
          #If a default ENV var is given
          if ((defined $default) and ($default =~ /^\s*ENV:(\w+)(?:\s*,\s*(.+?))?\s*$/)) {
            &expar_PDTerr("ENV var $1 is not defined\n\t", $i, $line)
              if ((not exists $ENV{$1}) and (not defined $2));
            $default = (exists $ENV{$1})? $ENV{$1} : (defined $2)? $2 : undef;
          }
  
          #Assign default value(s)
          if (defined $default) {
            #Check for syntax error in default value if exists
            &expar_PDTerr("syntax error in default '$default'", $i, $line)
              if ((($optionPtr->{'list'}) and
                   ($default !~ /$pats->{"${type}ListDefault"}/)) or
                  ((not $optionPtr->{'list'}) and
                   ($default !~ /$pats->{"${type}Default"}/)));
  
            #Check default keys to make sure that they match one of specified keys
            if ($optionPtr->{'list'}) {
              while (($env) = $default =~ /ENV:(\w+)/) {
                &expar_PDTerr("ENV var $env is not defined\n\t", $i, $line)
                  unless (exists $ENV{$env});
                $env = $ENV{$env};
                #In case an element of the list is an ENV var defined as another list
                $env =~ s/^\s*(?:[\"\']?\()?(.+?)(?:\)[\"?\'])\s*$/$1/;
                $default =~ s/ENV:\w+/$env/;
              }
              #Add defaults to default array unless they don't match specified pattern
              foreach (eval $default) {
                if ($type eq 'file') {
                  s/(?:\$HOME\b|\~(?!\w))/$ENV{'HOME'}/g;
                  $_ = (/^(?i)stdin$/)? "-" : (/^(?i)stdout$/)? ">-" : $_;
                }
                $_ = eval $_ if (($type eq 'application') and (/^[\'\"]?\`.+?\`[\'\"]?$/));
                &expar_PDTerr("default '$_' does not match specified pattern\n\t", $i, $line)
                  if ((exists $optionPtr->{'pattern'}) and
                      (!/$optionPtr->{'pattern'}/));
                push(@{$optionPtr->{'default'}}, $_);
              }
            } else {
              #Set default unless it doesn't match a valid key
              $default =~ s/^[\"\']?(.+?)[\"\']?$/$1/;
              if ($type eq 'file') {
                $default =~ s/(?:\$HOME\b|\~(?!\w))/$ENV{'HOME'}/g;
                $default =
                  ($default =~ /^(?i)stdin$/)? "-" : ($default =~ /^(?i)stdout$/)? ">-" : $default;
              }
              $default = eval $default
                if (($type eq 'application') and ($default =~ /^[\'\"]?\`.+?\`[\'\"]?$/));
              &expar_PDTerr("default '$default' does not match specified pattern\n\t", $i, $line)
                if ((exists $optionPtr->{'pattern'}) and ($default !~ /$optionPtr->{'pattern'}/));
              $optionPtr->{'default'} = $default;
            }
          }
  
          #Return pointer to hash
          return $optionPtr;
      };
  }

  #Integer, Real and Boolean types are handled identically...
  foreach $type (qw(integer real boolean)) {

    #Integer/Real parsing routine.
    $types->{$type}->{'sub'} =
      sub {
        my($pats, $line, $i) = @_;
        my($range, $default, $ptr, @list);
  
        #Check overall line for syntax error.
        &expar_PDTerr("$type syntax error", $i, $line)
          unless (($range, $default) = $line =~ /$pats->{"${type}Option"}\s*$/);

        #However, no ranges allowed for booleans
        &expar_PDTerr("$type syntax error", $i, $line)
          if (($type eq 'boolean') and (defined $range));

        #Store option definition
        my($optionPtr) =
          { 'type' => $type,
            'list' => ($line =~ /:\s*list\s+of\s+/)? 1 : 0,
          };

        push(@list, \$range) if (defined $range);
        push(@list, \$default) if (defined $default);

        #Replace ENV references with actual ENV variables in range and default.
        foreach (@list) {
          while (($env) = $$_ =~ /ENV:(\w+)/) {
            &expar_PDTerr("ENV var '$env' not defined", $i, $line)
              unless (exists $ENV{$env});
            $env = $ENV{$env};
            #In case an element of the list is an ENV var defined as another list
            $env =~ s/^\s*(?:[\"\']?\()?(.+?)(?:\)[\"?\'])\s*$/$1/;
            $$_ =~ s/ENV:(\w+)/$env/;
          }
        }

        #Store the range as a string
        $optionPtr->{'rangeStr'} = "$range" if (defined $range);

        #Create sub reference to check_range routine, specific to specified range.
        $optionPtr->{'range'} = &expar_create_check_range_sub_ptr($pats, $range) if (defined $range);

        #Set default values if they match range (if specified)
        if (defined $default) {
          if ($optionPtr->{'list'}) {
            foreach (eval $default) {
              &expar_PDTerr("default $_ is not within specified range\n\t", $i, $line)
                if ((defined $range) and (not &{$optionPtr->{'range'}}($_)));
              push(@{$optionPtr->{'default'}}, $_);
            }
          } else {
            &expar_PDTerr("default $default is not within specified range\n\t", $i, $line)
              if ((defined $range) and (not &{$optionPtr->{'range'}}($default)));
            $optionPtr->{'default'} = $default;
          }
        }

# Removed this to allow for different types of ranges: #%2==0 (even number, etc.)
        #Check range for syntax error
#        &expar_PDTerr("syntax error in range: $range", $i, $line)
#          if ((defined $range) and ($range !~ /$pats->{"${type}Range"}/));

        #Check default for syntax error
        &expar_PDTerr("syntax error in default: $default", $i, $line)
          if ((defined $default) and
              (((not $optionPtr->{'list'}) and ($default !~ /^\s*$pats->{"${type}Default"}\s*$/)) or
               (($optionPtr->{'list'}) and ($default !~ /^\s*$pats->{"${type}ListDefault"}\s*$/))));

        #Return pointer to hash
        return $optionPtr;

      };

  }

  #Pattern to match any type name
  $pats->{'types'} = "(?:" . join('|', keys %{$types}) . ")";

}

#################################################################################
# Routine to build up a subroutine that checks a number to make sure that it's
# in the specified range of that option.
#################################################################################
sub expar_create_check_range_sub_ptr {
  my($pats, $range) = @_;

  #If $range is defined, return a routine pointer that returns either '1' or
  # '0', depending on whether or not the argument is in the range(s) specified.
  # Use of 'real' here is done purposely: values in option ranges don't need
  # to be limited to integers.
  $range =~ s/^\s*\(\s*(.+?)\s*\)\s*$/$1/;
  my(@range) = split(/,/,$range);
  my($sub) = "sub {my(\$x)=shift;return (";
  foreach (@range) {
    if      (/^\s*\#?={0,2}\s*($pats->{'real'})\s*$/) {
      $sub .= "(\$x == $1) or ";
    } elsif (/^\s*($pats->{'real'})\s*(<=?)\s*\#\s*(<=?)\s*($pats->{'real'})\s*$/) {
      $sub .= "(($1 $2 \$x) and (\$x $3 $4)) or ";
    } elsif (/^\s*\#?\s*([<>]=?)\s*($pats->{'real'})\s*$/) {
      $sub .= "(\$x $1 $2) or ";
    } elsif (s/\#/\$x/g) {
      $sub .= "($_) or ";
    } else {
      print STDERR "'$_' didn't match a range pattern in \&expar_create_range_sub_ptr.\n";
    }
  }
  $sub =~ s/\s*or\s*$//;
  $sub .= ")? 1 : 0;}";

  return eval "$sub"; # return pointer to sub that returns '1' or '0'

}

#################################################################################
# Routine to define some patterns for matching later on...
#################################################################################
sub expar_define_patterns {
  my($pats) = @_;

  $pats->{'optionName'} = "(\\\w+)(?:\\\s*,\\\s*(\\\w+))?\\\s*";
  $pats->{'ENV'} = "ENV:\\\w+";

  #Switch patterns
  $pats->{'switch'} = "\\\w+";
  $pats->{'switchOption'} = "\\\s*:\\\s*switch\\\s*";

  #Key patterns
  $pats->{'key'} = '[\'\"]?\w+[\'\"]?';
  $pats->{'keyDefault'} = "(?:$pats->{'key'}|$pats->{'ENV'})";
  $pats->{'keyList'} =
    "\\\(\\\s*$pats->{'keyDefault'}(?:\\\s*,\\\s*$pats->{'keyDefault'})*\\\s*\\\)";
  $pats->{'keyListDefault'} =
    "\\\(\\\s*$pats->{'keyDefault'}(?:\\\s*,\\\s*$pats->{'keyDefault'})*\\\s*\\\)";
#    "^\\\s*(?:$pats->{'keyList'}|$pats->{'ENV'}(?:\\\s*,\\\s*$pats->{'keyList'})?)\\\s*\$";
  $pats->{'keyOption'} =
    "(?i)\\\s*:\\\s*(?:list\\\s+of\\\s+)?key" .
      "\\\s+((?:$pats->{'key'}|$pats->{'ENV'})" .
      "(?:\\\s*,\\\s*(?:$pats->{'key'}|$pats->{'ENV'}))*\\\s*,|$pats->{'ENV'}\\\s*,?)" .
      "\\\s*keyend(?:\\\s*=\\\s*(.+))?";


  #String, File, Name and Application patterns
  foreach (qw(string name file application)) {
    $pats->{$_} = '(?:\'?[^\']+\'?|\"?[^\"]+\"?)';
    $pats->{"${_}OrENV"} = "(?:$pats->{$_}|$pats->{'ENV'})";
    $pats->{"${_}Pattern"} = "(?:$pats->{$_}|$pats->{'ENV'})";
    $pats->{"${_}Default"} = "(?:$pats->{$_}|$pats->{'ENV'})";
    $pats->{"${_}ListDefault"} =
      "\\\(\\\s*" . $pats->{"${_}Default"} . "(?:\\\s*,\\\s*" .
      $pats->{"${_}Default"} . ")*\\\s*\\\)";
    $pats->{"${_}Option"} =
      "(?i)\\\s*:\\\s*(?:list\\\s+of\\\s+)?$_" .
      "\\\s*(?:\\\(\\\s*(" . $pats->{"${_}Pattern"} . ")\\\s*\\\))?(?:\\\s*=\\\s*(.+))?";
  }

  #Integer and Real patterns
  $pats->{'boolean'} = "(?i)(?:true|false|0|1|yes|no|on|off)";
  $pats->{'integer'} = "\\\d+";
  $pats->{'real'} = '[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?';

  foreach (qw(real integer boolean)) {
    $pats->{"${_}OrENV"} = "(?:$pats->{$_}|$pats->{'ENV'})";
    $pats->{"${_}Default"} = "(?:$pats->{$_}|$pats->{'ENV'}(?:\\\s*,$pats->{$_})?)";
    $pats->{"${_}ListDefault"} =
      "(?:\\\(\\\s*[\\\'\\\"]?" . $pats->{"${_}OrENV"} . "[\\\'\\\"]?" .
      "(?:\\\s*,\\\s*[\\\'\\\"]?" . $pats->{"${_}OrENV"} . "[\\\'\\\"]?)*\\\s*\\\)|" .
      "$pats->{'ENV'})";
# Removed this to allow for different types of ranges: #%2==0 (even number, etc.)
#    $pats->{"${_}RangeElelment"} =
#      "(?:" . 
#       $pats->{"realOrENV"} . "\\\s*<=?\\\s*#\\\s*<=?\\\s*" . $pats->{"realOrENV"} . "|" .
#         "#?\\\s*[<>]=?\\\s*" . $pats->{"realOrENV"} . "|" .
#         "#?={0,2}" . $pats->{"realOrENV"} .
#      ")";
#    $pats->{"${_}Range"} =
#      "\\\(\\\s*" . $pats->{"${_}RangeElelment"} .
#        "(?:\\\s*,\\\s*" . $pats->{"${_}RangeElelment"} . ")*\\\s*\\\)";
    $pats->{"${_}Option"} =
      "(?i)\\\s*:\\\s*(?:list\\\s+of\\\s+)?${_}" .
	"\\\s*(\\\(.+?\\\))?(?:\\\s*=\\\s*(.+))?";
  }

}

#################################################################################
# Routine to check for some inconsistencies if pdt_warnings is set.
#  This routine could be time consuming...
#################################################################################
sub expar_PDTchecks {
  my($PDT, $aliases, $flags) = @_;
  my(@argMatch, $option, $defCnt, $hasDefs);

  #If pdt_warnings set, see if abbreviations might cause conflicts
  if ($flags->{'pdt_warnings'} and $flags->{'abbreviations'}) {
    foreach $option (keys %{$PDT}, keys %{$aliases}) {
      @argMatch = ();
      #Loop through all options and find all options that begin with $option
      foreach (keys %{$PDT}, keys %{$aliases}) {
        push(@argMatch, $_)
          if ((/^$option/) and ($_ ne $option));
      }

      #Give warning if option string matches multiple options
      &expar_PDTwarn( "$option matches multiple options: " . join(',',@argMatch) )
        if (($#argMatch > 0) or
            (($#argMatch == 0) and
             (exists $aliases->{$option}) and
             ($argMatch[0] ne $aliases->{$option})));
    }
  }

  #If pdt_warnings set, warn of inconsistent # of options in a set
  if ($flags->{'pdt_warnings'}) {
    foreach $option (keys %{$PDT}) {
      if ((exists $PDT->{$option}->{'set'}) and
          ($PDT->{$option}->{'set'})) {
        $hasDefs = $defCnt = 0;
        #Set $hasDefs to a '1' if defaults were given for first element in set
        if (exists $PDT->{$option}->{'args'}->
            [$#{$PDT->{$option}->{'args'}}]->{'default'}) {
          $hasDefs = 1;
          $defCnt = ($PDT->{$option}->{'list'})?
            $#{$PDT->{$option}->{'args'}->[$#{$PDT->{$option}->{'args'}}]->{'default'}} : 1;
        }
        #Loop through elements of set and print message if # of defaults are inconsistent
        foreach (0 .. $#{$PDT->{$option}->{'args'}}) {
          if (((not exists $PDT->{$option}->{'args'}->[$_]->{'default'}) and ($hasDefs)) or
              ((exists $PDT->{$option}->{'args'}->[$_]->{'default'}) and (not $hasDefs)) or
              (($PDT->{$option}->{'list'}) and
               (exists $PDT->{$option}->{'args'}->[$_]->{'default'}) and
               ($#{$PDT->{$option}->{'args'}->[$_]->{'default'}} != $defCnt))) {
            &expar_PDTwarn("inconsistent # of defaults in $option");
            last;
          }
        }
      }
    }
  }

}

#################################################################################
# Routine to print an error to STDERR concerning the PDT.
#################################################################################
sub expar_PDTerr {
  my($str, $linenum, $line) = @_;
  die "*** ExPar PDT error: $str on line '$line', line #$linenum.\n\n";
}

#################################################################################
# Routine to print a warning to STDERR concerning the PDT.
#################################################################################
sub expar_PDTwarn {
  my($str) = @_;
  warn "*** ExPar PDT warning: $str.\n\n";
}

#################################################################################
# Routine to print an error to STDERR concerning the command line arguments.
#################################################################################
sub expar_ARGVerr {
  my($str) = @_;
  die "*** ExPar ARGV error: $str.\n\n";
}
