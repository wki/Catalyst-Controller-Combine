use strict;
use warnings;
use Test::More;
# use Text::Exception;

use ok 'Catalyst::Controller::Combine::IncludeDecorator';
my $class = 'Catalyst::Controller::Combine::IncludeDecorator';

{
    package MockCombiner;
    use Moose;
    sub combine { "($_[1])" } # simply returns '($path)'
    
    package X;
    use Moose;
    extends 'Catalyst::Controller::Combine::Part';
    has content => (is => 'ro', isa => 'Str');
}

note 'no include';
{
    my $include_decorator = $class->new(
        part     => X->new(content => 'x content'),
        combiner => MockCombiner->new,
        # no include !
    );
    
    is $include_decorator->content,
        'x content',
        'content unchanged';
}

note 'with include';
{
    my $include_decorator = $class->new(
        part     => X->new(content => 'before<include "blabla">after'),
        combiner => MockCombiner->new,
        include  => [
            qr{<include\s*"([^"]+)"\s*>}xms,
        ],
    );
    
    is $include_decorator->content,
        'before(blabla)after',
        'included content';
}

done_testing;
