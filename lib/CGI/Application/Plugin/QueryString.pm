package CGI::Application::Plugin::QueryString;

use warnings;
use strict;

use base 'Exporter';
our @EXPORT = qw[qs_parse qs_param];

sub qs_parse {
	my $self = shift;

	return undef if ref $self->{__CAP_QUERYSTRING} eq 'HASH';

	my $qs = shift || $ENV{'QUERY_STRING'};

	return undef unless $qs;

	$self->{__CAP_QUERYSTRING} = {};
	if ( length($qs) > 0 ) {
		my $buffer = $qs;
		my @pairs = split(/&/, $buffer);
		foreach my $pair ( @pairs ) {
			my ($name, $value) = split(/=/, $pair);
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			$self->{__CAP_QUERYSTRING}->{$name} = $value; 
		}
	}
}

sub qs_param {
	my $self = shift;

	return undef unless ref $self->{__CAP_QUERYSTRING} eq 'HASH';

	if ( ref $_[0] eq 'HASH' ) {
		$self->{__CAP_QUERYSTRING}->{$_} = $_[0]->{$_} foreach keys %{$_[0]};
	} else {
		my ($k, $v) = @_;
		if ( $v ) {
			$self->{__CAP_QUERYSTRING}->{$k} = $v;
		} else {
			return $self->{__CAP_QUERYSTRING}->{$k};
		}
	}
}

1;
