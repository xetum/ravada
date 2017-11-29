use utf8;
package Ravada::Schema::Result::Message;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::Message

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<messages>

=cut

__PACKAGE__->table("messages");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_user

  data_type: 'integer'
  is_nullable: 0

=head2 id_request

  data_type: 'integer'
  is_nullable: 1

=head2 subject

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=head2 message

  data_type: 'text'
  is_nullable: 1

=head2 date_send

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 1

=head2 date_shown

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 date_read

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_user",
  { data_type => "integer", is_nullable => 0 },
  "id_request",
  { data_type => "integer", is_nullable => 1 },
  "subject",
  { data_type => "varchar", is_nullable => 1, size => 120 },
  "message",
  { data_type => "text", is_nullable => 1 },
  "date_send",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 1,
  },
  "date_shown",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "date_read",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MH4QfuH3FdP9hNjTnBTivg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
