use strict;
use warnings;
use Test::More;
use Test::Exception;

use ok 'Catalyst::Controller::Combine::Part';
my $class = 'Catalyst::Controller::Combine::Part';

my $part = $class->new;
dies_ok { $part->content } 'content dies';

done_testing;
