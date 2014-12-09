package Fitness::Forms;

use strict;
use warnings;
no warnings qw(redefine);

use base 'Fitness::Base';
use Switch;

use Fitness::Schema;

sub form_GET : Runmode Authen {
	my $self = shift;

	if ( my $id = $self->param('id') ) {
		return $self->json_xs->convert_blessed->encode({form_id=>$id,forms=>[$self->schema->resultset("Sets")->search({form_id=>$id})]});
	} else {
		return $self->json_xs->convert_blessed->encode([$self->schema->resultset("Forms")->search({lifter_id=>$self->query->param('lifter_id')})]);
	}
}

sub bs_GET : Runmode Authen {
	my $self = shift;
	my $select = {};
	switch ( $self->param('bs') ) {
		case 'liftgroups' {
			$select = [map { [$_->TO_JSON->{liftgroup_id},$_->TO_JSON->{name}] } $self->schema->resultset("Liftgroups")->all];
		}
	}
	return "<select>\n<option value=\"\" />\n".join("\n", map { "<option value=\"$_->[0]\">$_->[1]</option>" } @$select)."\n</select>\n";
}

sub form_POST : Runmode Authen {
	my $self = shift;

	my $form = $self->from_json($self->query->param('keywords'));
	if ( $form->{form_id} == 0 ) {
		my $lifter = $self->schema->resultset("Forms")->create({lifter_id=>$form->{lifter_id}});
		foreach my $set ( keys %{$form->{sets}} ) {
			$lifter->add_to_sets({exercise_id=>$form->{sets}->{$set}->{exercise_id},pounds=>$form->{sets}->{$set}->{pounds},reps=>$form->{sets}->{$set}->{reps}});
		}
	} else {
		foreach ( keys %{$form->{sets}} ) {
			if ( my $set = $self->schema->resultset("Sets")->find({form_id=>$form->{form_id},exercise_id=>$form->{sets}->{$_}->{exercise_id}}) ) {
				if ( $form->{sets}->{$set->exercise_id}->{pounds} && $form->{sets}->{$set->exercise_id}->{reps} ) {
					$set->pounds($form->{sets}->{$set->exercise_id}->{pounds});
					$set->reps($form->{sets}->{$set->exercise_id}->{reps});
					$set->update;
				} else {
					$set->delete;
				}
			} elsif ( $form->{form_id} ) {
				if ( $form->{sets}->{$_}->{pounds} && $form->{sets}->{$_}->{reps} ) {
					$self->schema->resultset("Sets")->create({
						form_id => $form->{form_id},
						exercise_id => $form->{sets}->{$_}->{exercise_id},
						pounds => $form->{sets}->{$_}->{pounds},
						reps => $form->{sets}->{$_}->{reps},
					});
				}
			}
		}
	}
	return 1;
}

1;
