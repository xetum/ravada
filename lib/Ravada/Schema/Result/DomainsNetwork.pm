use utf8;
package Ravada::Schema::Result::DomainsNetwork;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::DomainsNetwork

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<domains_network>

=cut

__PACKAGE__->table("domains_network");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_domain

  data_type: 'integer'
  is_nullable: 0

=head2 id_network

  data_type: 'integer'
  is_nullable: 0

=head2 anonymous

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 allowed

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_domain",
  { data_type => "integer", is_nullable => 0 },
  "id_network",
  { data_type => "integer", is_nullable => 0 },
  "anonymous",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "allowed",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3oWgV36FX6w7wyTbnxFEog


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
