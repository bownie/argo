#!/usr/bin/perl -w

use strict;
use File::Basename;
use IO::Socket::INET;
use Argo;

# Install an int sig handler
#
use sigtrap 'handler' => \&intHandler, 'INT';

# Globals
#
my $argo = undef;
my $port = 30767;
my $processId = $$;    # my process id
my $scriptName = basename($0);
my $configFile="argo.conf";

my $my_socket = undef;
my $input_message = $ARGV[0];

# Usage statement
#
sub usage() {
  print "usage: $0 <message text>\n";
}

# Check the input arguments
#
sub checkArgs() {
  if ( $#ARGV ne 0 ) {
    usage();
    exit(1);
  }
}

# Our local signal handler for interrupts - tidy up and exit
#
sub intHandler() {
  closeSocket();
  print "Interrupted.  Exiting PID ".$processId."\n";
  exit(0);
}

sub openSocket() {

  # Assign the port base (and increment later if busy)
  #
  $port = $argo->portBase();

  print "Opening listener on port ".$port."\n";

  # open socket
  #
  $my_socket = new IO::Socket::INET->new(PeerPort => $port,
                                         Proto=>'udp',
                                         PeerAddr=>'localhost')
               or die "Cannot open socket ".$port."\n";
}

sub closeSocket() {

  if (defined($my_socket)) {
    print "Closing listening on port ".$port."\n";
    $my_socket->close();
  }
}

sub sendToSocket() {

  # Keep receiving messages from client
  my $def_msg="Enter message to send to server : ";
  my $looping = 1;
  my $text = "";
  my $msg = "";

  $msg = $input_message;

  chomp $msg;
  if($msg ne '') {
    print "\nSending message '",$msg,"'";
    if($my_socket->send($msg)) {
      print ".....<done>","\n";
      print $def_msg;
    }
  } else {
     # Send an empty message to server and exit
     $my_socket->send('');
     $looping = 0;
  }
}

# Check the arguments
#
checkArgs();

# Load the config file
#
$argo = new Argo();
$argo->loadConfig($configFile);

# Ok, we're up and running now we need to get other command line arguments
#
openSocket();

# Wait for requests
#
sendToSocket();

closeSocket();

exit(0);
