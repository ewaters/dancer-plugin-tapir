use strict;
use warnings;
use Test::More;
use FindBin;
use Dancer qw(config);
use Dancer::Test;
use Dancer::Plugin::Tapir;

config->{plugins}{Tapir} = {
	thrift_idl    => $FindBin::Bin . '/thrift/dancer.thrift',
	handler_class => 'MyWebApp::Handler',
};

$INC{'MyWebApp/Handler.pm'} = undef;
{
	package MyWebApp::Handler;

	use Moose;
	extends 'Tapir::Server::Handler::Class';

	__PACKAGE__->service('Accounts');

	__PACKAGE__->add_method('createAccount');
	sub createAccount {
		my ($class, $call) = @_;
		my %args = $call->args('plain');
		my ($username, $password) = @args{'username', 'password'};
		print "createAccount called with $username and $password\n";
		$call->set_result({
			id         => 42,
			allocation => 1000,
		});
	}

	__PACKAGE__->add_method('getAccount');
	sub getAccount {
	}
}

setup_thrift_handler;

response_status_is [ GET => '/' ], 404, "No root route";

response_status_is [ GET => '/accounts' ], 404, "No GET /accounts";
response_status_is [ POST => '/accounts' ], 500, "POST /accounts exists (but throws internal error without args)";
response_status_is [ POST => '/accounts?username=johndoe&password=abc123' ], 200, "POST /accounts with args";

done_testing;
