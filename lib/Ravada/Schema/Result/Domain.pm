use utf8;
package Ravada::Schema::Result::Domain;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::Domain

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<domains>

=cut

__PACKAGE__->table("domains");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_base

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 80

=head2 created

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 error

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 uri

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 is_base

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 is_public

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 file_base_img

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 file_screenshot

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 port

  data_type: 'integer'
  is_nullable: 1

=head2 id_owner

  data_type: 'integer'
  is_nullable: 1

=head2 vm

  data_type: 'char'
  is_nullable: 0
  size: 120

=head2 spice_password

  data_type: 'varchar'
  default_value: 'NULL'
  is_nullable: 1
  size: 20

=head2 has_spice

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 has_x2go

  data_type: 'integer'
  is_nullable: 1

=head2 has_rdp

  data_type: 'integer'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 start_time

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 run_timeout

  data_type: 'integer'
  is_nullable: 1

=head2 id_vm

  data_type: 'integer'
  is_nullable: 1

=head2 is_volatile

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_base",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "char", is_nullable => 0, size => 80 },
  "created",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "error",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "is_base",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "is_public",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "file_base_img",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "file_screenshot",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "port",
  { data_type => "integer", is_nullable => 1 },
  "id_owner",
  { data_type => "integer", is_nullable => 1 },
  "vm",
  { data_type => "char", is_nullable => 0, size => 120 },
  "spice_password",
  {
    data_type => "varchar",
    default_value => "NULL",
    is_nullable => 1,
    size => 20,
  },
  "has_spice",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "has_x2go",
  { data_type => "integer", is_nullable => 1 },
  "has_rdp",
  { data_type => "integer", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "start_time",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "run_timeout",
  { data_type => "integer", is_nullable => 1 },
  "id_vm",
  { data_type => "integer", is_nullable => 1 },
  "is_volatile",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<id_base>

=over 4

=item * L</id_base>

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("id_base", ["id_base", "name"]);

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:43dKlhs40425pU/2NoPeBg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
