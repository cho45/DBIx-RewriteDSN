use Test::Dependencies
	exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic DBIx::RewriteDSN/],
	style   => 'light';
ok_dependencies();
