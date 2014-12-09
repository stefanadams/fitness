package Fitness::Lifters;

use strict;
use warnings;
no warnings qw(redefine);

use base 'Fitness::Base';

use Data::Page;
use Fitness::Schema;

sub ac_GET : Runmode Authen {
	my $self = shift;

	my $term = '%'.$self->query->param('term').'%';
warn "Term: $term\n";
	return $self->json_xs->convert_blessed->encode([$self->schema->resultset("LiftersAC")->search([{label=>{-like=>$term}},{value=>{-like=>$term}}])]);
}

sub search_POST : StartRunmode Authen {
	my $self = shift;

	$self->qs_parse($self->query->param('POSTDATA'));
	#return $self->json_xs->convert_blessed->encode({rows => [$self->schema->resultset("Lifters")->search({}, {page=>$self->qs_param('page'), rows=>$self->qs_param('rows')})]});
	my $rs = $self->schema->resultset("Lifters")->search({}, {page=>$self->qs_param('page'), rows=>$self->qs_param('rows')});
	my $page = $rs->pager();
	return $self->json_xs->convert_blessed->encode({page=>$page->current_page, records=>$page->total_entries, total=>$page->last_page, rows=>[$rs->page($page->current_page)->all]});
}

sub cell_POST : Runmode Authen {
	my $self = shift;

	$self->schema->resultset("Lifters")->find($self->query->param('id'))->update({$self->query->param('celname') => $self->query->param($self->query->param('celname'))});
	return $self->to_json({sc=>'true',msg=>""});
}

sub edit_POST : Runmode Authen {
	my $self = shift;

	my %record = ();
	$record{$_} = $self->query->param($_) foreach $self->schema->source("Lifters")->columns;
	$self->schema->resultset("Lifters")->find($self->query->param('id'))->update({%record});
	return $self->to_json({sc=>'true',msg=>""});
}

sub add_POST : Runmode Authen {
	my $self = shift;

	my %record = ();
	$record{$_} = $self->query->param($_) foreach $self->schema->source("Lifters")->columns;
	$self->schema->resultset("Lifters")->create({%record});
	return $self->to_json({sc=>'true',msg=>""});
}

sub del_POST : Runmode Authen {
	my $self = shift;

	$self->schema->resultset("Lifters")->find($self->query->param('id'))->delete;
	return $self->to_json({sc=>'true',msg=>""});
}

1;
