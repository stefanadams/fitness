package Fitness::Schema::Result::FormsExpanded;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('forms');
__PACKAGE__->add_columns(qw/form_id time lifter_id lastname firstname gender liftgroup_id liftgroup set_id exercise_id exercise pounds reps/);
__PACKAGE__->set_primary_key('form_id');

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q[
    select form_id,time,lifter_id,lastname,firstname,gender,liftgroup_id,liftgroups.name liftgroup,set_id,exercise_id,exercises.name exercise,pounds,reps from forms join sets using (form_id) join exercises using (exercise_id) join lifters using (lifter_id) join liftgroups using (liftgroup_id)
]);

1;
