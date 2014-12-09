package Fitness::Schema::Result::Sets;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Helper::Row::ToJSON/);
__PACKAGE__->table('sets');
__PACKAGE__->add_columns(qw/form_id exercise_id pounds reps/);
__PACKAGE__->set_primary_key(qw/form_id exercise_id/);
__PACKAGE__->belongs_to(form => 'Fitness::Schema::Result::Forms', 'form_id');
__PACKAGE__->belongs_to(exercise => 'Fitness::Schema::Result::Exercises', 'exercise_id');

sub id { shift->set_id(@_) }

sub TO_JSON {
	my $self = shift;

	return {
		form => $self->form,
		%{$self->next::method},
	}
}

1;
