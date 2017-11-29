use utf8;
package Ravada::Schema::Result::Base;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::Base

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<bases>

=cut

__PACKAGE__->table("bases");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 image

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "image",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZhYCDKrQMl0OBanYLzURrw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
