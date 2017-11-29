use utf8;
package Ravada::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 password

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 change_password

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 is_admin

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 is_temporary

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 is_disabled

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 language

  data_type: 'char'
  is_nullable: 1
  size: 3

=head2 is_external

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 two_fa

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 secret

  data_type: 'char'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 0, size => 255 },
  "password",
  { data_type => "char", is_nullable => 1, size => 255 },
  "change_password",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "is_admin",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "is_temporary",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "is_disabled",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "language",
  { data_type => "char", is_nullable => 1, size => 3 },
  "is_external",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "two_fa",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "secret",
  { data_type => "char", is_nullable => 1, size => 20 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TWSpfgpL8rweopuvafkrSg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
