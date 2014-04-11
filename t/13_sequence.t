use strict;
use warnings;
use Test::More;

use ok 'Catalyst::Controller::Combine::Sequence';
my $class = 'Catalyst::Controller::Combine::Sequence';

{
    package X;
    use Moose;
    extends 'Catalyst::Controller::Combine::Part';
    has content => (is => 'ro', isa => 'Str');
}

my $sequence = $class->new();
is $sequence->content, '', 'empty content';

$sequence->append();
is $sequence->content, '', 'nothing appended';

$sequence->append(X->new(content => 'part 1'));
is $sequence->content, 'part 1', 'appended part 1';

$sequence->append(X->new(content => 'part 2'));
is $sequence->content, 'part 1part 2', 'appended part 2';

done_testing;
