use utf8;
package Ravada::Schema::Result::LxcTemplate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::LxcTemplate

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<lxc_templates>

=cut

__PACKAGE__->table("lxc_templates");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 355

=head2 arch

  data_type: 'char'
  is_nullable: 1
  size: 8

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 355 },
  "arch",
  { data_type => "char", is_nullable => 1, size => 8 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0w2ZvW0btu/aSR0BsdQh4Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
