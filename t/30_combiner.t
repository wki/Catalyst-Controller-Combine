use strict;
use warnings;
use Test::More;
use FindBin;
use Path::Class;
use Test::Exception;

use ok 'Catalyst::Controller::Combine::Combiner';
my $class = 'Catalyst::Controller::Combine::Combiner';

my $dir = dir($FindBin::Bin)->resolve->absolute->subdir('root/static/css');

note 'file factory method - pure';
{
    my $combiner = $class->new(
        dir => $dir,
        ext => 'css',
    );

    # not existing file
    is $combiner->file('not_there.css'), undef, 'not existing file';
    is $combiner->file('not_there'),     undef, 'not existing file w/o ext';

    # fake file already seen
    $combiner->_file_seen->{$dir->file('css1.css')} = 1;
    is $combiner->file('css1.css'), undef, 'seen file';
    is $combiner->file('css1'),     undef, 'seen file w/o ext';
    $combiner->_clear_files_seen;

    # regular usage with extension
    my $file_part = $combiner->file('css1.css');
    isa_ok $file_part, 'Catalyst::Controller::Combine::FilePart', 'file_part';
    is $file_part->file->stringify,
        $dir->file('css1.css'),
        'file with extension';

    is $combiner->file('css1.css'), undef, 'cache hit with extension';
    is $combiner->file('css1'), undef, 'cache hit without extension';
    $combiner->_clear_files_seen;

    # regular usage without extension
    $file_part = $combiner->file('css1');
    isa_ok $file_part, 'Catalyst::Controller::Combine::FilePart', 'file_part';
    is $file_part->file->stringify,
        $dir->file('css1.css'),
        'file without extension';

    is $combiner->file('css1.css'), undef, 'cache hit with extension';
    is $combiner->file('css1'), undef, 'cache hit without extension';
    $combiner->_clear_files_seen;
}

note 'file factory method - with replacement';
{
    my $combiner = $class->new(
        dir => $dir,
        ext => 'css',
        replacements => {
            'jquery*.css' => [
                { search => 's1', replace => 'r1' },
            ],
            'css*.css' => [
                { search => 's2', replace => 'r2' },
            ],
        },
    );
    
    my $part = $combiner->file('css1');
    isa_ok $part, 'Catalyst::Controller::Combine::ReplaceDecorator', 'part';
    isa_ok $part->part, 'Catalyst::Controller::Combine::FilePart', 'part->part';
    is $part->search, 's2', 'search';
}

note 'file factory method - with include';
{
    my $combiner = $class->new(
        dir => $dir,
        ext => 'css',
        include => [
            'i1',
        ],
    );
    
    my $part = $combiner->file('css1');
    isa_ok $part, 'Catalyst::Controller::Combine::IncludeDecorator', 'part';
    isa_ok $part->part, 'Catalyst::Controller::Combine::FilePart', 'part->part';
    is_deeply $part->include, ['i1'], 'include';
    is $part->combiner, $combiner, 'combiner';
}

note 'part factory method';
{
    my $combiner = $class->new(
        dir => $dir,
        ext => 'css',
        dependencies => {
            css2 => [qw(base)],
        },
    );
    
    # unknown type
    dies_ok { $combiner->part({type => 'Foo'}) }
        '{ type => Foo } dies';
    
    # callback
    dies_ok { $combiner->part({type => 'callback'}) }
        '{ type => callback } dies w/o coderef';
    
    my $part = $combiner->part(
        { type => 'callback', callback => sub { 'result' } },
    );
    
    isa_ok $part, 'Catalyst::Controller::Combine::CallbackPart', 'callback_part';
    is $part->content, 'result', 'callback content';
    
    # unfulfilled dependencies
    $part = $combiner->part('css1');
    isa_ok $part, 'Catalyst::Controller::Combine::FilePart', 'file_part';
    
    # fulfilled dependencies
    $part = $combiner->part('css2');
    isa_ok $part, 'Catalyst::Controller::Combine::Sequence', 'sequence';
    is_deeply [ map { $_->file->basename } $part->all_parts ],
        [ 'base.css', 'css2.css' ],
        'sequence with dependencies';
}

note 'usage';
{
    my $combiner = $class->new(
        dir => $dir,
        ext => 'css',
        dependencies => {
            css2 => [qw(base)],
        },
    );
    
    is $combiner->combine('css2'), '/* base.css *//* css2.css */', 'css2';
}

done_testing;
