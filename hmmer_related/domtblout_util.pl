#!/usr/bin/env perl

use warnings;
use strict;
use FindBin;
use List::Util qw(max);

sub usage{
    print <<USAGE;

perl $FindBin::Script <domtblout>

  Print uniq domains from a domtblout file

USAGE
    exit;
}

sub load_domtblout_file{
    my $file = shift;
    my $data;
    open my $fh, $file or die "$file: $!";
    while(<$fh>){
        next if /^\s*#/ or /^\s*$/;
        my @F            = split /\s+/;
        my $gene         = $F[0];
        my $query        = $F[3];
        my $evalue       = $F[6];
        my $bitscore     = $F[7];
        my $domain_index = $F[9];
        my $domain_num   = $F[10];
        my $c_evalue     = $F[11];
        my $i_evalue     = $F[12];
        my $hmm_from     = $F[15];
        my $hmm_to       = $F[16];
        my $ali_from     = $F[17];
        my $ali_to       = $F[18];
        my $env_from     = $F[19];
        my $env_to       = $F[20];
        push @{$data->{$gene}},
            {gene     => $gene,
             query    => $query,
             evalue   => $evalue, 
             c_evalue => $c_evalue,
             ali_from => $ali_from,
             ali_to   => $ali_to};
    }
    close $fh;
    return $data;
}

sub is_overlap{
    my @domains = @_;
    my $to   = max(map{$domains[$_]->{ali_to}}(0 .. $#domains - 1));
    return $domains[-1]->{ali_from} <= $to ? 1 : 0;
}

sub best_domain{
    my @domains = @_;
    my $best_domain = $domains[0];
    my $lowest_evalue = 10;
    for my $domain (@domains){
        if($domain->{c_evalue} < $lowest_evalue){
            $best_domain = $domain;
            $lowest_evalue = $domain->{c_evalue};
        }
    }
    return $best_domain;
}

sub print_domain{
    my $domain = shift;
    my $gene     = $domain->{gene};
    my $query    = $domain->{query};
    my $evalue   = $domain->{c_evalue};
    my $ali_from = $domain->{ali_from};
    my $ali_to   = $domain->{ali_to};
    print "$gene\t$ali_from\t$ali_to\t$query\t$evalue\n";
}

sub print_uniq_domains {
    my $data = shift;
    for my $gene (sort {$a cmp $b} keys %$data){
        my @domains = sort {$a->{ali_from} <=> 
                            $b->{ali_from}
                           }@{$data->{$gene}};
        for(my $i = 0; $i <= $#domains; $i++){
            my $begin = $i;
            for(my $j = $i + 1; $j <= $#domains; $j++){
                is_overlap(@domains[$begin..$j]) ?  $i++ : last;
            }
            my $end = $i;
            my $best = best_domain(@domains[$begin..$end]);
            print_domain($best);
        }
    }
}

sub main{
    usage unless @ARGV;
    my $file = shift @ARGV;
    my $data = load_domtblout_file($file);
    print_uniq_domains($data);
}

main() unless caller;

