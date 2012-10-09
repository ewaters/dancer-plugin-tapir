use strict;
use warnings;
use File::Temp qw();
use Test::More;
use FindBin;
use Dancer qw(config);
use Dancer::Test;
use Dancer::Plugin::Tapir;

my $nd_bin = `which NaturalDocs`;
chomp $nd_bin;
if (! $nd_bin) {
    plan skip_all => "You must have NaturalDocs in your path to test the docs";
}
else {
    plan tests => 1;
}

my $tempdir = File::Temp->newdir();

config->{plugins}{Tapir} = {
    thrift_idl => $FindBin::Bin . '/thrift/example.thrift',
    documentation_staging_dir => $tempdir,
    naturaldocs_bin => $nd_bin,
};

setup_tapir_documentation
    path => '/tapir/docs';

response_status_is [ GET => '/tapir/docs/' ], 200, "Found tapir docs";

done_testing;
