package Fitness::Base;

use strict;
use warnings;
no warnings qw(redefine);

use base 'CGI::Application';
use Apache2::Const qw/:common/;
use CGI::Application::Plugin::AutoRunmode;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Forward;
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::AnyTemplate;
use CGI::Application::Plugin::JSON ':all';
use CGI::Application::Plugin::JSON_XS;
use CGI::Application::Plugin::QueryString;
use CGI::Application::Plugin::ConfigAuto (qw/cfg cfg_file/);
use CGI::Application::Plugin::DBIx::Class ':all';

sub cgiapp_init {
	my $self = shift;

	$self->cfg_file($ENV{CONFIG});
	chdir $self->cfg('TEMPLATES');
	$self->dbic_config({schema => 'Fitness::Schema', connect_info => $self->cfg('DATA_SOURCE')});
        $self->template->config(
                default_type => 'TemplateToolkit',
                include_paths => $self->cfg('TEMPLATES'),
                TemplateToolkit => {
                        EVAL_PERL => 1,
                },
                template_filename_generator => \&template_filename_generator,
	);
	$self->session_config(
		CGI_SESSION_OPTIONS => [ "driver:mysql", $self->query, {Handle=>$self->schema->storage->dbh} ],
	);
	$self->authen->config(
		DRIVER => [ 'DBI',
			DBH => $self->schema->storage->dbh,
			TABLE => 'users',
			CONSTRAINTS => {
				'users.username' => '__CREDENTIAL_1__',
				'MD5:users.password' => '__CREDENTIAL_2__'
			},
		],
		CREDENTIALS => ['username', 'password'],	# This is the names of the POST keys that will be checked and presented by loginbox
		STORE => 'Session',
		LOGIN_RUNMODE => 'login',
	);
}

sub login_GET : Runmode { shift->authen->login_box }
sub login_POST : Runmode { shift->authen->login_box }
sub logout_GET : Runmode { shift->authen->logout; join(
	"\n",
	CGI::start_html(-title => 'Signed Out!'),
	CGI::h2('Signed Out'),
	CGI::a({href=>'/login.html'}, "Sign In"),
	CGI::end_html(),
)}

sub template_filename_generator {
	my $self     = shift;
	my $run_mode = $self->get_current_runmode;
	$run_mode    =~ s/_[A-Z]+$//;
	my $module   = ref $self;
	my @segments = split /::/, $module;
	$self->dumper(File::Spec->catfile(@segments, $run_mode));
	return File::Spec->catfile(@segments, $run_mode);
}

1;
