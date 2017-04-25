package Ravada::Network;

use strict;
use warnings;

=head1 NAME

Ravada::Network - Networks management library for Ravada

=cut

use Hash::Util qw(lock_hash);
use Moose;
use MooseX::Types::NetAddr::IP qw( NetAddrIP );
use Moose::Util::TypeConstraints;
use Data::Dumper;
use NetAddr::IP;


#########################################################

has 'address' => ( is => 'ro', isa => NetAddrIP, coerce => 1 );

#########################################################

our $CONNECTOR;

#########################################################


=head1 Description

    my $net = Ravada::Network->new(address => '127.0.0.1/32');
    if ( $net->allowed( $domain->id ) ) {

=cut

sub _init_connector {
    $CONNECTOR = \$Ravada::CONNECTOR;
    $CONNECTOR = \$Ravada::Front::CONNECTOR if !defined $$CONNECTOR;
}


sub BUILD {
    my $self = shift;

    my $name = $_[0]->{name};
    my $address = $_[0]->{address};
    my $description = $_[0]->{description};
    $name = "" unless defined $name;

    _init_connector();
    if ( $name ne '' ) {

    #my $row = $self->_insert_net_db($name, $address, $description);
    my $row = $self -> _select_net_db( $name, $address, $description);
    #my $row = $self -> _do_select_net_db( $name);
    #my @list = $self->list_networks;
    };
}
=head2 allowed

Returns true if the IP is allowed to run a domain

    if ( $net->allowed( $domain->id ) ) {

=cut

sub allowed {
    my $self = shift;
    my $id_domain = shift;
    my $anonymous = shift;

#    my $localnet = NetAddr::IP->new('127.0.0.0','255.0.0.0');
#    return 1 if $self->address->within($localnet);

    for my $network ( $self->list_networks ) {
        my ($ip,$mask) = $network->{address} =~ m{(.*)/(.*)};
        if (!$ip ) {
            $ip = $network->{address};
            $mask = 24;
        }
        my $netaddr;
        eval { $netaddr = NetAddr::IP->new($ip,$mask) };
        if ($@ ) {
            warn "Error with newtork $network->{address} [ $ip / $mask ] $@";
            return;
        }
        next if !$self->address->within($netaddr);

        return 1 if $network->{all_domains} && !$anonymous;
        return 0 if $network->{no_domains};

        my $allowed = $self->_allowed_domain($id_domain, $network->{id});
        next if !defined $allowed;

        return 0 if !$allowed;

        return $self->_allowed_domain_anonymous($id_domain, $network->{id})    if $anonymous;

        return $allowed;

    }

    return 0;
}

sub allowed_anonymous {
    my $self = shift;

    return $self->allowed(@_,1);
}

sub _allowed_domain {
    my $self = shift;
    my ($id_domain, $id_network) = @_;

    my $sth = $$CONNECTOR->dbh->prepare("SELECT allowed FROM domains_network "
        ." WHERE id_domain=? AND id_network=? ");
    $sth->execute($id_domain, $id_network);
    my ($allowed) = $sth->fetchrow;
    $sth->finish;

    return $allowed;
}

sub _allowed_domain_anonymous {
    my $self = shift;
    my ($id_domain, $id_network) = @_;

    my $sth = $$CONNECTOR->dbh->prepare("SELECT anonymous FROM domains_network "
        ." WHERE id_domain=? AND id_network=? AND allowed=1");
    $sth->execute($id_domain, $id_network);
    my ($allowed) = $sth->fetchrow;
    $sth->finish;

    return $allowed;
}

sub _do_select_net_db {
    my $self = shift;
    my $name = shift;

    my $sth = $$CONNECTOR->dbh->prepare(
        " SELECT * FROM networks WHERE name=?") ;
    $sth->execute($name);
    my $row = $sth->fetchrow_hashref;
    $sth->finish;
    warn Dumper ($row).$name;
    return $row;
}

sub _select_net_db {
    my $self = shift;
    #search network if not exists insert
    my ($row) = ($self->_do_select_net_db(@_) or $self->_insert_net_db(@_));

    $self->{_data} = $row;
    return $row if $row->{id};
}

sub _insert_net_db {
    my $self = shift;
    my $name = shift;
    my $address = shift;
    my $description = shift;

    my $sth = $$CONNECTOR->dbh->prepare(
        "INSERT INTO networks (name, address, description) "
        ." VALUES(?,?,?)"
    );

    $sth->execute($name,$address,$description);
    $sth->finish;
    return $self->_do_select_net_db( $name); ;
}

sub list_networks {
    my $self = shift;

    _init_connector();

    my $sth = $$CONNECTOR->dbh->prepare(
        "SELECT * "
        ." FROM networks "
        ." ORDER BY n_order"
    );
    $sth->execute();

    my @networks;

    while ( my $row = $sth->fetchrow_hashref) {
        lock_hash(%$row);
        push @networks, ( $row );
    }
    $sth->finish;

    return @networks;
}

1;
