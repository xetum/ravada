use utf8;
package Ravada::Schema::Result::Request;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::Request

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<requests>

=cut

__PACKAGE__->table("requests");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 command

  data_type: 'char'
  is_nullable: 1
  size: 32

=head2 args

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 date_req

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 date_changed

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 status

  data_type: 'char'
  is_nullable: 1
  size: 64

=head2 error

  data_type: 'text'
  is_nullable: 1

=head2 id_domain

  data_type: 'integer'
  is_nullable: 1

=head2 domain_name

  data_type: 'char'
  is_nullable: 1
  size: 80

=head2 result

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 at_time

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "command",
  { data_type => "char", is_nullable => 1, size => 32 },
  "args",
  { data_type => "char", is_nullable => 1, size => 255 },
  "date_req",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "date_changed",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "status",
  { data_type => "char", is_nullable => 1, size => 64 },
  "error",
  { data_type => "text", is_nullable => 1 },
  "id_domain",
  { data_type => "integer", is_nullable => 1 },
  "domain_name",
  { data_type => "char", is_nullable => 1, size => 80 },
  "result",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "at_time",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jSLCTx/d24baKcckTP+TqQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
