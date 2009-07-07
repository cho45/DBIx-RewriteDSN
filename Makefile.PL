use inc::Module::Install;
name 'DBIx-RewriteDSN';
all_from 'lib/DBIx/RewriteDSN.pm';

requires $_ for (qw/ /);

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
