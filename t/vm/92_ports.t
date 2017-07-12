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

    _wait_ip($vm_name, $domain);

    my $domain_ip = $domain->ip;
    ok($domain_ip,"[$vm_name] Expecting an IP for domain ".$domain->name.", got ".($domain_ip or '')) or return;

    my $internal_port = 22;
    my ($public_ip0, $public_port0);
    eval {
       ($public_ip0, $public_port0) = $domain->expose($USER,$internal_port);
    };
    is($@,'');

    is(scalar $domain->list_ports,1);

    my ($public_ip, $public_port) = $domain->public_address($internal_port);
    is($public_ip, $public_ip0);
    is($public_port, $public_port0);

    my ($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);

    is($n_rule,3,"Expecting rule for $remote_ip -> $local_ip:$public_port") or exit;

    my ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);
    is($n_rule_nat,1,"Expecting nat rule for $local_ip:$public_port "
                ."-> ".$domain_ip.":$internal_port") or exit;

    #################################################################
    #
    # shutdown
    local $@ = undef;
    eval { $domain->shutdown_now($USER) };
    is($@, '');

    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);
    is($n_rule,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule ");

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);

    is($n_rule_nat,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule_nat ");

    #################################################################
    # start
    #
    $domain->start(user => $USER, remote_ip => $remote_ip);

($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);

    is($n_rule,3,"Expecting rule for $remote_ip -> $local_ip:$public_port") or do { dump_all_rules('filter','RAVADA'); exit};

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);
    is($n_rule_nat,1,"Expecting nat rule for $local_ip:$public_port "
                ."-> ".$domain_ip.":$internal_port") or exit;

    #################################################################
    #
    # remove
    local $@ = undef;
    eval { $domain->remove($USER) };
    is($@, '');

    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);
    is($n_rule,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule ");

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);

    is($n_rule_nat,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule_nat ");

}

# Remove expose port
sub test_remove_expose {
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

    my $domain_ip = $domain->ip;
    ok($domain_ip,"[$vm_name] Expecting an IP for domain ".$domain->name.", got ".($domain_ip or '')) or return;

    my $internal_port = 22;
    my ($public_ip0, $public_port0) = $domain->expose($USER,$internal_port);

    is(scalar $domain->list_ports,1);

    my ($public_ip, $public_port) = $domain->public_address($internal_port);
    is($public_ip, $public_ip0);
    is($public_port, $public_port0);

    my ($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);

    is($n_rule,3,"Expecting rule for $remote_ip -> $local_ip:$public_port") or exit;

    my ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);
    is($n_rule_nat,1,"Expecting nat rule for $local_ip:$public_port "
                ."-> ".$domain_ip.":$internal_port") or exit;

    #################################################################
    #
    # remove expose
    local $@ = undef;
    eval { $domain->remove_expose($USER,$internal_port) };
    is($@, '');

    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);
    is($n_rule,0,"[$vm_name] Expecting 0 rules for "
                    ."$remote_ip -> $local_ip:$public_port "
                    ." got $n_rule ") or exit;

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);

    is($n_rule_nat,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule_nat ");

    {
    my @sql_rules = search_sql_iptables($local_ip, $remote_ip);
    is(scalar(@sql_rules),2,"[$vm_name] Expecting 0 rules for"
        ." $remote_ip -> $local_ip, got "
        .scalar @sql_rules." ".Dumper(\@sql_rules)) or exit;
    }

    $domain->shutdown_now($USER);
    {
    my @sql_rules = search_sql_iptables($local_ip, $remote_ip);
    is(scalar(@sql_rules),0,"[$vm_name] Expecting 0 rules for"
        ." $remote_ip -> $local_ip, got "
        .scalar @sql_rules." ".Dumper(\@sql_rules)) or exit;
    }

}

