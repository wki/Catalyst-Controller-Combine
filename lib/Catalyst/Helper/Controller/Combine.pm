package Catalyst::Helper::Controller::Combine;

use strict;

=head1 NAME

Catalyst::Helper::Controller::Combine - Helper for Combine Controllers

=head1 SYNOPSIS

    script/create.pl controller Js Combine
    script/create.pl controller Css Combine

=head1 DESCRIPTION

Helper for Combine Controllers.

=head2 METHODS

=head3 mk_compclass

=cut

sub mk_compclass {
    my ( $self, $helper ) = @_;
    my $file = $helper->{file};
    
    my $ext = lc($helper->{name}) || 'xx';
    $ext =~ s{\A .* ::}{}xms;
    
    my $mimetype = 'text/plain';
    my $minifier = '';
    my $depend = '';
    my $replace = '';
    if ($ext eq 'js')  { 
        $mimetype = 'application/javascript';
        $minifier = "# uncomment if desired and do not import namespace::autoclean!\n# use JavaScript::Minifier::XS qw(minify);";

        $depend =
        "    # aid for the prototype users\n" .
        "    #   --> place all .js files directly into root/static/js!\n" .
        "    #     scriptaculous => 'prototype',\n" .
        "    #     builder       => 'scriptaculous',\n" .
        "    #     effects       => 'scriptaculous',\n" .
        "    #     dragdrop      => 'effects',\n" .
        "    #     slider        => 'scriptaculous',\n" .
        "    #     default       => 'dragdrop',\n" .
        "\n" .
        "    # aid for the jQuery users\n" .
        "    #   --> place all .js files including version-no directly into root/static/js!\n" .
        "    #     'jquery.metadata'     => 'jquery-1.3.2'\n",
        "    #     'jquery.form-2.36'    => 'jquery-1.3.2'\n",
        "    #     'jquery.validate-1.6' => [qw(jquery.form-2.36 jquery.metadata)]\n",
        "    #     default               => [qw(jquery.validate-1.6 jquery-ui-1.7.2)]",
    }
    if ($ext eq 'css') { 
        $mimetype = 'text/css'; 
        $minifier = "# uncomment if desired and do not import namespace::autoclean!\n# use CSS::Minifier::XS qw(minify);";

        $depend =
        "    #     layout  => 'jquery-ui', \n" .
        "    #     default => 'layout',";

        $replace =
        "    #                    # change jQuery UI's links to images\n" .
        "    #                    # assumes that all images for jQuery UI reside under static/images\n" .
        "    #     'jquery-ui' => [ qr'url\(images/' => 'url(/static/images/' ],";
    }
    
    $helper->render_file( 'compclass', $file, 
                          {
                              ext       => $ext,
                              mimetype  => $mimetype,
                              minifier  => $minifier,
                              depend    => $depend,
                              replace   => $replace,
                          } );
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Helper>

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;

__DATA__

__compclass__
package [% class %];

use Moose;
BEGIN { extends 'Catalyst::Controller::Combine' }

[% minifier %]

__PACKAGE__->config(
    #   optional, defaults to static/<<action_namespace>>
    # dir => 'static/[% ext %]',
    #
    #   optional, defaults to <<action_namespace>>
    # extension => '[% ext %]',
    #
    #   specify dependencies (without file extensions)
    # depend => {
[% depend %]
    # },
    #
    #   optionally specify replacements to get done
    # replace => {
[% replace %]
    # },
    #
    #   will be guessed from extension
    # mimetype => '[% mimetype %]',
    #
    #   if you want another minifier change this
    # minifier => 'minify',
);

#
# defined in base class Catalyst::Controller::Combine
# uncomment and modify if you like
#
# sub default :Path {
#     my $self = shift;
#     my $c = shift;
#     
#     $c->forward('do_combine');
# }

=head1 NAME

[% class %] - Combine View for [% app %]

=head1 DESCRIPTION

Combine View for [% app %]. 

=head1 SEE ALSO

L<[% app %]>

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
