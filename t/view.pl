#!/usr/bin/perl

use warnings;
use strict;

sub view {
    my $display = shift;
    `remote-viewer $display`;
}

our %launched;
for (;;) {
    for my $domain (`virsh list --name`) {
        chomp $domain;
        next if $domain !~ /\w/;
        next if $launched{$domain}++;
        print "$domain\n";
        my $display= `virsh domdisplay $domain`;
        chomp $display;
        view($display);
    }
    sleep 1;
}
