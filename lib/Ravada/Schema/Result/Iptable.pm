use utf8;
package Ravada::Schema::Result::Iptable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::Iptable

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<iptables>

=cut

__PACKAGE__->table("iptables");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_domain

  data_type: 'integer'
  is_nullable: 0

=head2 id_user

  data_type: 'integer'
  is_nullable: 0

=head2 remote_ip

  data_type: 'char'
  is_nullable: 0
  size: 16

=head2 time_req

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 time_deleted

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 iptables

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_domain",
  { data_type => "integer", is_nullable => 0 },
  "id_user",
  { data_type => "integer", is_nullable => 0 },
  "remote_ip",
  { data_type => "char", is_nullable => 0, size => 16 },
  "time_req",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "time_deleted",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "iptables",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c7UHPXGaln97b3BPl+Y0nQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
