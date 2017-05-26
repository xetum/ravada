use warnings;
use strict;

use Carp qw(confess);
use Data::Dumper;
use Hash::Util qw(lock_hash);
use IPC::Run3;
use Test::More;
use Test::SQL::Data;

use feature qw(signatures);
no warnings "experimental::signatures";

use lib 't/lib';
use Test::Ravada;

my $test = Test::SQL::Data->new(config => 't/etc/sql.conf');

use_ok('Ravada');
init($test->connector);

my $ID_ISO = search_id_iso('Ubuntu Mini');
my %ARG_CREATE_DOM = (
      KVM => [ id_iso => $ID_ISO ]
);

my @VMS = reverse keys %ARG_CREATE_DOM;
my $USER = create_user("foo","bar");

#################################################################
sub test_domain_display($vm_name){
    my $vm = rvd_back->search_vm($vm_name);

    my $net = Ravada::Network->new(address => '127.0.0.1/32');

    ok(!$net->requires_password);
    my $domain_name = new_domain_name();
    my $domain = $vm->create_domain( name => $domain_name
                , id_iso => $ID_ISO , id_owner => $USER->id);

    ok($domain->has_spice());
    ok(!$domain->has_x2go());
    ok(!$domain->has_rdp());

    my $domain_f = rvd_front->search_domain($domain->name);
    ok($domain_f->has_spice());
    ok(!$domain_f->has_x2go());

    is($domain->has_spice(),1);

    for my $val (0,1) {
        is($domain->has_spice($val),$val);
        is($domain->has_spice(),$val);
        $domain_f = rvd_front->search_domain($domain->name);
        is($domain_f->has_spice(),$val);
        is($domain->has_display('spice'),$val);

        eval {is($domain_f->has_spice($val+1),$val+1)};
        is($@,'');

        is($domain->has_x2go($val) ,$val);
        is($domain->has_x2go() ,$val);
        $domain_f = rvd_front->search_domain($domain->name);
        is($domain_f->has_x2go(), $val);
        is($domain_f->has_display('x2go'),$val);

        eval {is($domain_f->has_x2go($val+1),$val+1)};
        is($@,'');

        is($domain->has_rdp($val) ,$val);
        is($domain->has_rdp() ,$val);
        $domain_f = rvd_front->search_domain($domain->name);
        is($domain_f->has_rdp(), $val);
        is($domain->has_display('rdp'),$val);

        eval {is($domain_f->has_rdp($val+1),$val+1)};
        is($@,'');

    }

}

sub test_domain_display_req($vm_name) {
    my $vm = rvd_back->search_vm($vm_name);

    my $domain0 = $vm->create_domain( name => new_domain_name()
        , id_iso => $ID_ISO
        , id_owner => $USER->id
    );
    for my $type ( qw(spice rdp x2go)) {
        for my $value ( 0 , 1 , 2) {
            my $req = Ravada::Request->set_display(
                   uid => $USER->id
                ,$type => $value
            ,id_domain => $domain0->id
            );
            rvd_back->_process_all_requests_dont_fork();
            is($req->error,'');
            my $domain = $vm->search_domain($domain0->name);
            is($domain->has_display($type),$value);

            my $domain_f = $vm->search_domain($domain0->name);
            is($domain_f->has_display($type),$value);
        }
    }
}

sub test_display_children($vm_name) {
    my $vm = rvd_back->search_vm($vm_name);

    my $domain0 = $vm->create_domain( name => new_domain_name()
        , id_iso => $ID_ISO
        , id_owner => $USER->id
    );
    for my $type ( qw(spice rdp x2go)) {
        for my $value ( 0 , 1 , 2) {
            $domain0->set_display($type => $value);

            my $domain = $vm->search_domain($domain0->name);
            is($domain->has_display($type),$value);

            my $domain_f = $vm->search_domain($domain0->name);
            is($domain_f->has_display($type),$value);

            $domain0->prepare_base($USER)   if !$domain0->is_base();

            my $child = $domain0->clone(name => new_domain_name(), user => $USER);
            is($child->has_display($type),$value);
            
            my $child_f = $vm->search_domain($child->name);
            is($child_f->has_display($type),$value);
            $child->remove($USER);
        }
    }

}

