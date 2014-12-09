package QI::Barcodes;

use strict;
use warnings;
no warnings qw(redefine);

use base 'QI::Base';

use Readonly;

Readonly my @BARCODES => qw/000000Z 000001A 000002A 000001B 000009A QIA_reset QIA_green QIA_red QIA_cancel QIM_empty QIM_null QIM_now QIF_received:QIM_now QIF_sold:QIM_now QIF_billed:QIM_now QIF_paid:QIM_now QIF_shipped:QIM_now QIF_customer QIF_customer:Amdocs QIF_model QIF_manufacturer QIF_manufacturer:HP QIF_location QIF_location:Rack1Shelf1Bay1/;

sub barcodes_GET : Runmode {
	my $self = shift;

	push @_, qq[<img src="http://www.barcodesinc.com/generator/image.php?code=$_&style=197&type=C128B&width=350&height=50&xres=1&font=5" /><br /><br />] foreach @BARCODES;

	return join '<br>', @_;
}

1;