# Remove crash a domain and see if ports are closed after cleanup
sub test_crash_domain {
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

    my $domain_ip = $domain->ip;
    ok($domain_ip,"[$vm_name] Expecting an IP for domain ".$domain->name.", got ".($domain_ip or '')) or return;

    my $internal_port = 22;
    my ($public_ip0, $public_port0) = $domain->expose($USER,$internal_port);

    is(scalar $domain->list_ports,1);

    my ($public_ip, $public_port) = $domain->public_address($internal_port);
    is($public_ip, $public_ip0);
    is($public_port, $public_port0);

    my ($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);

    is($n_rule,3,"Expecting rule for $remote_ip -> $local_ip:$public_port") or exit;

    my ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);
    is($n_rule_nat,1,"Expecting nat rule for $local_ip:$public_port "
                ."-> ".$domain_ip.":$internal_port") or exit;

    #################################################################
    #
    # shutdown forced
    eval { $domain->domain->destroy() };
    is($@,'');

    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);
    is($n_rule,3,"[$vm_name] Expecting 3 rules for "
                    ."$remote_ip -> $local_ip:$public_port "
                    ." got $n_rule ") ;

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);

    is($n_rule_nat,1,"[$vm_name] Expecting 1 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule_nat ");

    {
    my @sql_rules = search_sql_iptables($local_ip, $remote_ip);
    is(scalar(@sql_rules),2,"[$vm_name] Expecting 2 rules for"
        ." $remote_ip -> $local_ip, got "
        .scalar @sql_rules) ;
    }


    my $domain2 = create_domain($vm_name, $USER,'debian');
    my $remote_ip2 = '1.2.3.4';

    $domain2->start(user => $USER, remote_ip => $remote_ip2)
        if !$domain2->is_active();

    {
    my @sql_rules = search_sql_iptables($local_ip, $remote_ip);
    is(scalar(@sql_rules),0,"[$vm_name] Expecting 0 rules for"
        ." $remote_ip -> $local_ip, got "
        .scalar @sql_rules);
    }

    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);
    is($n_rule,0,"[$vm_name] Expecting 0 rules for "
                    ."$remote_ip -> $local_ip:$public_port "
                    ." got $n_rule ") ;

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);

    is($n_rule_nat,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule_nat ");

}

sub test_two_ports {
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

    _wait_ip($vm_name, $domain);

    my $domain_ip = $domain->ip;
    ok($domain_ip,"[$vm_name] Expecting an IP for domain ".$domain->name.", got ".($domain_ip or '')) or return;

    my $internal_port1 = 1;
    my ($public_ip1, $public_port1) = $domain->expose($USER, $internal_port1);

    my $internal_port2 = 2;
    my ($public_ip2, $public_port2) = $domain->expose($USER, $internal_port2);
    is ($public_ip2, $public_ip1);

    ok($public_port1 ne $public_port2,"Expecting two different ports "
        ." $public_port1 $public_port2 ");


    my ($public_ip, $public_port) = $domain->public_address($internal_port1);
    is($public_ip, $public_ip1);
    is($public_port, $public_port1);

    # A rule for the first port
    my ($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port1);

    is($n_rule,3,"Expecting rule for $remote_ip -> $local_ip:$public_port1") or exit;


    # check ip and port for second expose
    ($public_ip, $public_port) = $domain->public_address($internal_port2);
    is($public_ip, $public_ip2);
    is($public_port, $public_port2);


    # A rule for the second port
    ($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port2);

    is($n_rule,5,"Expecting rule for $remote_ip -> $local_ip:$public_port2") or do {
        dump_all_rules('filter','RAVADA');
        exit;
};


    my ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port1
                        , $domain_ip, $internal_port1);
    is($n_rule_nat,1,"Expecting nat rule for $local_ip:$public_port1"
                ."-> ".$domain_ip.":$internal_port1") or exit;

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port2
                        , $domain_ip, $internal_port2);
    is($n_rule_nat,2,"Expecting nat rule for $local_ip:$public_port2"
                ."-> ".$domain_ip.":$internal_port2") or exit;

    local $@ = undef;
    eval { $domain->shutdown_now($USER) };
    is($@, '');
    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port1);
    is($n_rule,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port1 "
                    ." got $n_rule ");

    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port2);
    is($n_rule,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port2 "
                    ." got $n_rule ");

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port1
                        , $domain_ip, $internal_port1);

    is($n_rule_nat,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port1 "
                    ." got $n_rule_nat ");

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port2
                        , $domain_ip, $internal_port2);

    is($n_rule_nat,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port2 "
                    ." got $n_rule_nat ");

}

