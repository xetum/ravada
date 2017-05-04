use warnings;
use strict;

use Carp qw(confess);
use Data::Dumper;
use IPC::Run3;
use Test::More;
use Test::SQL::Data;

use feature qw(signatures);
no warnings "experimental::signatures";

use lib 't/lib';
use Test::Ravada;

my $test = Test::SQL::Data->new(config => 't/etc/sql.conf');

use_ok('Ravada');
my %ARG_CREATE_DOM = (
      KVM => [ id_iso => 1 ]
);

my @VMS = reverse keys %ARG_CREATE_DOM;
init($test->connector);
my $USER = create_user("foo","bar");

#################################################################
sub test_domain_display($vm_name){
    my $vm = rvd_back->search_vm($vm_name);

    my $net = Ravada::Network->new(address => '127.0.0.1/32');

    ok(!$net->requires_password);
    my $domain_name = new_domain_name();
    my $domain = $vm->create_domain( name => $domain_name
                , id_iso => 1 , id_owner => $USER->id);

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
        , id_iso => 1
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
        , id_iso => 1
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

sub test_display_ports($vm_name) {
    my $vm = rvd_back->search_vm($vm_name);

    my $domain0 = $vm->create_domain( name => new_domain_name()
        , id_iso => 1
        , id_owner => $USER->id
    );
    my %used_port;
    for my $type ( qw(spice rdp x2go)) {
        for my $value ( 0 , 1 , 2) {
            next if $type =~ /spice/i && !$value;

            diag("$vm_name $type : $value");
            $domain0->set_display($type => $value);

            my $domain = $vm->search_domain($domain0->name);
            is($domain->has_display($type),$value);

            my $domain_f = $vm->search_domain($domain0->name);
            is($domain_f->has_display($type),$value);

            $domain->shutdown_now($USER)    if $domain->is_active;
            $domain->start(user => $USER, remote_ip => '10.0.0.1');

            for ( 1 .. 10 ) {
                last if $domain->ip;
                sleep 1;
            }
            ok($domain->ip,"Expecting an IP") or next;

            my $display = $domain->display($USER,$type);
            if (!$value) {
                is($display,undef);
                next;
            }
            like($display,qr(^$type://\d+\.)) and do {
                my ($port) = $display =~ m{.*:(\d+)};
                ok(!$used_port{$port} || $used_port{$port} eq $type
                    , "[$vm_name:$type] Port $port already used for "
                        .($used_port{$port} or ''));
                $used_port{$port} = $type;
            };
            $domain->shutdown_now($USER)    if $domain->is_active;
        }
    }

}

#################################################################

clean();

my $vm_name = 'KVM';
my $vm = rvd_back->search_vm($vm_name);


SKIP: {

    my $msg = "SKIPPED: No virtual managers found";
    if ($vm && $vm_name =~ /kvm/i && $>) {
        $msg = "SKIPPED: Test must run as root";
        $vm = undef;
    }

    skip($msg,10)   if !$vm;

    test_display_ports($vm_name);

    test_domain_display($vm_name);
    test_domain_display_req($vm_name);

    test_display_children($vm_name);
}

clean();

done_testing();
