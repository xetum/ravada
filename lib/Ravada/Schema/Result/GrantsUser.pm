use utf8;
package Ravada::Schema::Result::GrantsUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::GrantsUser

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<grants_user>

=cut

__PACKAGE__->table("grants_user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_user

  data_type: 'integer'
  is_nullable: 0

=head2 id_grant

  data_type: 'integer'
  is_nullable: 0

=head2 allowed

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_user",
  { data_type => "integer", is_nullable => 0 },
  "id_grant",
  { data_type => "integer", is_nullable => 0 },
  "allowed",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<id_grant>

=over 4

=item * L</id_grant>

=item * L</id_user>

=back

=cut

__PACKAGE__->add_unique_constraint("id_grant", ["id_grant", "id_user"]);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:278yPuPeq/F0GWhvM5J9YA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
