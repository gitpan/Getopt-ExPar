#!/rwasics_apps/gnu/bin/perl -w

package Reference_Parser;

$Reference_Parser::VERSION = 1.0.0;

# Gen_Ref_Traversal_String.pm -
#    Generate Reference Traversal String 1.0.0 for Perl
#
# hlhamilt@rsn.hp.com, 04/25/97
#
# Harlin L. Hamilton Jr., Hewlett Packard.
#
# Copyright (C) 1997 by Harlin L. Hamilton Jr.  All rights reserved.
#

##################################################################
# Gen_Ref_Traversal_String returns a string that allows for easy
# readability of HASH/ARRAY data structures.  A hash or
# array reference is the first argument passed to
# Ref_Traversal_String.  An optional second argument is a string
# whose length gives an offset from the left side of the screen.
##################################################################

=head1

 Examples:

1)
#Program:
my($x) = { 'a' => { 'a' => [ 'a', 'b', 'c', ], 
                    'b' => 9,
                    'c' => 10, },
           'b' => 'asdf',
           'c' => [ 45, 56, 67, ], };

print "\$x->" . &reference_tree_string($x, "\$x->");

#Output:
$x->{ 'a' => { 'a' => [ a, #0
                        b, #1
                        c, ],
               'b' => 9,
               'c' => 10, },
      'b' => asdf,
      'c' => [ 45, #0
               56, #1
               67, ], }

2)
#Program:
my($x) = { 'a' => { 'a' => [ 'a', 'b', 'c', ], 
                    'b' => 9,
                    'c' => 10, },
           'b' => 'asdf',
           'c' => [ 45, 56, 67, ], };

print "\$x->" . &reference_tree_string($x);

#Output:
$x->{ 'a' => { 'a' => [ a, #0
                    b, #1
                    c, ],
           'b' => 9,
           'c' => 10, },
  'b' => asdf,
  'c' => [ 45, #0
           56, #1
           67, ], }


=cut

##################################################################

use strict;
use Exporter;
@Reference_Parser::ISA = qw(Exporter);
@Reference_Parser::EXPORT = qw(Reference_Tree_String);
@Reference_Parser::EXPORT_OK = qw(reference_tree_string);

*Reference_Tree_String = \&reference_tree_string;

sub reference_tree_string {
  my($ref,$pad) = @_;
  &reference_tree_string1($ref, $pad, 0);
}

sub reference_tree_string1 {
  my($ref,$pad,$level) = @_;
  my($str,$first,$line,$i);
  $str = '';
  $first = 1;
  $pad = "" unless defined $pad;
  if (ref($ref) eq 'ARRAY') {
    return "[ ],\n" if ($#{$ref} == -1);
    for ($i=0; $i<=$#{$ref}; $i++) {
      $line = ($i==0)? "[ " : ' ' x length($pad) . "  ";
      $line .=
        (defined $ref->[$i])? 
          (($i==0)? &reference_tree_string1($ref->[$i], ' ' x length($pad . $line), $level+1) :
                    &reference_tree_string1($ref->[$i], ' ' x length($line), $level+1)) : "''";
      chomp($line);
      $str .= $line . "\n";
    }
    chomp($str);
    $str .= " ]";
  } elsif ((ref($ref) eq 'HASH') or ((ref($ref) ne '') and ($ref =~ /=HASH/))) {
    return "{ },\n" if ((scalar keys %{$ref}) == 0);
    foreach (sort keys %{$ref}) {
      $line = ($first)? "{ " : ' ' x length($pad) . "  ";
      $line .= "'" . join( ", ", split(/$;/)) . "' => ";
      $line .= ($first)? &reference_tree_string1($ref->{$_}, ' ' x length($pad . $line), $level+1) :
                         &reference_tree_string1($ref->{$_}, ' ' x length($line), $level+1);
      $first = 0;
      chomp($line);
      $str .= $line . "\n";
    }
    chomp($str);
    $str .= " }";
  } else {
#    return "'$ref'\n" unless ($ref =~ /^\d+$/);
#    return "$ref\n";
    return "'$ref',\n";
  }
  return "$str;\n" if ($level == 0);
  return "$str,\n";
}

1;

