package Catalyst::Controller::Combine::FilePart;
use Moose;
use Path::Class::File;
use namespace::autoclean;

extends 'Catalyst::Controller::Combine::Part';

=head1 NAME

Catalyst::Controller::Combine::FilePart - represents a file

=head1 SYNOPSIS

=head1 DESCRIPTION

provides the content of a file

=head1 ATTRIBUTES

=cut

has file => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 1,
);

=head1 METHODS

=cut

=head2 content

returns the file content

=cut

sub content {
    my $self = shift;

    return scalar $self->file->slurp;
}

=head2 debug

=cut

sub debug {
    my $self = shift;
    my $indent = shift // '';

    print "${indent}File: ${\$self->file}\n";
}

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
