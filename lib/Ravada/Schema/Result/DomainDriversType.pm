use utf8;
package Ravada::Schema::Result::DomainDriversType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::DomainDriversType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<domain_drivers_types>

=cut

__PACKAGE__->table("domain_drivers_types");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 1
  size: 32

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 vm

  data_type: 'char'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 1, size => 32 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "vm",
  { data_type => "char", is_nullable => 1, size => 32 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ksir6N3WbxB3liqjeVBUzw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
