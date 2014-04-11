use strict;
use warnings;
use Path::Class;
use Test::More;

use ok 'Catalyst::Controller::Combine::FilePart';
my $class = 'Catalyst::Controller::Combine::FilePart';

my $dir = Path::Class::tempdir(CLEANUP => 1);
my $file = $dir->file('xxx.js');
$file->spew("line1\nline2");

my $filepart = $class->new(file => $file);

is $filepart->content, "line1\nline2", 'content';

done_testing;