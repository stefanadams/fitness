package Fitness::Stats;

use strict;
use warnings;
no warnings qw(redefine);

use base 'Fitness::Base';

use Fitness::Schema;
use Data::Dumper;
sub stats_GET : StartRunmode {
	my $self = shift;

	my $sums = $self->schema->resultset("Liftgroups")->search({}, {
		'+select' => [{sum => 'pounds * reps'}],
		'+as' => ['pounds'],
		'prefetch' => {lifters => {forms => {sets => {}}}},
		'group_by' => ['liftgroup_id'],
	});
	my $groups = {};
	my $total = 0;
	while (my $group = $sums->next) {
		my $pounds = $group->get_column('pounds');
		$pounds = 0 unless $pounds;
		$total += $pounds;
		$groups->{$group->id}->{name} = $group->name;
		$groups->{$group->id}->{pounds} += $pounds;
	}

	return $self->json_xs->convert_blessed->encode({total => $total, groups => $groups});
}

1;
