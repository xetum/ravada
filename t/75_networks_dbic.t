use warnings;
use strict;

use Carp qw(confess);
use Data::Dumper;
use POSIX qw(WNOHANG);
use Test::More;
use Test::SQL::Data;

use_ok('Ravada');
use_ok('Ravada::Network');
use_ok('Ravada::Schema');

use lib 't/lib';
use Test::Ravada;

my $test = Test::SQL::Data->new(config => 't/etc/sql.conf');

my $rvd_back = rvd_back( $test->connector , 't/etc/ravada.conf');
my $RVD_FRONT = rvd_front( $test->connector , 't/etc/ravada.conf');

my $vm = $rvd_back->search_vm('Void');
my $USER = create_user('foo','bar');

my $SCHEMA = Ravada::Schema->connect($test->connection_data);

########################################################################3

sub test_allow_all {
    my $domain = shift;

    my $ip = '192.168.1.2/32';
    my $net = Ravada::Network->new(address => $ip);
    ok(!$net->allowed($domain->id),"Expecting not allowed from unknown network");

    my $new_net_data = $SCHEMA->resultset('Network')->create(
         { name => 'foo'
             , address => '192.168.1.0/24'
             , all_domains => 1
         }
    );

    ok(!$net->allowed_anonymous($domain->id),"Expecting denied anonymous from known network");
    ok($net->allowed($domain->id),"Expecting allowed from known network");

    my $net2 = Ravada::Network->new(address => '192.168.1.22/32');
    ok($net2->allowed($domain->id),"Expecting allowed from known network");
    ok(!$net2->allowed_anonymous($domain->id),"Expecting denied anonymous from known network");
    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok(!$n_found, "Expecting 0 anon bases, got '$n_found'");
    }

}

sub test_allow_domain {
    my $domain = shift;

    my $ip = '10.1.1.1/32';
    my $net = Ravada::Network->new(address => $ip);
    ok(!$net->allowed($domain->id),"Expecting not allowed from unknown network");

    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok(!$n_found, "Expecting 0 anon bases, got '$n_found'");
    }

    my $net_data = $SCHEMA->resultset('Network')->create(
         { name => 'foo'
             , address => '10.1.1.0/24'
             , all_domains => 0
             , no_domains => 0
         }
    );

    my $dom_net_data = $SCHEMA->resultset('DomainsNetwork')->create(
        {   id_domain => $domain->id
            ,id_network => $net_data->id
            , allowed => 1
        }
    );

    ok($net->allowed($domain->id),"Expecting allowed from known network");
    ok(!$net->allowed_anonymous($domain->id)
        ,"Expecting not allowed anonymous from known network");

    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok(!$n_found, "Expecting 0 anon bases, got '$n_found'");
    }

    $dom_net_data->allowed(0);
    $dom_net_data->update();

    ok(!$net->allowed($domain->id),"Expecting not allowed from known network");
    ok(!$net->allowed_anonymous($domain->id)
        ,"Expecting not allowed anonymous from known network");

    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok(!$n_found, "Expecting 0 anon bases, got '$n_found'");
    }

    $dom_net_data->allowed(0);
    $dom_net_data->anonymous(1);
    $dom_net_data->update();

    ok(!$net->allowed($domain->id),"Expecting not allowed from known network");

    ok(!$net->allowed_anonymous($domain->id)
        ,"Expecting not allowed anonymous from known network");

    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok(!$n_found, "Expecting 0 anon bases, got '$n_found'");
    }

    $dom_net_data->allowed(1);
    $dom_net_data->update();

    ok($net->allowed($domain->id),"Expecting allowed from known network");
    ok($net->allowed_anonymous($domain->id)
        ,"Expecting allowed anonymous from known network");

    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok($n_found == 1, "Expecting 1 anon bases, got '$n_found'");
    }


}


sub test_deny_all {
    my $domain = shift;

    my $ip = '10.0.0.2/32';

    my $net = Ravada::Network->new(address => $ip);
    ok(!$net->allowed($domain->id),"Expecting not allowed from unknown network");

    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok(!$n_found, "Expecting 0 anon bases, got '$n_found'");
    }

#    my $sth = $test->dbh->prepare("INSERT INTO networks (name,address,no_domains) "
#        ." VALUES (?,?,?) ");
    #
    #$sth->execute('bar', '10.0.0.0/16', 1);
    #$sth->finish;
    my $net_data = $SCHEMA->resultset('Network')->create({
        name => "bar"
        , address => "10.0.0.0/16"
        , no_domains => 1
    });

    ok(!$net->allowed($domain->id),"Expecting denied from known network");
    ok(!$net->allowed_anonymous($domain->id),"Expecting denied anonymous from known network");

    { # test list bases anonymous
        my $list_bases = $RVD_FRONT->list_bases_anonymous($ip);
        my $n_found = scalar (@$list_bases);
        ok(!$n_found, "Expecting 0 anon bases, got '$n_found'");
    }

}

sub deny_everything_any {
    my ($net_any) = $SCHEMA->resultset('Network')->search({ address => '0.0.0.0/0'})->all;
    $net_any->all_domains(0);
    $net_any->update();
}

########################################################################3
#
#
remove_old_domains();
remove_old_disks();

my $domain_name = new_domain_name();
my $domain = $vm->create_domain( name => $domain_name
            , id_iso => 1 , id_owner => $USER->id);

$domain->prepare_base($USER);
$domain->is_public(1);

my $net = Ravada::Network->new(address => '127.0.0.1/32');
ok($net->allowed($domain->id));

deny_everything_any();
my $net2 = Ravada::Network->new(address => '10.0.0.0/32');
ok(!$net2->allowed($domain->id), "Address unknown should not be allowed to anything");

test_allow_all($domain);
test_deny_all($domain);

test_allow_domain($domain);

remove_old_domains();
remove_old_disks();

done_testing();
