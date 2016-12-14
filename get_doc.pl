#!/usr/bin/perl -w

#
# (c) Geocrime, 2004. Released under GNU GPL2.
#
# This script converts an input source, consisting of CPU instruction set
# reference sections, to an rtf-formated file, which is suitable for
# processing by windows help compiler. Can handle various input formats, but
# the deafault is for Hackman v5.01 disassembler. Can also produce various
# output formats.
#

use strict;

#$main::MAP;
#%main::map_hash;
#%main::aliases;
#%main::conf;
#%main::indentry;

my ($key, $inst);
my @alias;
my $fold;

usage() unless ($#ARGV >= 2);

# Default pasrser. Parsers can be plugged in as modules, containing the 
# fold_alternative sub. 

if ($ARGV[1] eq 'hackman') {
  $fold = \&fold_hackman;
  } else {
  do $ARGV[1];
  $fold = \&fold_alternative;
  };

# Process parser.conf
  if (!open(MAP, "<$ARGV[2]")) {
	print STDERR "$ARGV[2]: $!\n";
        exit;
        }

  while (<MAP>) {
    chomp;
    ($inst, $key, @alias) = split(',', $_);
    $key = uc $key;
    if ($inst ne '#') {
      $main::conf{$key} = $inst;
      foreach $inst (@alias) { push @{$main::aliases{$key}}, uc $inst }
      }
    }
  close MAP;

if ($ARGV[0] eq 'html') {
  print "<HTML>\n<HEAD></HEAD>\n<BODY>\n";
  &{$fold}(\&format_html);
  print "</BODY>\n</HTML>\n";
} elsif ($ARGV[0] eq 'hlprtf') {
  print "{\\rtf1\n";
  print "\\deff1{\\fonttbl{\\f1\\fnil default;}}\n";
  print "!{\\footnote JumpKeyword(Contents)}\n\\page\n";

  if (!open(MAP, ">$ARGV[3]")) {
	print STDERR "$ARGV[3]: $!\n";
        exit;
        }
  $ARGV[3] =~ s/\./_/g;
  $ARGV[3] = uc $ARGV[3]; 
  print MAP "#ifndef $ARGV[3]\n#define $ARGV[3]\t1\n\n";
  &{$fold}(\&format_hlprtf);
  print MAP "\n\n/* Here comes a list of collisions ;-(( */\n\n/*\n";
  foreach $key (keys %main::map_hash) {
    print MAP sprintf("0x%08X: %d\n", $key, $main::map_hash{$key})
      unless $main::map_hash{$key}==1;
    }
  print MAP "*/\n";
  print MAP "\n\n#endif /* $ARGV[3] */\n";
  close MAP;

  print <<EOF;
\\section
\${\\footnote Contents}
\#{\\footnote Contents}
\K{\\footnote Contents}
{\\b\\fs30 Contents}
\\par
EOF
#!{\\footnote Search()}
  foreach $key (sort keys %main::indentry) {
    print "\\par {\\uldb $main::indentry{$key}}";
#    print "{\\v\"$key,$key\"}\n";
    print "{\\v!{\\footnote KLink(\"$key,$key\")}}\n";
    }
  print "}\n";
} elsif ($ARGV[0] eq 'tex') {
  print <<EOF;
\\documentclass{book}
\\begin{document}
EOF

  &{$fold}(\&format_tex);
print <<EOF;
\\end{document}
EOF
} else {
  usage();
}

sub usage()
{
  print STDERR "usage: get_doc.pl hlprtf|html|tex parser parserconf [mapfile]\n";
  exit;
}

sub fold_hackman
{
my ($format) = @_;
my $state;
my (@inst, @section);
my (@i, $a);
my ($line, $string, $sec);
my $cntr = 1;

# $state:
# 0 - initial
# 1 - inside instruction, waiting suboptions
# 2 - inside suboption
# 3 - ignore current section

$state = 0;
$string = "";
@inst = ();
@section = ('');

while (<Modules/Module*.dat>) {
  open(STDIN, $_);

while(<STDIN>) {
  chomp;

# Begin of instruction description
  if ( ($_ =~ /^<[^\/](.+)>/) && ( ($state == 0) || ($state == 1) ) ) {
    ($i[0], $i[1], $i[2]) = split /<(.+)>/;
    $state = 1;
    if (defined $main::conf{$i[1]}) {
      if ($main::conf{$i[1]} eq '+') {
        foreach $a (@{$main::aliases{$i[1]}}) {
          push @inst, $a;
          }
        } elsif ($main::conf{$i[1]} eq '-') {
          next
        } elsif ($main::conf{$i[1]} eq 'x') {
          $sec = 0;
          $state = 3;
          }
      }
    push @inst, $i[1];
    next;
    }

# Begin of instruction description subsection
  if ( ($_ =~ /^\[\d\]/) && ( ($state==1) || ($state==2) )  && ($state!=3)) {
    $state = 2;
    $section[$sec] = $string
      if $string; # Not empty
    ($i[0], $sec, @i) = split /[(\D+)]/;
    $string = "";
    next;
    }

# End of instruction description
  if ( $_ =~ /^<\/(.+)>/ ) {
    print &{$format}(\@inst, \@section)
      if $#section && ($state != 3);
    $state = 0; # Reset to initial state
    @section = ('');
    @inst = ();
    $sec = "";
    next;
    }

# Subsection contents
  if ($state != 3) {
    ($i[0], $line, @i) = split /"(.*)"/;
    $string .= $line
      if $line; # Not empty
    $string .= "\n";
  }
  } # while
  } # while()
} # sub fold_hackman

sub format_html
{
my ($key, $section) = @_;
my ($text, $sec, $inst, $anchors, $instructions);
my @secname = ('', 'Description', 'Operation', 'Flags affected', 'Exceptions', 'Opcode');

for ($sec=1; $sec <= $#$section; $sec++) {

# First, escape the special chars
#  $$section[$sec] =~ s///g;

  $$section[$sec] =~ s/\xAC/<-/g;
  $$section[$sec] =~ s/\x09/     /g;
  $$section[$sec] =~ s/\x96/-/g;
  $$section[$sec] =~ s/\x99/(tm)/g;
  $$section[$sec] =~ s/\xAE/(r)/g;
  $$section[$sec] =~ s/\xB3//g;
  $$section[$sec] =~ s/\x95/-/g; # bullet
  $$section[$sec] =~ s/\x97/--/g; # --
  $$section[$sec] =~ s/\xB9/!=/g; # not equal 
  $$section[$sec] =~ s/\xCD/N/g;
  $$section[$sec] =~ s/\xC1/A/g;
  $$section[$sec] =~ s/\xA5/(infinity)/g;
  $$section[$sec] =~ s/\xC5/E/g;
  $$section[$sec] =~ s/\xAC//g;
  $$section[$sec] =~ s/\x92/'/g;
  $$section[$sec] =~ s/\xB1//g;
  $$section[$sec] =~ s/\xA3//g;
  $$section[$sec] =~ s/\x94/&quot;/g;
  $$section[$sec] =~ s/\x93/&quot;/g;

  $$section[$sec] =~ s/&/&amp;/g;
  $$section[$sec] =~ s/</&lt;/g;
  $$section[$sec] =~ s/>/&gt;/g;

  $$section[$sec] =~ s/\n\n/\n<p>/g;
  $$section[$sec] =~ s/\n/<BR>\n/g;

  $anchors = "";
  foreach $inst (@$key) {
    $anchors .= "<A NAME=\"$inst"."::"."$sec\"></A>\n";
    } # foreach $inst
  $inst = $$key[0];
  $instructions = join('/', @$key);
  $$section[$sec] = $anchors."\n<H3>$instructions</H3>\n<B>$secname[$sec]</B>\n<P>$$section[$sec]\n";
  }

$text = join('', @$section);
$text .= "<HR>";

return $text;
}

sub format_hlprtf
{
my ($key, $section) = @_;
my ($sec, $inst, $anchors, $instructions, $keywords, $hash);
my @secname = ('', 'Description', 'Operation', 'Flags affected', 'Exceptions', 'Opcode');

for ($sec=1; $sec <= $#$section; $sec++) {

  chomp $$section[$sec];

# First, escape the special chars
#  $$section[$sec] =~ s///g;

  $$section[$sec] =~ s/\xAC/<-/g;
  $$section[$sec] =~ s/\x09/\\tab/g;
  $$section[$sec] =~ s/\x96/-/g;
  $$section[$sec] =~ s/\x99/(tm)/g;
  $$section[$sec] =~ s/\xAE/(r)/g;
  $$section[$sec] =~ s/\xB3//g;
  $$section[$sec] =~ s/\x95/-/g; # bullet
  $$section[$sec] =~ s/\x97/--/g; # --
  $$section[$sec] =~ s/\xB9/!=/g; # not equal 
  $$section[$sec] =~ s/\xCD/N/g;
  $$section[$sec] =~ s/\xC1/A/g;
  $$section[$sec] =~ s/\xA5/(infinity)/g;
  $$section[$sec] =~ s/\xC5/E/g;
  $$section[$sec] =~ s/\xAC//g;
  $$section[$sec] =~ s/\x92/'/g;
  $$section[$sec] =~ s/\xB1//g;
  $$section[$sec] =~ s/\xA3//g;
  $$section[$sec] =~ s/\x94/"/g;
  $$section[$sec] =~ s/\x93/"/g;

  $$section[$sec] =~ s/\{/\\{/g;
  $$section[$sec] =~ s/\}/\\}/g;

  if ($sec == 1) {
    @_ = split '\n', $$section[$sec];
    $main::indentry{@$key[0]} = $_[0];
    } 

# Line breaks
  $$section[$sec] =~ s/\n/\n\\par /g;

  $anchors = "";
  $keywords = "";
  foreach $inst (@$key) {
    $anchors .= "#{\\footnote $inst"."::"."$sec}\n";
    $hash = crc32($inst, $sec);
    if (defined $hash) {
      $main::map_hash{$hash}++;
      print MAP "/* COLLISION! "
        unless $main::map_hash{$hash}==1;
      print MAP sprintf("%s::%s\t\t=0x%08X\n", $inst, $sec, $hash);
      print MAP "*/\n"
        unless $main::map_hash{$hash}==1;
      }
    $keywords .= "$inst,$inst;";
    } # foreach $inst
  $keywords .= join(",$secname[$sec];", @$key);
  $keywords .= ",$secname[$sec]";

  $instructions = join('/', @$key);
  $inst = $$key[0];

# Keywords
  $$section[$sec] = "\${\\footnote $inst,$secname[$sec]}\nK{\\footnote $keywords}\n$anchors\n{\\fs20\\b $instructions}\\tab{\\b $secname[$sec]}\\par\\par\n$$section[$sec]\n{\\page}\n\n";
  }

return join('', @$section);
}

sub format_tex
{
my ($key, $section) = @_;
my ($sec, $inst, $anchors, $instructions, $keywords, $hash, $text);
my @secname = ('', 'Description', 'Operation', 'Flags affected', 'Exceptions', 'Opcode');

$instructions = join('/', @$key);
$text = "\\section{$instructions}\n";
for ($sec=1; $sec <= $#$section; $sec++) {

  chomp $$section[$sec];

# First, escape the special chars
#  $$section[$sec] =~ s///g;

  $$section[$sec] =~ s/\xAC/\$\\leftarrow\$/g;
  $$section[$sec] =~ s/\x09/     /g;
  $$section[$sec] =~ s/\x99/(tm)/g;
  $$section[$sec] =~ s/\xAE/(r)/g;
  $$section[$sec] =~ s/\xB3//g;
  $$section[$sec] =~ s/\x96/-/g;
  $$section[$sec] =~ s/\x95/-/g; # bullet
  $$section[$sec] =~ s/\x97/--/g; # --
  $$section[$sec] =~ s/\xB9/\$\\neq\$/g; # not equal 
  $$section[$sec] =~ s/\xCD/N/g;
  $$section[$sec] =~ s/\xC1/A/g;
  $$section[$sec] =~ s/\xA5/(infinity)/g;
  $$section[$sec] =~ s/\xC5/E/g;
  $$section[$sec] =~ s/\xAC//g;
  $$section[$sec] =~ s/\x92/'/g;
  $$section[$sec] =~ s/\xB1//g;
  $$section[$sec] =~ s/\xA3//g;
  $$section[$sec] =~ s/\x94/"/g;
  $$section[$sec] =~ s/\x93/"/g;

  $$section[$sec] =~ s/\{/\\{/g;
  $$section[$sec] =~ s/\}/\\}/g;
  $$section[$sec] =~ s/#/\\#/g;
  $$section[$sec] =~ s/&/\\&/g;
  $$section[$sec] =~ s/\^/\\^/g;
  $$section[$sec] =~ s/\_/\\_/g;

# Line breaks
  $$section[$sec] =~ s/\n/\n\\par /g;

  $anchors = "";
  $keywords = "";
  foreach $inst (@$key) {
if (0) {
    $anchors .= "#{\\footnote $inst"."::"."$sec}\n";
    $hash = crc32($inst, $sec);
    if (defined $hash) {
      $main::map_hash{$hash}++;
      print MAP "/* COLLISION! "
        unless $main::map_hash{$hash}==1;
      print MAP sprintf("%s::%s\t\t=0x%08X\n", $inst, $sec, $hash);
      print MAP "*/\n"
        unless $main::map_hash{$hash}==1;
      }
}
    $keywords .= "$inst,$inst;";
    } # foreach $inst
  $keywords .= join(",$secname[$sec];", @$key);
  $keywords .= ",$secname[$sec]";

  $inst = $$key[0];

# Keywords
  $$section[$sec] = "%$inst,$secname[$sec]\n%%$keywords\n%$anchors\n\\subsection{$instructions   $secname[$sec]}\\par\\par\n$$section[$sec]\n\n";
  }

$text .= join('', @$section);
return $text."\\newpage\n";
}

sub crc32() 
{
my ($inst, $sec) = @_;
my ($crc, $string, @string, $i, $b);
my $POLY = 0xEDB88320; 

$string = $inst.$sec;

$crc = 0xFFFFFFFF;

@string = unpack('C*', uc $string);

  for ($i = 0; $i <= $#string; $i++) {
    $crc ^= $string[$i];
    for ($b=0; $b<8; $b++) {
      if ($crc & 1) {
        $crc = ($crc >> 1) ^ $POLY;
      } else {
        $crc >>= 1;
      }
    }
  }
  return ~$crc;
}

