package Catalyst::Controller::Combine::ReplaceDecorator;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Controller::Combine::Decorator';

=head1 NAME

Catalyst::Controller::Combine::ReplaceDecorator - handle a content replacement

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=cut

=head2 search

the regex to search for

=cut

has search => (
    is       => 'ro',
    isa      => 'Str|RegexpRef',
    required => 1,
);

=head2 replace

the text to insert as a replacement

=cut

has replace => (
    is => 'ro',
    isa => 'Str',
    default => '',
    required => 1,
);

=head1 METHODS

=cut

sub content {
    my $self = shift;
    my $content = $self->part->content;

    $content =~ s{${\$self->search}}{qq{qq{${\$self->replace}}}}eexmsg;

    return $content;
}

=head2 debug

=cut

sub debug {
    my $self = shift;
    my $indent = shift // '';

    print "${indent}Replace ${\$self->search} --> ${\$self->replace}\n";
    $self->part->debug("$indent    ");
}

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
