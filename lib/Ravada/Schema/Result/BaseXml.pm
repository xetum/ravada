use utf8;
package Ravada::Schema::Result::BaseXml;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::BaseXml

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<base_xml>

=cut

__PACKAGE__->table("base_xml");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 id_domain

  data_type: 'integer'
  is_nullable: 0

=head2 xml

  data_type: 'varchar'
  is_nullable: 1
  size: 8092

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "id_domain",
  { data_type => "integer", is_nullable => 0 },
  "xml",
  { data_type => "varchar", is_nullable => 1, size => 8092 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<id_domain>

=over 4

=item * L</id_domain>

=back

=cut

__PACKAGE__->add_unique_constraint("id_domain", ["id_domain"]);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-11-29 11:14:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2ZhDHzuxTboWceRACIcVlw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
