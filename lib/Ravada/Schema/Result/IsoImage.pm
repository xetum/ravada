use utf8;
package Ravada::Schema::Result::IsoImage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ravada::Schema::Result::IsoImage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<iso_images>

=cut

__PACKAGE__->table("iso_images");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 file_re

  data_type: 'char'
  is_nullable: 1
  size: 64

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 arch

  data_type: 'char'
  is_nullable: 1
  size: 8

=head2 xml

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 xml_volume

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 md5

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 md5_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 device

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 sha256

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 sha256_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 rename_file

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "file_re",
  { data_type => "char", is_nullable => 1, size => 64 },
  "name",
  { data_type => "char", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "arch",
  { data_type => "char", is_nullable => 1, size => 8 },
  "xml",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "xml_volume",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "md5",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "md5_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "device",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sha256",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sha256_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "rename_file",
  { data_type => "varchar", is_nullable => 1, size => 80 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kmT1nVpj7r6O2fT83y5S7A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
