#!/usr/bin/env perl

use warnings;
use strict;
use Getopt::Long;
use FindBin;

sub base_usage{
    print <<USAGE;

perl $FindBin::Script CMD [OPTIONS]

  rmissing | remove rows with missing data("-")

  csv2tab  | Replace any comma to tab
  tab2csv  | Replace any tab to comma

  win2linux| Replace \\r\\n to \\n
  win2mac  | Replace \\r\\n to \\r
  linux2win| Replace \\n to \\r\\n
  linux2mac| Replace \\n to \\r
  mac2win  | Replace \\r to \\r\\n
  mac2linux| Replace \\r to \\n

  maxlen   | Max line length

USAGE
    exit;
}

sub base_main{
    base_usage unless @ARGV;
    my $cmd = shift @ARGV;
    if(   $cmd eq q/rmissing/ ){ &rmissing  } 
    elsif($cmd eq q/csv2tab/  ){ &csv2tab   }
    elsif($cmd eq q/tab2csv/  ){ &tab2csv   }
    elsif($cmd eq q/win2linux/){ &win2linux }
    elsif($cmd eq q/win2mac/  ){ &win2mac   }
    elsif($cmd eq q/linux2win/){ &linux2win }
    elsif($cmd eq q/linux2mac/){ &linux2mac }
    elsif($cmd eq q/mac2win/  ){ &mac2win   }
    elsif($cmd eq q/mac2linux/){ &mac2linux }
    elsif($cmd eq q/maxlen/   ){ &maxlen    }
    else{ warn "Unrecognized command: $cmd!\n"; base_usage }
}

base_main() unless caller;

###################
# Define commands #
###################

#
# Common subroutines
#

sub cmd_usage{
    my $cmd = shift;
    print <<USAGE;

perl $FindBin::Script $cmd [OPTIONS]

 [-i,--input]  FILE
 -o,--output   FILE
 -h,--help

USAGE
    exit;
}

sub get_options{
    my $cmd = shift;
    GetOptions(
        "input=s"  => \my $infile,
        "output=s" => \my $outfile,
        "help"     => \my $help
    );
    cmd_usage($cmd) if $help or (!$infile and @ARGV == 0 and -t STDIN);
    my ($in_fh, $out_fh) = (\*STDIN, \*STDOUT);
    $infile = shift @ARGV if (!$infile and @ARGV > 0);
    open $in_fh, "<", $infile or die "$infile: $!" if $infile;
    open $out_fh, ">", $outfile or die "$outfile: $!" if $outfile;

    return {
        in_fh => $in_fh,
        out_fh => $out_fh
    };
}

sub get_fh{
    my $cmd = shift;
    my $options = get_options($cmd);
    my $in_fh = $options->{in_fh};
    my $out_fh = $options->{out_fh};
    return ($in_fh, $out_fh);
}

#
# Command rmissing
#

sub present_missing{
    my $line = shift;
    chomp $line;
    my @F = split /\s+/;
    for my $i (@F){
        return 1 if $i eq q/-/;
    }
    return 0;
}

sub rmissing{
    my ($in_fh, $out_fh) = get_fh(q/rmissing/);
    while(<$in_fh>){
        next if present_missing($_);
        print $out_fh $_;
    }
}

#
# Command csv2tab and tab2csv
#

sub csv2tab{
    my ($in_fh, $out_fh) = get_fh(q/csv2tab/);
    while(<$in_fh>){
        s/,/\t/g;
        print $out_fh $_;
    }
}

sub tab2csv{
    my ($in_fh, $out_fh) = get_fh(q/tab2csv/);
    while(<$in_fh>){
        s/\t/,/g;
        print $out_fh $_;
    }
}

#
# Command win2linux, win2mac, linux2win, linux2mac, mac2win, mac2linux
#

sub new_line_convert{
    my($from, $to) = @_;
    my %new_line = (win   => "\r\n",
                    linux => "\n",
                    mac   => "\r");
    my ($in_fh, $out_fh) = get_fh($from."2".$to);
    local $/ = $new_line{$from};
    local $\ = $new_line{$to};
    while(<$in_fh>){ print $out_fh $_ }
}

sub win2linux { new_line_convert(qw/win linux/) }
sub win2mac   { new_line_convert(qw/win mac/)   }
sub linux2win { new_line_convert(qw/linux win/) }
sub linux2mac { new_line_convert(qw/linux mac/) }
sub mac2win   { new_line_convert(qw/mac win/)   }
sub mac2linux { new_line_convert(qw/mac linux/) }

# 
# Max line length
#

sub maxlen{
    my ($in_fh, $out_fh) = get_fh(q/maxlen/);
    my $maxlen = 0;
    while(<$in_fh>){
        chomp;
        $maxlen = length($_) if length($_) > $maxlen;
    }
    print $maxlen,"\n";
}
