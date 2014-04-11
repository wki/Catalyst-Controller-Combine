use strict;
use warnings;
use Test::More;
# use Text::Exception;

use ok 'Catalyst::Controller::Combine::IncludeDecorator';
my $class = 'Catalyst::Controller::Combine::IncludeDecorator';

{
    package C;
    use Moose;
    sub combine { $_->[1] }
    
    package X;
    use Moose;
    extends 'Catalyst::Controller::Combine::Part';
    has content => (is => 'ro', isa => 'Str');
}

# no include --> unchanged

# include with empty replacement -> just replaced

# include with file name replacement -> replace



done_testing;
