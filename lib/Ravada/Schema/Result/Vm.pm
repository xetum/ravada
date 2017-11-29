use utf8;
package Ravada::Schema::Result::Vm;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::Vm

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vms>

=cut

__PACKAGE__->table("vms");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 vm_type

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 hostname

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 default_storage

  data_type: 'varchar'
  default_value: 'default'
  is_nullable: 1
  size: 64

=head2 connection_args

  data_type: 'text'
  is_nullable: 1

=head2 public_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 security

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 0, size => 64 },
  "vm_type",
  { data_type => "char", is_nullable => 0, size => 20 },
  "hostname",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "default_storage",
  {
    data_type => "varchar",
    default_value => "default",
    is_nullable => 1,
    size => 64,
  },
  "connection_args",
  { data_type => "text", is_nullable => 1 },
  "public_ip",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "security",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RU4rvSBhZ9oIQ5WCzzTGNA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
