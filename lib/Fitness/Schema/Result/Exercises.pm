package Fitness::Schema::Result::Exercises;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('exercises');
__PACKAGE__->add_columns(qw/exercise_id name/);
__PACKAGE__->set_primary_key('exercise_id');
__PACKAGE__->has_many(sets => 'Fitness::Schema::Result::Sets', 'exercise_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->liftgroup_id }

1;