sub test_display_ports_down($vm_name) {
    for my $id_iso ($ID_ISO, search_id_iso('debian'), search_id_iso('mint')) {
        test_display_ports_down_iso($vm_name, $id_iso);
    }
}

sub test_display_ports_down_iso($vm_name,$id_iso) {
    my $vm = rvd_back->search_vm($vm_name);

    my $domain0 = $vm->create_domain( name => new_domain_name()
        , id_iso => $id_iso
        , id_owner => $USER->id
    );
    my %used_port;
    for my $type ( qw(spice rdp x2go)) {
        for my $value ( 0 , 1 , 2, 0) {
            next if $type =~ /spice/i && !$value;

            $domain0->shutdown_now($USER)    if $domain0->is_active;

            $domain0->set_display($type => $value);

            my $domain = $vm->search_domain($domain0->name);
            is($domain->has_display($type),$value);

            my $domain_f = $vm->search_domain($domain0->name);
            is($domain_f->has_display($type),$value);

            # check SQL nat ports
            #
            my @nat_ports = _sql_nat_ports($domain);
            is(scalar @nat_ports,0,"Expecting 0 ports open for domain ".$domain->id
                ." got ".Dumper(\@nat_ports));

            next if $type =~ /spice/i;

            # check iptables nat ports
            #
            @nat_ports = _iptables_nat_ports($domain0->_display_port($type));
            is(scalar @nat_ports,0,"Expecting 0 ports open for $type"
                    ." got ".Dumper(\@nat_ports));

            # start the domain
            #
            $domain0->start(user => $USER, remote_ip => '10.1.1.1');
            for ( 1 .. 20 ) {
                last if $domain0->ip;
                diag("Waiting for ".$domain0->name." network up") if $_> 3;
                sleep 1;
            }
            ok($domain0->ip,"Expecting an IP , got :".($domain0->ip or '<UNDEF>')) or next;

            # check SQL nat ports
            #
            my $expect_ports = 0;
            $expect_ports = 1 if $value;
            @nat_ports = _sql_nat_ports($domain);
            is(scalar @nat_ports,$expect_ports,"Expecting $expect_ports ports open for domain "
                .$domain->id." $type=$value "
                ." got ".Dumper(\@nat_ports));

            # check iptables nat ports
            #
            @nat_ports = _iptables_nat_ports($domain0->_display_port($type));
            is(scalar @nat_ports,$expect_ports,"Expecting $expect_ports ports open for $type"
                ." got ".Dumper(\@nat_ports));

            # close the iptables and check no ports open
            #
            $domain->close_iptables(user => $USER);

            # check SQL nat ports
            #
            @nat_ports = _sql_nat_ports($domain);
            is(scalar @nat_ports ,0,"Expecting 0 ports open for domain "
                .$domain->id." $type=$value "
               ." got ".Dumper(\@nat_ports));

            # check iptables nat ports
            #
            @nat_ports = _iptables_nat_ports($domain0->_display_port($type));
            is(scalar @nat_ports,0,"Expecting 0 ports open for $type"
                    ." got ".Dumper(\@nat_ports));


            # check SQL nat ports
            $domain->open_iptables(uid => $USER->id, remote_ip => '10.1.1.1');
            @nat_ports = _sql_nat_ports($domain);
            is(scalar @nat_ports,$expect_ports,"Expecting $expect_ports ports open for domain "
                .$domain->id." $type=$value "
                ." got ".Dumper(\@nat_ports));

            # check iptables nat ports
            #
            @nat_ports = _iptables_nat_ports($domain0->_display_port($type));
            is(scalar @nat_ports,$expect_ports,"Expecting $expect_ports ports open for $type"
                    ." got ".Dumper(\@nat_ports));


        }
    }
    $domain0->remove($USER);
}


