package Fitness::Schema::Result::LiftersAC;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('lifters');
__PACKAGE__->add_columns(qw/label category value pounds/);
__PACKAGE__->set_primary_key('value');

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q[
    SELECT concat_ws(', ', lastname, firstname) label, liftgroups.name category, lifter_id value, sum(pounds*reps) pounds FROM lifters JOIN liftgroups USING (liftgroup_id) LEFT JOIN forms USING (lifter_id) LEFT JOIN sets USING (form_id) GROUP BY category,label
]);

1;
