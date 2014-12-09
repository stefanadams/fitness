package QI::Input;

use strict;
use warnings;
no warnings qw(redefine);

use base 'Fitness::Base';

use Readonly;
use Date::Manip;
use Fitness::Schema;
use Switch;

use vars qw/$TAG $ACTION $FIELD $MACRO $TAGFIELDS @WANT @NOCOPY/;

sub input_POST : Runmode {
	my $self = shift;

	$self->get_record;
	$self->process_record;
	$self->return_records;
}

################################

sub warn_session {
	my $self = shift;
	no warnings;
	warn "------------------\n" unless $self->{__QI_WARN};
	warn join(' -=- ', ($_[0]||''), ++$self->{__QI_WARN}, 'input->'.$self->query->param('input'), 'tag->'.($self->session->param('record')?$self->session->param('record')->tag:''), 'cell->'.$self->session->param('field').'='.$self->session->param('value')), "\n";
}

sub get_record {
	my $self = shift;
	my $LIFTER = qr/^L_(\d+)_L$/;
	my $EXERCISES = qr/^E_(\w+)_E$/;
	if ( $self->query->param('input') && $self->query->param('input') =~ $LIFTER ) {
		$self->query->param(input => $self->generate_tag) if $self->query->param('input') eq '000000Z';
		if ( !$self->session->param('exercise') || $self->session->param('exercise') !~ $EXERCISES ) {
			# Start of a new record
			$self->session->clear([qw/exercise pounds reps/]);
			if ( my $record = $self->schema->resultset("Fitness")->find({lifter => $self->query->param('input')}) ) {
				$self->session->param(record => $record);
			} else {
				$self->warn_session('A5');
				# Create a new record
				$self->session->param(record => $self->schema->resultset("Fitness")->create({lifter => $self->query->param('input')}));
			}
		}
	}
	$self->reset unless $self->session->param('record');
}

sub process_record {
	my $self = shift;
	return unless $self->session->param('record') && $self->query->param('input');
	$self->autofield(1);
	$self->warn_session('C');
	if ( $self->query->param('input') =~ $FIELD ) {
		$self->session->param(field => $1);
		$self->session->param(value => $3);
	} elsif ( $self->query->param('input') =~ $ACTION ) {
		switch ( $1 ) {
			case 'reset' {
				$self->reset;
			}
			case 'cancel' {
				$self->clear;
			}
		}
	} elsif ( $self->query->param('input') =~ $TAG && $self->session->param('field') && $self->session->param('field') =~ $TAGFIELDS ) {
		$self->session->param(value => $self->query->param('input'));
	} elsif ( $self->query->param('input') !~ $TAG ) {
		$self->session->param(value => $self->query->param('input'));
	} else {
		$self->warn_session;
	}
	$self->reset if $self->session->param('field') && $self->session->param('field') eq 'tag';
	$self->deflate_macro;
	$self->update_record;
	$self->autofield;
}

sub update_record {
	my $self = shift;
	return unless $self->session->param('record');
	my $record = $self->schema->resultset("Assets")->find({lifter => $self->session->param('record')->lifter});
	my $field = $self->session->param('exercise');
	my $value = $self->session->param('value');
	return unless $field && defined $value;
	$record->$exercise($value eq "\0" ? undef : $value);
	$record->update;
	$self->session->param(record => $record);
	$self->session->clear([qw/exercise pounds reps/]);
}

sub autofield {
	my $self = shift;
	return unless $self->session->param('record');
	if ( defined $_[0] ) {
		$self->session->param(autofield => $_[0]);
	} else {
		return if $self->session->param('exercise') || !$self->session->param('autofield');
		my $record = $self->session->param('record');
		$self->session->param(exercise => $_) and last foreach grep { !$record->$_ } @WANT;
		$self->session->param(autofield => 0);
	}
}

sub clean_session {
	my $self = shift;
	unless ( $self->session->param('record') ) {
		$self->autofield(0);
		$self->session->clear('exercise');
	}
	$self->session->clear('pounds');
	$self->session->clear('reps');
}

sub reset {
	my $self = shift;
	$self->autofield(0);
	$self->session->clear([qw/record exercise pounds reps/]);
}

sub clear {
	my $self = shift;
	$self->autofield(0);
	$self->session->clear([qw/exercise pounds reps/]);
}

sub return_records {
	my $self = shift;
	$self->clean_session;
	my @records = ();
	my ($k, $v);
	if ( my $record = $self->session->param('record') ) {
		my %record = $record->get_inflated_columns;
		do { $record{$k} = $record->$v if ref $v; } while ($k, $v) = each %record;
		push @records, {%record};
	} else {
		push @records, {};
	}
	foreach my $recent ( $self->schema->resultset("RecentAssets")->all ) {
		next unless defined $recent;
		my %recent = $recent->get_inflated_columns;
		do { $recent{$k} = $recent->$v if ref $v; } while ($k, $v) = each %recent;
		push @records, {%recent};
	}
	return $self->to_json({lifter=>($self->session->param('record')?$self->session->param('record')->lifter:undef), exercise=>$self->session->param('exercise'), records=>[@records]});
}

1;
