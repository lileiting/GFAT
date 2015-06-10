#!/usr/bin/env perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::RealBin/../lib";
use fasta;

sub usage{
    print <<USAGE;

$FindBin::Script CMD [OPTIONS]

CMD:
  idlist Get ID list of a sequence file
  sort   Sort sequences by name
  rmdesc Remove sequence descriptions

USAGE
    exit;
}

sub read_commands{
    usage unless @ARGV;
    my @cmd = qw/idlist sort rmdesc/;
    my %cmd = map{$_ => 1}@cmd;
    my $cmd = shift @ARGV;
    warn "Unrecognized command: $cmd!\n" and usage unless $cmd{$cmd};
    return $cmd;
}

sub main{
    my $cmd = read_commands;
    if($cmd eq q/idlist/){
        idlist_fasta;
    }elsif($cmd eq q/sort/){
        sort_fasta;
    }elsif($cmd eq q/rmdesc/){
        rmdesc_fasta;
    }
}

main;