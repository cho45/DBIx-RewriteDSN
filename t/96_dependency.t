use Test::Dependencies
	exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic DBIx::RewriteDSN/],
	style   => 'light';

use ExtUtils::MakeMaker;
use Filter::Util::Call ;
ok_dependencies();
