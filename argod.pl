#!/usr/bin/perl -w

use strict;
use File::Basename;
use IO::Socket::INET;
use Argo;
use DBI;

# Install an int sig handler
#
use sigtrap 'handler' => \&intHandler, 'INT';

# Globals
#
my $argo = undef;
my $port = 30767;
my $configFile = "argo.conf";

# Database handle
#
my $dbh = undef;

# The user's id or ip address (REMOTE_ADDR)
#
my $userId="172.168.0.$$"; # set it to process name

# Relevance periods in seconds
#
my $firstPeriod=600;   # 10 minutes
my $secondperiod=1200; # 20 minutes
my $thirdperiod=1800;  # 30 minutes


# My process id and script name
#
my $processId = $$;
my $scriptName = basename($0);

# Global definition of my socket
#
my $my_socket = undef;

# Usage statement
#
sub usage() {
  print "usage: $0 <config.file>\n";
}

# Check the input arguments
#
sub checkArgs() {
  if ( $#ARGV eq 1 ) {
    #usage();
    $configFile = $ARGV[0];
  }

  if ( ! -e $configFile ) {
    die "Config file \"".$configFile."\" does not exist.";
  }
}


# Check for running processes and kill this script if we're exceeding
# the maximum number indicated in the config.
#
sub checkProcesses() {

    # Only check this if we're limiting the number of processes
    #
    if ( $argo->processLimit() > 0 ) {

      my @procList = `ps -eo comm,pid|grep ${scriptName}`;

      my $total = $#procList + 1;
      if ( $total > $argo->processLimit() ) {
        die "Too many ".${scriptName}." processes already running. Limit is ".$argo->processLimit()."\n";
      } else {

        Argo::logMsg("Starting ".$scriptName." with pid ".$processId.".  ".$total." of a possible ".$argo->processLimit());

        my $showProcs = 0;
        if ( $showProcs ) {
          foreach (@procList) {
            chomp();
            Argo::logMsg(" pid : ".$_);
          }
        }
      }
    }
}

# Our local signal handler for interrupts - tidy up and exit
#
sub intHandler() {
  tidyUp();
  Argo::logMsg("Caught interrupt.  Exiting pid ".$processId);
}

sub openSocket() {

  $port = $argo->portBase();

  Argo::logMsg("Opening listener on port ".$port);
  # open socket
  #
  $my_socket = new IO::Socket::INET->new(LocalPort => $port,
                                         Proto=>'udp')
               or die "Cannot open socket ".$port."\n";
}

sub closeSocket() {

  if (defined($my_socket)) {
    Argo::logMsg("Closing listening on port ".$port);
    $my_socket->close();
  }
}

# Insert a message into the store
#
sub insertMessage($) {
  my $text = $_[0];

  if (defined($dbh)) {
    Argo::logMsg("Inserting to DB");
  } else {
    Argo::logMsg("Inserting to file");

    # Open for append
    #
    open WO, ">>", $argo->dbFileStorage() or die "Could not open database file \"".$argo->dbFileStorage()."\" for writing.";
    #WO->autoflush(1);

    # Printing out in epoch time
    #
    print WO time().":".$userId.":".$text."\n"; 
    close WO;
  }
}

# Get the results
#
sub getResults($) {
  my $text = $_[0];

  if (defined($dbh)) {
    Argo::logMsg("Scanning for matches in database.");
  } else {
    Argo::logMsg("Scanning for matches in file storage.");

    my $now = time();
    my %recordSet = $argo->getRecordSet($now - $firstPeriod, $now, $userId, $text);

    if ( keys(%recordSet) > 0 ) {
      for my $row ( sort keys(%recordSet) ) {
        #Argo::logMsg("Retrieved row -> ".${row}.":".$recordSet{$row});
        $recordSet{$row}->print();
      }
    } else {
      Argo::logMsg("No matches found in file storage.");
    }
  }

}


# Processing a message involves storing it and then querying against it
# to return results.
#
sub processMessage($) {
  my $text = $_[0];

  insertMessage($text);
  getResults($text);
}


sub listenOnSocket() {

  # Keep receiving messages from client
  my $looping = 1;
  my $text = "";

  while($looping)
  {
    $my_socket->recv($text,128);
    if($text ne '') {
      processMessage($text);
    } else {
      # If client message is empty exit
      Argo::logMsg("Client has exited.");
      $looping = 0;
    }
  }
}

sub tidyUp() {
  # Close the socket
  #
  closeSocket();

  closeDatabase();
}

# Open a database handle
#
sub openDatabase() {

  # Only attempt a connection if we've got a connection string
  #
  if (defined($argo->dbConnection())) {

    Argo::logMsg("Attempting to connect to database: ".$argo->dbConnection."\n");

    $dbh = DBI->connect($argo->dbConnection(),
                        $argo->dbUser(),
                        $argo->dbPass()) or die "Couldn't connect to database: " . DBI->errstr;
  } else {
    Argo::logMsg("No connection string in config file. Using flat file storage.");
  }
}

# Close a database handle
#
sub closeDatabase() {
  $dbh->disconnect if (defined($dbh));
}

sub main() {

  Argo::logMsg("Starting $scriptName");

  # Check the arguments
  #
  checkArgs();

  # Load the config file
  #
  $argo = new Argo();
  $argo->loadConfig($configFile);

  # open any database connection
  #
  openDatabase();

  # Check for running processes and kill ourselves if we're exceeding max
  #
  checkProcesses();

  # Ok, we're up and running now we need to get other command line arguments
  #
  openSocket();

  # Wait for requests
  #
  listenOnSocket();

  # Perform shutdown tidy up
  #
  tidyUp();

  Argo::logMsg("Stopping $scriptName");

  exit(0);
}

main();
