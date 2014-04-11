package Catalyst::Controller::Combine::Part;
use Moose;
use namespace::autoclean;

=head1 NAME

Catalyst::Controller::Combine::Part - abstract base class for parts

=head1 SYNOPSIS

    # get the text content provided by a part
    $part->content;

=head1 DESCRIPTION

All logic is spread into several classes depending on responsibility. This
is the base class all others are inheriting from.

=head1 ATTRIBUTES

=cut

=head1 METHODS

=cut

=head2 content

returns the content provided by a part. Overloaded by child classes

=cut

sub content { die 'abstract' }

=head2 debug

generates a tree-like debug structure

=cut

sub debug {
    my $self = shift;
    my $indent = shift // '';

    print "${indent}Part - \n";
}

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
