package Fitness::Exercises;

use strict;
use warnings;
no warnings qw(redefine);

use base 'Fitness::Base';

use Fitness::Schema;

sub all_GET : Runmode Authen {
	my $self = shift;

	return $self->json_xs->convert_blessed->encode({exercises => [$self->schema->resultset("Exercises")->all]});
}

sub search_POST : StartRunmode Authen {
	my $self = shift;

	$self->qs_parse($self->query->param('POSTDATA'));
	return $self->json_xs->convert_blessed->encode({rows => [$self->schema->resultset("Exercises")->search({}, {page=>$self->qs_param('page'), rows=>$self->qs_param('rows')})]});
}

sub cell_POST : Runmode Authen {
	my $self = shift;

	$self->schema->resultset("Exercises")->find($self->query->param('id'))->update({$self->query->param('celname') => $self->query->param($self->query->param('celname'))});
	return $self->to_json({sc=>'true',msg=>""});
}

sub edit_POST : Runmode Authen {
	my $self = shift;

	my %record = ();
	$record{$_} = $self->query->param($_) foreach $self->schema->source("Exercises")->columns;
	$self->schema->resultset("Exercises")->find($self->query->param('id'))->update({%record});
	return $self->to_json({sc=>'true',msg=>""});
}

sub add_POST : Runmode Authen {
	my $self = shift;

	my %record = ();
	$record{$_} = $self->query->param($_) foreach $self->schema->source("Exercises")->columns;
	$self->schema->resultset("Exercises")->create({%record});
	return $self->to_json({sc=>'true',msg=>""});
}

sub del_POST : Runmode Authen {
	my $self = shift;

	$self->schema->resultset("Exercises")->find($self->query->param('id'))->delete;
	return $self->to_json({sc=>'true',msg=>""});
}

1;
