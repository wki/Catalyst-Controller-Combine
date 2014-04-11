package Catalyst::Controller::Combine::IncludeDecorator;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Controller::Combine::Part';

=head1 NAME

Catalyst::Controller::Combine::IncludeDecorator - handle include replacements

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=cut

=head2 include

a list of {search, replace} hashrefs.

=cut

has include => (
    is      => 'ro',
    traits  => ['Array'],
    isa     => 'ArrayRef', # of { search => ..., replace => ... }
    default => sub { [] },
    handles => { 
        all_includes => 'elements',
    },
);

=head2 part

a part for obtaining content before the replacements are made

=cut

has part => ( 
    is  => 'ro',
    isa => 'Catalyst::Controller::Combine::Part',
);

=head2 combiner

the combiner object asked for the content of the files which are the result
of the replace-operations

=cut

has combiner => ( 
    is  => 'ro',
    isa => 'Object',
);

=head1 METHODS

=cut

=head2 content

return a referenced part with all include replacements made

=cut

sub content {
    my $self    = shift;
    my $content = $self->part->content;

    foreach my $include ( $self->all_includes ) {
        $content =~
            s{ $include->{search} }
             { $self->combiner->combine($include->{replace} // $1) }exmsg;
    }

    return $content;
}

=head2 debug

=cut

sub debug {
    my $self = shift;
    my $indent = shift // '';

    print "${indent}Include\n";
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
