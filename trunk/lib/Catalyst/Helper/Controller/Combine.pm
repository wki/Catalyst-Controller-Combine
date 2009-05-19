package Catalyst::Helper::Controller::Combine;

use strict;

=head1 NAME

Catalyst::Helper::Controller::Combine - Helper for Combine Controllers

=head1 SYNOPSIS

    script/create.pl view Js Combine
    script/create.pl view Css Combine

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
    if ($ext eq 'js')  { 
        $mimetype = 'application/javascript';
        $minifier = "# uncomment if desired\n# use JavaScript::Minifier::XS qw(minify);";
        $depend =
        "    #     scriptaculous => 'prototype',\n" .
        "    #     builder       => 'scriptaculous',\n" .
        "    #     effects       => 'scriptaculous',\n" .
        "    #     dragdrop      => 'effects',\n" .
        "    #     slider        => 'scriptaculous',\n" .
        "    #     default       => 'dragdrop',";
    }
    if ($ext eq 'css') { 
        $mimetype = 'text/css'; 
        $minifier = "# uncomment if desired\n# use CSS::Minifier::XS qw(minify);";
        $depend =
        "    #     default => 'layout',";
    }
    
    $helper->render_file( 'compclass', $file, 
                          {
                              ext       => $ext,
                              mimetype  => $mimetype,
                              minifier  => $minifier,
                              depend    => $depend,
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

use strict;
use warnings;
use parent 'Catalyst::Controller::Combine';

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
