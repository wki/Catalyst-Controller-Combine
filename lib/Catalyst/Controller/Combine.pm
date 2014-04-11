package Catalyst::Controller::Combine;
use Moose;
use DateTime;
use Digest::MD5 'md5_hex';
use aliased 'Catalyst::Controller::Combine::Combiner';

# needed to make :attrs work
BEGIN { extends 'Catalyst::Controller' }

has dir       => (is => 'rw',
                  default => sub { 'static/' . shift->action_namespace },
                  lazy => 1);

has extension => (is => 'rw',
                  default => sub { shift->action_namespace },
                  lazy => 1);

has depend    => (is => 'rw',
                  default => sub { return {} });

has mimetype  => (is => 'rw',
                  default => sub {
                                    my $ext = shift->extension;
                                    return $ext eq 'js'  ? 'application/javascript'
                                         : $ext eq 'css' ? 'text/css'
                                         : 'text/plain';
                                 },
                  lazy => 1);

has replace   => (is => 'rw',
                  default => sub { {} },
                  lazy => 1,
                  predicate => 'has_replacement');

has include   => (is => 'rw',
                  default => sub { [] },
                  lazy => 1,
                  predicate => 'has_include');

has minifier  => (is => 'rw',
                  default => 'minify');

has expire    => (is => 'rw',
                  default => 0);

has expire_in => (is => 'rw',
                  default => 60 * 60 * 24 * 365 * 3); # 3 years


=head1 NAME

Catalyst::Controller::Combine - Combine JS/CSS Files

=head1 SYNOPSIS

    # use the helper to create your Controller
    script/myapp_create.pl controller Js Combine

    # or:
    script/myapp_create.pl controller Css Combine

    # DONE. READY FOR USE.

    # Just use it in your template:
    # will deliver all JavaScript files concatenated (in Js-Controller)
    <script type="text/javascript" src="/js/file1/file2/.../filex.js"></script>

    # will deliver all CSS files concatenated (in Css-Controller)
    <link rel="stylesheet" type="text/css" href="/css/file1/file2/.../filex.css" />

    # in the generated controller you may add this to allow minification
    # the trick behind is the existence of a sub named 'minify'
    # inside your Controller.

    use JavaScript::Minifier::XS qw(minify);
        # or:
    use CSS::Minifier::XS qw(minify);


=head1 DESCRIPTION

Catalyst Controller that concatenates (and optionally minifies) static files
like JavaScript or CSS into a single request. Depending on your configuration,
files are also auto-added with a simple dependency-management.

The basic idea behind concatenation is that all files one Controller should
handle reside in a common directory.

Assuming you have a directory with JavaScript files like:

    root/static/js
     |
     +-- prototype.js
     |
     +-- helpers.js
     |
     +-- site.js

Then you could combine all files in a single tag (assuming your directory for
the Controller is set to 'static/js' -- which is the default):

    <script type="text/javascript" src="/js/prototype/helpers/site.js"></script>

If you add a dependency into your Controller's config like:

    __PACKAGE__->config(
        ...
        depend => {
            helpers => 'prototype',
            site    => 'helpers',
        },
        ...
    );

Now, the URI to retrieve the very same JavaScript files can be shortened:

    <script type="text/javascript" src="/js/site.js"></script>

=head1 CONFIGURATION

A simple configuration of your Controller could look like this:

    __PACKAGE__->config(
        # the directory to look for files
        # defaults to 'static/<<action_namespace>>'
        dir => 'static/js',

        # the (optional) file extension in the URL
        # defaults to action_namespace
        extension => 'js',

        # optional dependencies
        depend => {
            scriptaculous => 'prototype',
            builder       => 'scriptaculous',
            effects       => 'scriptaculous',
            dragdrop      => 'effects',
            slider        => 'scriptaculous',
            myscript      => [ qw(slider dragdrop) ],
        },

        # name of the minifying routine (defaults to 'minify')
        # will be used if present in the package
        minifier => 'minify',

        # should a HTTP expire header be set? This usually means,
        # you have to change your filenames, if there a was change!
        expire => 1,

        # time offset (in seconds), in which the file will expire
        expire_in => 60 * 60 * 24 * 365 * 3, # 3 years

        # mimetype of response if wanted
        # will be guessed from extension if possible and not given
        # falls back to 'text/plain' if not guessable
        mimetype => 'application/javascript',
    );

=head2 CONFIGURATION OPTIONS

TODO: writeme...

=head1 METHODS

=head2 do_combine :Action

the C<do_combine> Action-method may be used like this (eg in YourApp:Controller:Js):

    sub default :Path {
        my $self = shift;
        my $c = shift;

        $c->forward('do_combine');
    }

However, a predeclared C<default> method like this is already present -- see
below.

