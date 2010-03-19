use inc::Module::Install;

name     'Catalyst-Controller-Combine';
all_from 'lib/Catalyst/Controller/Combine.pm';
author   'Wolfgang Kinkeldei <wolfgang@kinkeldei.de>';
license  'perl';
perl_version '5.8.0';

requires 'Moose'             => '0.74';
requires 'Catalyst::Runtime' => '5.80';
requires 'File::stat'        => '1.00';
requires 'List::Util'        => '1.19';
requires 'Path::Class'       => '0.16';
requires 'FindBin'           => '1.47';

test_requires 'Test::Builder'         => '0.86';
test_requires 'Test::Builder::Tester' => '1.18';
test_requires 'Test::More'            => '0.86';
test_requires 'Test::Exception'       => '0.27';
test_requires 'Test::Harness'         => '3.14';
test_requires 'Text::Glob'            => '0.08';

auto_install;

repository 'http://github.com/wki/Catalyst-Controller-Combine.git';

WriteAll;

