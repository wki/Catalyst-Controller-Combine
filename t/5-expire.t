use Test::More;
use Test::Exception;
use Catalyst ();
use FindBin;
use DateTime;
use DateTime::Duration;



# a simple package
{
    package MyApp::Controller::Js;
    use Moose;
    extends 'Catalyst::Controller::Combine';

    __PACKAGE__->config(
    #    expire    => 1,
    #    expire_in => 60 * 60, # 1 hour
    );
}


#
# test start...
#

# setup our Catalyst :-)
my $c = Catalyst->new();
$c->setup_log();
$c->setup_home("$FindBin::Bin");

my $controller;
lives_ok { $controller = $c->setup_component('MyApp::Controller::Js') } 'setup component worked';


#
# check if expires header is sent, if feature isn't turned on
#
eval {
    $controller->do_combine($c, 'js1');
    if (!$c->response->header('expires')) {
        ok("expires header not sent, if feature not active");
    }
    else {
        die;
    }
};
if ($@) {
    fail("expires header not sent, if feature not active");
}


# okay, let's check the real stuff, turn this feature one
MyApp::Controller::Js->config->{expire} = 1;
$controller = $c->setup_component('MyApp::Controller::Js');



#
# combine and check if expire header is set and correct (no expire_in is explicitely set)
#
eval {
    $controller->do_combine($c, 'js1');
    my $expected_date_str = (DateTime->now + DateTime::Duration->new(seconds => $controller->{expire_in}))->strftime( "%a, %d %b %Y %H:%M:%S GMT" );
    if ($c->response->header('expires') && $c->response->header('expires') eq $expected_date_str) {
        ok('expires in "standard expire delta"');
    }
    else {
        die;
    }
};
if ($@) {
    print $@;
    fail('expires in "standard expire delta"');
}



#
# combine and check if expire header is set and correct (expire_in = 60 minutes)
#
eval {
    MyApp::Controller::Js->config->{expire_in} = 60 * 60; # one hour
    $controller = $c->setup_component('MyApp::Controller::Js');
    $controller->do_combine($c, 'js1');
    my $expected_date_str = (DateTime->now + DateTime::Duration->new(seconds => MyApp::Controller::Js->config->{expire_in}))->strftime( "%a, %d %b %Y %H:%M:%S GMT" );
    if ($c->response->header('expires') && $c->response->header('expires') eq $expected_date_str) {
        ok('expires in one hour');
    }
    else {
        die;
    }
};
if ($@) {
    fail('expires in one hour');
}



done_testing;
