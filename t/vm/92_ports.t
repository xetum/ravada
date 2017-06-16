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

    my $domain = create_domain($vm_name, $USER,'debian');

    my $remote_ip = '10.0.0.1';
    my $local_ip = $vm->ip;

    $domain->start(user => $USER, remote_ip => $remote_ip);

    my $client_ip = $domain->remote_ip();
    is($client_ip, $remote_ip);

    my $client_user = $domain->remote_user();
    is($client_user->id, $USER->id);

    _wait_ip($domain);
    ok($domain->ip,"[$vm_name] Expecting an IP for domain ".$domain->name.", got ".($domain->ip or '')) or return;

    my ($public_ip0, $public_port0) = $domain->expose(22);

    my ($public_ip, $public_port) = $domain->public_address(22);
    is($public_ip, $public_ip0);
    is($public_port, $public_port0);

    my ($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);

    is($n_rule,3,"Expecting rule for $remote_ip -> $local_ip:$public_port") or exit;

    my ($n_rule_nat) = search_iptables_rule_nat($local_ip, $remote_ip, $public_port);
    is($n_rule_nat,1,"Expecting nat rule for $remote_ip -> $local_ip:$public_port") or exit;

}

sub _wait_ip {
    my $domain = shift;
    return if $domain->_vm->type !~ /kvm|qemu/i;

    sleep 1;
    $domain->domain->send_key(Sys::Virt::Domain::KEYCODE_SET_LINUX,200, [28]);
    sleep 2;
    for ( 1 .. 6 ) {
        diag("sending enter to ".$domain->name);
        $domain->domain->send_key(Sys::Virt::Domain::KEYCODE_SET_LINUX,200, [28]);
        sleep 1;
    }
    for (1 .. 20) {
        last if $domain->ip;
        sleep 1;
        diag("waiting for ".$domain->name." ip") if $_ ==10;
    }
    return $domain->ip;
}

sub add_network_10 {
    my $requires_password = shift;
    $requires_password = 1 if !defined $requires_password;

    my $sth = $test->connector->dbh->prepare(
        "DELETE FROM networks where address='10.0.0.0/24'"
    );
    $sth->execute;
    $sth = $test->connector->dbh->prepare(
        "INSERT INTO networks (name,address,all_domains,requires_password)"
        ."VALUES('10','10.0.0.0/24',1,?)"
    );
    $sth->execute($requires_password);
}


# Before messing with ports, everything worked for spice
sub test_no_ports {
    my $vm_name = shift;

    my $vm = rvd_back->search_vm($vm_name);

    my $domain = create_domain($vm_name, $USER);

    $domain->shutdown_now(user => $USER)    if $domain->is_active;
    ok(!$domain->is_active,"Expecting domain not active, got "
        .($domain->is_active or 0)) or exit;

    my $remote_ip = '10.0.0.1';
    my $local_ip = $vm->ip;
    my $local_port;

    my ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 0,"[$vm_name] Expecting no chain, got ".Dumper($chain))
        or return;

    ($n_rule, $chain) = search_iptables_rule_nat($local_ip, $remote_ip,);
    is($n_rule,0, Dumper($chain));

    $domain->start(user => $USER, remote_ip => $remote_ip);
    my $display = $domain->display($USER);
    ($local_ip, $local_port) = $display =~ m{(\d+\.\d+\.\d+\.\d+):(\d+)};
    ok(defined $local_port, "Expecting a port in display '$display'")
        or return;

    ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 1,"[$vm_name] Expecting 1 chain, got ".Dumper($chain));

    ($n_rule, $chain) = search_iptables_rule_nat($local_ip, $remote_ip,);
    is($n_rule,0, "[$vm_name] Expecting no NAT chain, got ".Dumper($chain));

    # after shutdown
    #
    $domain->shutdown_now($USER);

    ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 0,"[$vm_name] Expecting no chain, got ".Dumper($chain));

    ($n_rule, $chain) = search_iptables_rule_nat($local_ip, $remote_ip,);
    is($n_rule,0,"[$vm_name] Expecting no NAT chain, got ".Dumper($chain));

    # start again
    #
    $domain->start(user => $USER, remote_ip => $remote_ip);
    $display = $domain->display($USER);
    ($local_ip, $local_port) = $display =~ m{(\d+\.\d+\.\d+\.\d+):(\d+)};
    ok(defined $local_port, "Expecting a port in display '$display'")
        or return;

    ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 1,"[$vm_name] Expecting 1 chain, got ".Dumper($chain))
        or exit;

    ($n_rule, $chain) = search_iptables_rule_nat($local_ip, $remote_ip,);
    is($n_rule,0, "[$vm_name] Expecting no NAT chain, got ".Dumper($chain))
        or exit;

    my $public_ip_domain = $domain->public_address();
    is($public_ip_domain, $vm->ip);

    my ($public_ip_address, $public_port_address) = $domain->public_address(22);
    is($public_ip_address,undef);
    is($public_port_address,undef);

    $domain->remove($USER);

    # after remove

    ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 0,"[$vm_name] Expecting no Ravada chain, got "
                                .Dumper($chain));

    ($n_rule, $chain) = search_iptables_rule_nat($local_ip, $remote_ip,);
    is($n_rule,0,"[$vm_name] Expecting no NAT chain, got ".Dumper($chain));

}

##############################################################

clean();
flush_rules();

add_network_10(0);

for my $vm_name ( sort keys %ARG_CREATE_DOM ) {

    test_one_port($vm_name);
    test_no_ports($vm_name);

}

flush_rules();
clean();
done_testing();
