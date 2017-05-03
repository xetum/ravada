use warnings;
use strict;

use Carp qw(confess);
use Data::Dumper;
use IPC::Run3;
use Test::More;
use Test::SQL::Data;

use feature qw(signatures);

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

    my $domain_f = rvd_front->search_domain($domain->name);
    ok($domain_f->has_spice());
    ok(!$domain_f->has_x2go());

    is($domain->has_spice(),1);

    for my $val (0,1) {
        is($domain->has_spice($val),$val);
        is($domain->has_spice(),$val);
        $domain_f = rvd_front->search_domain($domain->name);
        is($domain_f->has_spice(),$val);

        is($domain->has_x2go($val) ,$val);
        is($domain->has_x2go() ,$val);
        $domain_f = rvd_front->search_domain($domain->name);
        is($domain_f->has_x2go(), $val);

        is($domain->has_rdp($val) ,$val);
        is($domain->has_rdp() ,$val);
        $domain_f = rvd_front->search_domain($domain->name);
        is($domain_f->has_rdp(), $val);

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

    test_domain_display($vm_name);
}

clean();

done_testing();
