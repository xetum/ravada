use utf8;
package Ravada::Schema::Result::BasePort;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::BasePort

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<base_ports>

=cut

__PACKAGE__->table("base_ports");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_domain

  data_type: 'integer'
  is_nullable: 1

=head2 port

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_domain",
  { data_type => "integer", is_nullable => 1 },
  "port",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<id_domain_name>

=over 4

=item * L</id_domain>

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("id_domain_name", ["id_domain", "name"]);

=head2 C<id_domain_port>

=over 4

=item * L</id_domain>

=item * L</port>

=back

=cut

__PACKAGE__->add_unique_constraint("id_domain_port", ["id_domain", "port"]);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RXtT1vYPoK308/mSt0a35w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
