package Catalyst::Controller::Combine::Combiner;
use Moose;
use Text::Glob qw(match_glob);
use Path::Class ();
use Module::Load 'load';
use aliased 'Catalyst::Controller::Combine::FilePart';
use aliased 'Catalyst::Controller::Combine::IncludeDecorator';
use aliased 'Catalyst::Controller::Combine::ReplaceDecorator';
use aliased 'Catalyst::Controller::Combine::Sequence';

=head1 NAME

Catalyst::Controller::Combine::Combiner - blabla

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=cut

=head2 dir

the directory inside which to search for all files. Only files inside this
directory are allowed.

=cut

has dir => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    required => 1,
);

=head2 dependencies

a tree of other parts we depend on. The dependencies may be existing files
(relative paths pointing to files inside dir) or non existing things acting
as a placeholder inside the dependencies hashref.

    main => [
        qw(utils more),
    ],
    more => [
        qw(many other things),
    ],

If neither a file nor e dependencies entry exists, a warning will get issued.

Dependencies may be strings of a hashref like

    { type => 'Type', ... }

where TypeName must be a class named 'TypePart' in the namespace
C<Catalyst::Controller::Combine>.

=cut

has dependencies => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} },
);

=head2 replacements

the keys of this hashref are globs, the value are array-refs with all
replacements to get made with all files matching the given glob.

    '*' => [ { search => replace }, ... ],
    'jquery-x*.js' => [ ...],

=cut

has replacements => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} },
    handles => {
        replacement_globs => 'keys',
        replacements_for  => 'get',
    }
);

=head2 include

a list of include searches to process. The searches can be one of:

=over

=item strings

the strings are converted to regexes and then behave the same.

=item regexes

eg. C<<< qr{\@import \s+ (?:url\s*\()? ["']? ([^"')]+) ["']? [)]? .*? ;}xms >>>
in this case the file name to get searched from C<$1>.

=back

=cut

has include => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
    handles => {
        has_include => 'count',
    },
);

=head ext

the default file extension to append

=cut

has ext => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

# an internally used cache containing all files seen in order to avaid
# multiple occurences of a single file
has _file_seen => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} },
    handles => {
        _clear_files_seen => 'clear', # needed for tests
    },
);

=head1 METHODS

=cut

=head2 combine ( $file1, $file2, ... )

combines all files (or entries found in dependencies) by fulfilling all
dependencies required.

=cut

sub combine {
    my $self = shift;

    my $sequence = Sequence->new;
    $sequence->append($self->part($_)) for @_;

    return $sequence->content;
    
    # looks better?
    # return Sequence
    #     ->new
    #     ->append(map { $self->part($_) } @_)
    #     ->content;
}

=head2 debug ( $file1, $file2, ... )

constructs the same objects as C<combine> does but prints a debug output
of the object tree instead of combining.

=cut

sub debug {
    my $self = shift;

    my $sequence = Sequence->new;
    $sequence->append($self->part($_)) for @_;
    $sequence->debug;
}

=head2 part ( $name_or_relative_path )

this factory method resolves the given argument and returns a C<Part> instance
suitable for constructing the content required.

=cut

sub part {
    my ($self, $thing) = @_;

    if (ref $thing eq 'HASH') {
        my $class = 'Catalyst::Controller::Combine::' .
            ucfirst( delete $thing->{type} ) . 'Part';
        load $class;
        return $class->new(%$thing, combiner => $self);
    } elsif (exists $self->dependencies->{$thing}) {
        my $part = Sequence->new;
        $part->append($self->part($_)) for @{$self->dependencies->{$thing}};
        $part->append($self->file($thing));
        return $part;
    }
    
    return $self->file($thing);
}

=head2 file ( $relative_path )

this factory method resolves the path given with or without appending the
known file extension. If the file can be found and has not yet been part
of a construction a C<FilePart> instance is returned, nothing in all other
cases.

=cut

sub file {
    my ($self, $relative_path) = @_;

    my $ext = $self->ext;

    my $file;
    foreach my $ext ( '', ".$ext" ) {
        $file = $self->dir->file("$relative_path$ext");
        last if -f $file;
    }

    return if !-f $file || $self->_file_seen->{$file}++;

    return $self->_file($file);
}

# helper method returning constructing a FilePart instance for a file
# requested optionally decorated with a Replacement or Include

sub _file {
    my ($self, $file) = @_;

    my $part = FilePart->new(file => $file);
    $part = $self->_decorate_with_replacements($part);
    $part = $self->_decorate_with_include($part);
    return $part;
}

sub _decorate_with_replacements {
    my ($self, $part) = @_;
    
    my $path = $part->file->relative($self->dir);
    foreach my $glob (grep { match_glob($_, $path) } $self->replacement_globs) {
        my $replacements = $self->replacements_for($glob);
        foreach my $replacement (@$replacements) {
            $part = ReplaceDecorator->new(
                part => $part,
                %$replacement,
            );
        }
    }
    
    return $part;
}

sub _decorate_with_include {
    my ($self, $part) = @_;

    return $part if !$self->has_include;

    return IncludeDecorator->new(
        part     => $part,
        combiner => $self,
        include  => $self->include,
    );
}

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

