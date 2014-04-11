use strict;
use warnings;
use Test::More;
# use Text::Exception;

use ok 'Catalyst::Controller::Combine::ReplaceDecorator';
my $class = 'Catalyst::Controller::Combine::ReplaceDecorator';

{
    package X;
    use Moose;
    extends 'Catalyst::Controller::Combine::Part';
    has content => (is => 'ro', isa => 'Str');
}

my $replace_decorator = $class->new(
    part    => X->new(content => 'you could make an x from a u'),
    search  => qr{u}xms,
    replace => 'X',
);
    
is $replace_decorator->content,
    'yoX coXld make an x from a X',
    'content changed';

$replace_decorator = $class->new(
    part    => X->new(content => 'a foo is a foo'),
    search  => qr{(foo)}xms,
    replace => '-$1-',
);
    
is $replace_decorator->content,
    'a -foo- is a -foo-',
    'content changed with $1';

done_testing;
