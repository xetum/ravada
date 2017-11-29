use utf8;
package Ravada::Schema::Result::Network;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::Network

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<networks>

=cut

__PACKAGE__->table("networks");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 address

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 140

=head2 all_domains

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 no_domains

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 requires_password

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 n_order

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "address",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 140 },
  "all_domains",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "no_domains",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "requires_password",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "n_order",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mEY01nq8RxTfZnSPzaaFwQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
