package DBIx::RewriteDSN;

use strict;
use warnings;
our $VERSION = '0.01';

use DBI;
use File::Slurp;

my $orig_connect = \&DBI::connect;
my $filename;
my $RULES;

sub import {
	my ($class, %opts) = @_;
	if ($opts{-file}) {
		$filename = $opts{-file};
		$RULES = File::Slurp::slurp($filename);
		$class->enable;
	}
	if ($opts{-rules}) {
		$RULES = $opts{-rules};
		$class->enable;
	}
}

sub enable {
	my ($class) = @_;
	no warnings 'redefine';
	*DBI::connect = \&_connect;
}

sub disable {
	my ($class) = @_;
	no warnings 'redefine';
	*DBI::connect = $orig_connect;
}

sub rewrite {
	my ($dsn) = @_;

	my $new_dsn;
	for (split /\n/, $RULES) {
		chomp;
		$_ =~ s/^\s+|\s+$//g;
		$_ or next;
		$_ =~ /^#/ and next;

		my ($match, $rewrite) = split(/\s+/, $_);
		if ($dsn =~ $match) {
			$new_dsn = eval(sprintf('"%s"', $rewrite || "")); ## no critic
			last;
		}
	}

	if ($new_dsn && $new_dsn ne $dsn) {
		print STDERR sprintf("Rewrote '%s' to '%s'\n", $dsn, $new_dsn);
		$dsn = $new_dsn;
	} else {
		print STDERR sprintf("Didn't rewrite %s\n", $dsn);
	}

	$dsn;
}

sub _connect {
	my ($class, $dsn, @rest) = @_;
	$dsn = DBIx::RewriteDSN::rewrite($dsn);
	$orig_connect->($class, $dsn, @rest);
}


1;
__END__

=head1 NAME

DBIx::RewriteDSN - dsn rewriter for debug

=head1 SYNOPSIS

  use DBIx::RewriteDSN -rules => q{
    dbi:SQLite:dbname=foobar dbi:SQLite:dbname=test_foobar
  };

  ## DBIx::RewriteDSN redefine DBI::connect and 
  ## rewrite dsn passed to DBI::connect
  my $dbh = DBI::connect("dbi:SQLite:dbname=foobar", "", "");

  $dbh->{Driver}->{Name} #=> dbname=test_foobar


=head1 DESCRIPTION

DBIx::RewriteDSN is dsn rewriter like mod_rewrite.


=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
