use warnings;
use strict;

use Data::Dumper;
use JSON::XS;
use Test::More;
use Test::SQL::Data;
use IPTables::ChainMgr;

use lib 't/lib';
use Test::Ravada;

my $test = Test::SQL::Data->new(config => 't/etc/sql.conf');

use_ok('Ravada');

my $FILE_CONFIG = 't/etc/ravada.conf';

my @ARG_RVD = ( config => $FILE_CONFIG,  connector => $test->connector);

my %ARG_CREATE_DOM = (
      KVM => [ id_iso => 1 ]
    ,Void => [ ]
);

my $RVD_BACK = rvd_back($test->connector, $FILE_CONFIG);
my $USER = create_user("foo","bar");

##############################################################

# Forward one port
sub test_one_port {
    my $vm_name = shift;

    my $vm = rvd_back->search_vm($vm_name);

    my $domain = create_domain($vm_name, $USER,'xubuntu');

    my $remote_ip = '10.0.0.1';
    my $local_ip = $vm->ip;
    my $local_port;

    $domain->start(user => $USER, remote_ip => $remote_ip);
    for (1 .. 10) {
        last if $domain->ip;
        sleep 1;
    }
    ok($domain->ip,"Expecting an IP, got ".($domain->ip or ''));
    $domain->open_port(22);

    my ($public_ip, $public_port) = $domain->public_address(22);
    my ($n_rule, $chain)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $local_port);

    die Dumper($n_rule,$chain);
}

# Before messing with ports, everything worked for spice
sub test_no_ports {
    my $vm_name = shift;

    my $vm = rvd_back->search_vm($vm_name);

    my $domain = create_domain($vm_name, $USER);
    is($domain->is_active,undef) or exit;

    my $remote_ip = '10.0.0.1';
    my $local_ip = $vm->ip;
    my $local_port;

    my ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 0, Dumper($chain)) or exit;

    ($n_rule, $chain) = search_iptables_rule_nat($local_ip, $remote_ip,);
    is($n_rule,0, Dumper($chain));

    $domain->start(user => $USER, remote_ip => $remote_ip);
    my $display = $domain->display($USER);
    ($local_ip, $local_port) = $display =~ m{(\d+\.\d+\.\d+\.\d+):(\d+)};
    ok(defined $local_port, "Expecting a port in display '$display'") or return;
}

##############################################################

clean();
flush_rules();

for my $vm_name ( sort keys %ARG_CREATE_DOM ) {

    test_no_ports($vm_name);
}

flush_rules();
clean();
done_testing();
