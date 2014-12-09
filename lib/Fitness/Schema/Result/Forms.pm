package Fitness::Schema::Result::Forms;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Helper::Row::ToJSON/);
__PACKAGE__->table('forms');
__PACKAGE__->add_columns(qw/form_id time lifter_id/);
__PACKAGE__->set_primary_key('form_id');
__PACKAGE__->has_many(sets => 'Fitness::Schema::Result::Sets', 'form_id');
__PACKAGE__->belongs_to(lifter => 'Fitness::Schema::Result::Lifters', 'lifter_id');

sub id { shift->form_id(@_) }

sub TO_JSON {
	my $self = shift;

	return {
		lifter => $self->lifter,
		%{$self->next::method},
	}
}

1;
