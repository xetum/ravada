use utf8;
package Ravada::Schema::Result::DomainDriversOption;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::DomainDriversOption

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<domain_drivers_options>

=cut

__PACKAGE__->table("domain_drivers_options");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_driver_type

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_driver_type",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "char", is_nullable => 0, size => 64 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z64HNmKrbl5Xa7ih1taDqA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