sub test_display_ports($vm_name) {
    my $vm = rvd_back->search_vm($vm_name);

    my $domain0 = $vm->create_domain( name => new_domain_name()
        , id_iso => $ID_ISO
        , id_owner => $USER->id
    );
    my %used_port;
    for my $type ( qw(spice rdp x2go)) {
        for my $value ( 0 , 1 , 2, 0) {
            next if $type =~ /spice/i && !$value;

            $domain0->set_display($type => $value);

            my $domain = $vm->search_domain($domain0->name);
            is($domain->has_display($type),$value);

            my $domain_f = $vm->search_domain($domain0->name);
            is($domain_f->has_display($type),$value);

            $domain->shutdown_now($USER)    if $domain->is_active;
            $domain->start(user => $USER, remote_ip => '10.0.0.1');

            for ( 1 .. 60 ) {
                last if $domain->ip;
                sleep 1;
            }
            my $domain_ip = $domain->ip;
            ok($domain_ip,"Expecting an IP for domain ".$domain->name
                            ." got: $domain_ip") or exit;

            my $display = $domain->display($USER,$type);
            if (!$value) {
                is($display,undef,"Expecting no display , got '".($display or '')."'");
                next;
            }

            my ($ip,$port) = $display =~ m{.*://(\d+\..*\d+):(\d+)};

            like($display,qr(^$type://\d+\.)) and do {
                if ($type ne 'spice') {
                    my ($ok,$msg) = test_chain_prerouting($vm_name, $ip
                                    , $domain->_display_port($type), $domain_ip, 1);
                    ok($ok, $msg) or exit;
                }
                ok(!$used_port{$port}
                    || $used_port{$port} eq $type
                    || ($used_port{$port} && !$domain->has_display($used_port{$port}))
                    , "[$vm_name:$type] Port $port already used for "
                        .($used_port{$port} or 'NOBODY'));
                $used_port{$port} = $type;
            };
            if ($type eq 'spice') {
                is(_sql_nat_ports($domain),0);
            } else {
                my @nat_ports = _sql_nat_ports($domain);
                is( scalar @nat_ports,1,Dumper(\@nat_ports));
            }

            $domain->shutdown_now($USER)    if $domain->is_active;
            if ($type ne 'spice') {
                my ($ok,$msg) = test_chain_prerouting($vm_name, $ip
                                    , $domain->_display_port($type), $domain_ip, 0);
                ok($ok, $msg);
            }
            $domain0->set_display($type,0);
            my @nat_ports = _sql_nat_ports($domain);
            is(scalar @nat_ports,0,"Expecting 0 ports open for domain ".$domain->id." got ".Dumper(\@nat_ports)) or exit;

        }
    }

}
sub _iptables_nat_ports($port) {
    my $ipt = IPTables::Parse->new();

    my @rules;
    for my $rule (@{$ipt->chain_rules('nat','PREROUTING')}) {
        lock_hash(%$rule);
        push @rules,($rule)
                if $rule->{to_port} eq $port;
    }
    return @rules;

}

sub _sql_nat_ports($domain) {
    my $sth = $test->dbh->prepare(
        "SELECT * FROM domain_ports "
        ." WHERE id_domain=?"
    );
    $sth->execute($domain->id);
    my @ports;
    while (my $port = $sth->fetchrow_hashref) {
        push @ports,($port);
    }
    return @ports;
}

#################################################################

clean();
flush_rules();

my $vm_name = 'KVM';
my $vm = rvd_back->search_vm($vm_name);


SKIP: {

    my $msg = "SKIPPED: No virtual managers found";
    if ($vm && $vm_name =~ /kvm/i && $>) {
        $msg = "SKIPPED: Test must run as root";
        $vm = undef;
    }

    skip($msg,10)   if !$vm;

    test_display_ports_down($vm_name);
    test_display_ports($vm_name);

    #TODO
#test_display_ports_multiple($vm_name);

    test_domain_display($vm_name);
    test_domain_display_req($vm_name);

    test_display_children($vm_name);
}

clean();
flush_rules();

done_testing();
