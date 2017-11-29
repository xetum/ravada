use utf8;
package Ravada::Schema::Result::DomainPort;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::DomainPort

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<domain_ports>

=cut

__PACKAGE__->table("domain_ports");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_domain

  data_type: 'integer'
  is_nullable: 1

=head2 public_port

  data_type: 'integer'
  is_nullable: 1

=head2 internal_port

  data_type: 'integer'
  is_nullable: 1

=head2 public_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 internal_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 active

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_domain",
  { data_type => "integer", is_nullable => 1 },
  "public_port",
  { data_type => "integer", is_nullable => 1 },
  "internal_port",
  { data_type => "integer", is_nullable => 1 },
  "public_ip",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "internal_ip",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "active",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<description>

=over 4

=item * L</id_domain>

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("description", ["id_domain", "description"]);

=head2 C<domain_port>

=over 4

=item * L</id_domain>

=item * L</internal_port>

=back

=cut

__PACKAGE__->add_unique_constraint("domain_port", ["id_domain", "internal_port"]);

=head2 C<internal>

=over 4

=item * L</internal_port>

=item * L</internal_ip>

=back

=cut

__PACKAGE__->add_unique_constraint("internal", ["internal_port", "internal_ip"]);

=head2 C<name>

=over 4

=item * L</id_domain>

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["id_domain", "name"]);

=head2 C<public>

=over 4

=item * L</public_port>

=item * L</public_ip>

=back

=cut

__PACKAGE__->add_unique_constraint("public", ["public_port", "public_ip"]);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FniNzHMwEzkSe+XLURRFbg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