sub _wait_ip {
    my $vm_name = shift;
    my $domain = shift;
    return if $domain->_vm->type !~ /kvm|qemu/i;
    return $domain->ip  if $domain->ip;

    sleep 1;
    eval ' $domain->domain->send_key(Sys::Virt::Domain::KEYCODE_SET_LINUX,200, [28]) ';
    die $@ if $@;

    return if $@;
    sleep 2;
    for ( 1 .. 6 ) {
        diag("sending enter to ".$domain->name);
        eval ' $domain->domain->send_key(Sys::Virt::Domain::KEYCODE_SET_LINUX,200, [28]) ';
        die $@ if $@;
        sleep 1;
    }
    for (1 .. 30) {
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

    my ($n_rule_nat) = search_iptables_rule_nat($local_ip,qr(\d+)
                        ,qr(.*), qr(\d+));

    is($n_rule_nat,0, Dumper($chain));

    $domain->start(user => $USER, remote_ip => $remote_ip);
    my $display = $domain->display($USER);
    ($local_ip, $local_port) = $display =~ m{(\d+\.\d+\.\d+\.\d+):(\d+)};
    ok(defined $local_port, "Expecting a port in display '$display'")
        or return;

    ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 1,"[$vm_name] Expecting 1 chain, got ".Dumper($chain));

    my @sql_rules = search_sql_iptables($local_ip, $remote_ip);
    is(scalar(@sql_rules),2,"[$vm_name] Expecting 2 rules for"
        ." $remote_ip -> $local_ip, got "
        .scalar @sql_rules." ".Dumper(\@sql_rules)) or exit;

    ($n_rule_nat) = search_iptables_rule_nat($local_ip,qr(\d+)
                        ,qr(.*), qr(\d+));
    is($n_rule_nat,0, Dumper($chain));


    # after shutdown
    #
    $domain->shutdown_now($USER);

    ($n_rule, $chain) = search_iptables_rule_ravada($local_ip, $remote_ip);
    is($n_rule, 0,"[$vm_name] Expecting no chain, got ".Dumper($chain));

    ($n_rule_nat) = search_iptables_rule_nat($local_ip,qr(\d+)
                        ,qr(.*), qr(\d+));
    is($n_rule_nat,0,"[$vm_name] Expecting no NAT chain, got ".Dumper($chain));

    @sql_rules = search_sql_iptables($local_ip,$remote_ip);
    is(scalar(@sql_rules),0,"Expecting 0 SQL rules, got "
        .scalar @sql_rules." ".Dumper(\@sql_rules)) or exit;
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

    ($n_rule_nat) = search_iptables_rule_nat($local_ip,qr(\d+) 
                        ,qr(.*), qr(\d+));

    is($n_rule_nat,0, "[$vm_name] Expecting no NAT chain, got ".Dumper($chain))
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

    ($n_rule_nat) = search_iptables_rule_nat($local_ip,qr(\d+) 
                        ,qr(.*), qr(\d+));

    is($n_rule_nat,0, Dumper($chain));


}

# expose a port when the host is down
sub test_host_down {
    my $vm_name = shift;

    my $vm = rvd_back->search_vm($vm_name);

    my $domain = create_domain($vm_name, $USER,'debian');

    my $remote_ip = '10.0.0.1';
    my $local_ip = $vm->ip;

    $domain->shutdown_now($USER)    if $domain->is_active;

    my $internal_port = 22;
    my ($public_ip0, $public_port0);
    eval { ($public_ip0, $public_port0) = $domain->expose($USER,$internal_port) };
    is($@,'') or return;

    $domain->start(user => $USER, remote_ip => $remote_ip);

    my $client_ip = $domain->remote_ip();
    is($client_ip, $remote_ip) or exit;

    my $client_user = $domain->remote_user();
    is($client_user->id, $USER->id);

    _wait_ip($vm_name, $domain);

    my $domain_ip = $domain->ip;
    ok($domain_ip,"[$vm_name] Expecting an IP for domain ".$domain->name.", got ".($domain_ip or '')) or return;


    is(scalar $domain->list_ports,1);

    my ($public_ip, $public_port) = $domain->public_address($internal_port);
    is($public_ip, $public_ip0);
    is($public_port, $public_port0);

    my ($n_rule)
        = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);

    is($n_rule,3,"Expecting rule for $remote_ip -> $local_ip:$public_port") or exit;

    my ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);
    is($n_rule_nat,1,"Expecting nat rule for $local_ip:$public_port "
                ."-> ".$domain_ip.":$internal_port") or exit;

    local $@ = undef;
    eval { $domain->shutdown_now($USER) };
    is($@, '');

    ($n_rule) = search_iptables_rule_ravada($local_ip, $remote_ip, $public_port);
    is($n_rule,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule ");

    ($n_rule_nat) = search_iptables_rule_nat($local_ip, $public_port
                        , $domain_ip, $internal_port);

    is($n_rule_nat,0,"[$vm_name] Expecting 0 rules for $remote_ip -> $local_ip:$public_port "
                    ." got $n_rule_nat ");

}

##############################################################

clean();

add_network_10(0);

for my $vm_name ( sort keys %ARG_CREATE_DOM ) {

    my $vm = rvd_back->search_vm($vm_name);
    next if !$vm;

    diag("Testing $vm_name");
    flush_rules();
    test_no_ports($vm_name);
    test_one_port($vm_name);
    test_no_ports($vm_name);

    test_host_down($vm_name);

    test_two_ports($vm_name);
}

flush_rules();
clean();
done_testing();
