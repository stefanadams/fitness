package Fitness::Schema::Result::Liftgroups;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('liftgroups');
__PACKAGE__->add_columns(qw/liftgroup_id name/);
__PACKAGE__->set_primary_key('liftgroup_id');
__PACKAGE__->has_many(lifters => 'Fitness::Schema::Result::Lifters', 'liftgroup_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->liftgroup_id }

1;
