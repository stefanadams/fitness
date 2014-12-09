package Fitness::Schema::Result::Lifters;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('lifters');
__PACKAGE__->add_columns(qw/lifter_id lastname firstname liftgroup_id gender/);
__PACKAGE__->set_primary_key('lifter_id');
__PACKAGE__->has_many(forms => 'Fitness::Schema::Result::Forms', 'lifter_id');
__PACKAGE__->belongs_to(liftgroup => 'Fitness::Schema::Result::Liftgroups', 'liftgroup_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->lifter_id }

sub name {
	my $self = shift;
	return join ', ', $self->lastname, $self->firstname;
}

sub TO_JSON {
	my $self = shift;

	return {
		liftgroup => $self->liftgroup,
		%{$self->next::method},
	}
}

1;