All files in the remaining URL will be concatenated to a single resulting
stream and optionally minified if a sub named 'minify' in your Controller's
package namespace exists.

Thus, inside your Controller a simple

    # for JavaScript you may do
    use JavaScript::Minifier::XS qw(minify);

    # for CSS quite similar:
    use CSS::Minifier::XS qw(minify);

will do the job and auto-minify the stream.

If you specify an C<include> configuration option you also could recursively
include other files into the generated stream. (Think about @import in css files).

=cut

sub do_combine :Action {
    my $self = shift;
    my $c    = shift;

    my $response = $self->_combine($c, @_);

    #
    # deliver -- at least an empty line to make catalyst happy ;-)
    #
    my $minifier = $self->can($self->minifier)
        || \&_do_not_modify;
    $c->response->headers->content_type($self->mimetype)
        if $self->mimetype;
    # looks complicated but makes this routine testable...
    $c->response->headers->expires(DateTime->now->add(seconds => $self->expire_in)->epoch)
        if $self->expire && $self->expire_in;

    $c->response->body($minifier->($response) . "\n");
}

sub _combine {
    my $self = shift;
    my $c    = shift;

    return Combiner->new(
        ext          => $self->ext,
        dir          => $c->path_to('root', $self->dir)->resolve,
        dependencies => $self->_curried_coderef_dependencies($c),
        replacements => $self->replace,
        include      => $self->include,
    )->combine(@_);
}

sub _curried_coderef_dependencies {
    my ($self, $c);
    
    my %depencies;
    $dependencies{$_} = [
        map { 
            ref eq 'HASH' && exists $_->{type} && lc $_->{type} eq 'callback'
                ? $self->_curry_coderef($c, $_)
                : $_
        }
        map { ref eq 'ARRAY' ? @$_ : $_ }
        $self->depend->{$_}
    ]
        for keys %{$self->depend};
}

sub _curry_coderef {
    my ($self, $c, $hashref) = @_;
    
    my $callback = $hashref->{callback};
    my $curried_sub = sub { $self->$callback($c, @_) };
    
    return { %$hashref, callback => $curried_sub };
}

sub _do_not_modify { $_[0] };

=head2 default :Path

a standard handler for your application's controller

maps to the path_prefix of your actual controller and consumes the entire URI

=cut

sub default :Path {
    my $self = shift;
    my $c = shift;

    $c->forward('do_combine');
}

=head2 uri_for :Private

handle uri_for requests (not intentionally a Catalyst-feature :-) requires a
patched C<uri_for> method in your app! my one looks like the sub below.

If this method is used, the URI will only contain files that will not
automatically get added in by dependency resolution. Also, a simple
GET-parameter is added that reflects the unix-timestamp of the most resent
file that will be in the list of combined files. This helps the browser
to do proper caching even if files will change. Admittedly this is most of
the time needed during development.

    # in my app.pm:
    sub uri_for {
        my $c = shift;
        my $path = shift;
        my @args = @_;

        if (blessed($path) && $path->class && $path->class->can('uri_for')) {
            #
            # the path-argument was a component that can help
            # let the controller handle this for us
            #   believe me, it can do it!
            #
            return $c->component($path->class)->uri_for($c, $path, @args);
        }

        #
        # otherwise fall back into the well-known behavior
        #
        $c->next::method($path, @args);
    }

    # alternatively, using Catalyst 5.8 you may do this:
    around 'uri_for' => sub {
        my $orig = shift;
        my $c = shift;
        my $path = shift;
        my @args = @_;

        if (blessed($path) && $path->class && $path->class->can('uri_for')) {
            #
            # let the controller handle this for us
            #   believe me, it can do it!
            #
            return $c->component($path->class)->uri_for($c, $path, @args);
        }

        return $c->$orig($path, @args);
    };

=cut

sub uri_for :Private {
    my $self = shift;
    my $c    = shift;
    my $path = shift; # actually an action...
    my @args = @_;

    my $actual_path = $c->dispatcher->uri_for_action($path);
    $actual_path = '/' if $actual_path eq '';

    my $hash = calculate_hash($self->_combine($c, @parts));
    
    $c->uri_for("$actual_path", @parts, {h => $hash});
}

=head2 calculate_hash ( $content )

returns a hash from a given content. The default implementation returns the
first 10 digits of a MD5 hash. Please overload if a different hahavior is
wanted.

=cut

sub calculate_hash {
    my ($self, $content) = @_;
    
    return substr(0,10, md5_hex($content));
}

=head1 GOTCHAS

Please do not use C<namespace::autoclean> if you intend to enable a minifier.
The black magic behind the scenes tries to determine your intention to minify
by searching for a sub called C<minify> inside the controller's package.
However, this sub is imported by eg C<JavaScript::Minifier::XS> and will be
kicked out of the controller by C<namespace::autoclean>.

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
