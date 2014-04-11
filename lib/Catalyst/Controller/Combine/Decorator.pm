package Catalyst::Controller::Combine::Decorator;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Controller::Combine::Part';

=head1 NAME

Catalyst::Controller::Combine::Decorator - abstract base class for decorators

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=cut

=head2 part

a part for obtaining content before the replacements are made

=cut

has part => ( 
    is  => 'ro',
    isa => 'Catalyst::Controller::Combine::Part',
);

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
