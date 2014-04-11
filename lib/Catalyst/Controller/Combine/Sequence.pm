package Catalyst::Controller::Combine::Sequence;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Controller::Combine::Part';

=head1 NAME

Catalyst::Controller::Combine::Sequence - a sequence of other parts

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=cut

=head2 parts

a list of other parts

=cut

has parts => (
    is      => 'ro',
    traits  => ['Array'],
    isa     => 'ArrayRef',
    default => sub { [] },
    handles => { 
        all_parts => 'elements',
    },
);

=head1 METHODS

=cut

=head2 content

returns the concatenated result of all parts

=cut

sub content {
    my $self = shift;
    
    return join '', map { $_->content } $self->all_parts;
}

=head2 append

appends a part to the end of the sequence

=cut

sub append {
    my $self = shift;

    push @{ $self->parts }, grep defined, @_;

    return $self; # allow chaining
}

=head2 debug

=cut

sub debug {
    my $self = shift;
    my $indent = shift // '';
    
    print "${indent}Sequence\n";
    
    $_->debug("$indent    ") for $self->all_parts;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
