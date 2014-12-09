use lib 'lib';
use Fitness::Schema;
use JSON::XS;

my $json = JSON::XS->new;
my $schema = Fitness::Schema->connect('DBI:mysql:database=fitness;host=localhost', 'fitness', 'fitness');

#my $e = $schema->resultset("Exercises")->create({name=>'Bench Press'});
#my $lg = $schema->resultset("Liftgroups")->create({name=>'Faculty/Staff'});
#my $l = $schema->resultset("Lifters")->create({lastname=>'Adams', firstname=>'Stefan', gender=>'M', liftgroup_id=>$lg->id});

#my $s = $schema->resultset("Sets")->create({lifter_id=>1, exercise_id=>1, pounds=>150, reps=>10});


use Data::Dumper;
#use Data::Grouper;
#my $lifter = $schema->resultset("Forms")->search({form_id=>1})->first;
#print Dumper($lifter->TO_JSON), "\n";
print $json->convert_blessed->encode([$schema->resultset("Forms")->search({form_id=>18})->first]), "\n";
my $sums = $schema->resultset("Liftgroups")->search({}, {
	'+select' => [{sum => 'pounds * reps'}],
	'+as' => ['pounds'],
	'prefetch' => {lifters => {forms => {sets => {}}}},
	'group_by' => ['liftgroup_id'],
});
my %sums = ();
while (my $group = $sums->next) {
	my $pounds = $group->get_column('pounds');
	next unless $pounds;
	$sums{_} += $pounds;
	$sums{$group->name} += $pounds;
}
print Dumper(\%sums), "\n";
