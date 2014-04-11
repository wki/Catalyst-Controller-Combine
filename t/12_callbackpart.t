use strict;
use warnings;
use Test::More;

use ok 'Catalyst::Controller::Combine::CallbackPart';
my $class = 'Catalyst::Controller::Combine::CallbackPart';

my $callback = $class->new(callback => sub { 'hello coderef' });

is $callback->content, 'hello coderef', 'content';

done_testing;
