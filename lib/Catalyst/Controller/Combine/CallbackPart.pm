package Catalyst::Controller::Combine::CallbackPart;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Controller::Combine::Part';

=head1 NAME

Catalyst::Controller::Combine::CallbackPart - represents a callback

=head1 SYNOPSIS

=head1 DESCRIPTION

returns content by calling a provided code reference

=head1 ATTRIBUTES

=cut

has callback => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

=head1 METHODS

=cut

=head2 content

returns the callback's result

=cut

sub content {
    my $self = shift;
    
    return $self->callback->();
}

=head2 debug

=cut

sub debug {
    my $self = shift;
    my $indent = shift // '';

    print "${indent}Callback\n";
}

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
