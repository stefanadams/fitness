package QI::XLS;

use strict;
use warnings;

use base 'QI::Base';
use Spreadsheet::WriteExcel;
use QI::Schema;

sub qi_GET : Runmode {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'qi.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $assets = $self->schema->resultset("Assets");
	my $row=0;
	while ( my $asset = $assets->next ) {
		my %asset = $asset->get_columns;
		$worksheet->write($row++, 0, [values %asset]);
	}
	$workbook->close;
	close $fh;
	return $str;
}

1;
