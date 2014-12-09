package Fitness::Schema::Result::TotalPoundsVW;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('sets');
__PACKAGE__->add_columns(qw/id pounds/);
__PACKAGE__->set_primary_key('id');

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q[
    SELECT 1 id,sum(pounds*reps) pounds FROM sets JOIN forms USING (form_id) where year(time)=year(now()) and month(time)=month(now())
]);

1;
