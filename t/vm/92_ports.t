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

# Before messing with ports, everything worked for spice
sub test_no_ports {
    my $vm_name = shift;

    my $domain = create_domain($vm_name);
}

##############################################################

clean();

for my $vm_name ( sort keys %ARG_CREATE_DOM ) {

    test_no_ports($vm_name);
}

clean();
done_testing();
